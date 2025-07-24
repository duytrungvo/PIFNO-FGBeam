import torch
import torch.nn.functional as F
# from torchmetrics.functional.regression import r2_score
from train_utils.utils import boundary_function


def pino_loss_reduced_order2_1d(func):
    def inner(*args, **kwargs):
        Du1, Du2, boundary_l, boundary_r = func(*args, **kwargs)
        f1 = torch.zeros(Du1.shape, device=args[2].device)
        f_loss1 = F.mse_loss(Du1, f1)
        f2 = torch.zeros(Du2.shape, device=args[2].device)
        f_loss2 = F.mse_loss(Du2, f2)

        loss_boundary_l = F.mse_loss(boundary_l, torch.zeros(boundary_l.shape, device=args[2].device))
        loss_boundary_r = F.mse_loss(boundary_r, torch.zeros(boundary_r.shape, device=args[2].device))

        return f_loss1, f_loss2, loss_boundary_l, loss_boundary_r
    return inner

class LpLoss(object):
    '''
    loss function with rel/abs Lp loss
    '''
    def __init__(self, d=2, p=2, size_average=True, reduction=True):
        super(LpLoss, self).__init__()

        #Dimension and Lp-norm type are postive
        assert d > 0 and p > 0

        self.d = d
        self.p = p
        self.reduction = reduction
        self.size_average = size_average

    def abs(self, x, y):
        num_examples = x.size()[0]

        #Assume uniform mesh
        h = 1.0 / (x.size()[1] - 1.0)

        all_norms = (h**(self.d/self.p))*torch.norm(x.view(num_examples,-1) - y.view(num_examples,-1), self.p, 1)

        if self.reduction:
            if self.size_average:
                return torch.mean(all_norms)
            else:
                return torch.sum(all_norms)

        return all_norms

    def rel(self, x, y):
        num_examples = x.size()[0]

        diff_norms = torch.norm(x.reshape(num_examples,-1) - y.reshape(num_examples,-1), self.p, 1)
        y_norms = torch.norm(y.reshape(num_examples,-1), self.p, 1)

        if self.reduction:
            if self.size_average:
                return torch.mean(diff_norms/y_norms)
            else:
                return torch.sum(diff_norms/y_norms)

        return diff_norms/y_norms

    def __call__(self, x, y):
        return self.rel(x, y)

@pino_loss_reduced_order2_1d
def FDM_ReducedOrder2_Euler_Bernoulli_FGBeam_BSF(config_data, a, u, bc):
    batchsize = u.size(0)
    nx = u.size(1)
    dx = 1 / (nx - 1)
    # E = config_data['E']
    q = config_data['q']
    b = config_data['b']
    BC = config_data['BC']
    out_dim = config_data['out_dim']
    u = u.reshape(batchsize, nx, out_dim)

    mxx = (u[:, :-2, 1] - 2 * u[:, 1:-1, 1] + u[:, 2:, 1]) / dx ** 2
    uxx = (u[:, :-2, 0] - 2 * u[:, 1:-1, 0] + u[:, 2:, 0]) / dx ** 2
    D = a[:, 1:-1, 0]
    m = u[:, 1:-1, 1]

    G1, G2, d2G1dx2, d2G2dx2, boundary_l, boundary_r \
        = boundary_function(u[:, :, 0], u[:, :, 1], bc, nx, dx, BC)

    Du1 = (mxx - d2G2dx2[:, 1:-1]) / q + 1.0
    # Du2 = E * I * (uxx - d2G1dx2[:, 1:-1]) + m - G2[:, 1:-1]
    # Du2 = (uxx - d2G1dx2[:, 1:-1]) - (m - G2[:, 1:-1]) / D
    Du2 = D * (uxx - d2G1dx2[:, 1:-1]) - (m - G2[:, 1:-1])

    return Du1, Du2, boundary_l, boundary_r

@pino_loss_reduced_order2_1d
def FDM_ReducedOrder2_Euler_Bernoulli_FGBeam_BSF_norm(config_data, a, u, bc):
    batchsize = u.size(0)
    nx = u.size(1)
    dx = 1 / (nx - 1)
    L = config_data['L']
    q = config_data['q']
    b = config_data['b']
    h = config_data['h']
    Em = config_data['Em']
    P = 100.0 * Em * h**3 * b / q / L**4
    BC = config_data['BC']
    out_dim = config_data['out_dim']
    u = u.reshape(batchsize, nx, out_dim)

    mxx = (u[:, :-2, 1] - 2 * u[:, 1:-1, 1] + u[:, 2:, 1]) / dx ** 2
    uxx = (u[:, :-2, 0] - 2 * u[:, 1:-1, 0] + u[:, 2:, 0]) / dx ** 2
    D = a[:, 1:-1, 0]
    m = u[:, 1:-1, 1]

    G1, G2, d2G1dx2, d2G2dx2, boundary_l, boundary_r \
        = boundary_function(u[:, :, 0], u[:, :, 1], bc, nx, dx, BC)

    # Du1 = (mxx - d2G2dx2[:, 1:-1]) / q / L**2 + 1.0
    Du1 = (mxx - d2G2dx2[:, 1:-1]) / L**2 + q
    Du2 = (uxx - d2G1dx2[:, 1:-1]) * D / P / L**2 - (m - G2[:, 1:-1])

    return Du1, Du2, boundary_l, boundary_r
