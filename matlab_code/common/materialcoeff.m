function [e0, e1, e2, g0] = materialcoeff(distributrion_form, x, E1, E2, px, pz, L, h, b, kappa, nu1)

NG = 24;
[p, w] = lgwt(NG, -h/2, h/2);
e0 = 0;
e1 = 0;
e2 = 0;
g0 = 0;
for i = 1 : NG
    xii = p(i);
    wi = w(i);
    % I0 = E2 + (E1 - E2) * (1 - x / 2 / L).^px * (xii / h + 1 / 2)^pz;
    I0 = distributrion_form(x, xii, E1, E2, px, pz, L, h);
    e0 = e0 + b * I0 * wi;

    I1 = I0 * xii;
    e1 = e1 + b * I1 * wi;

    I2 = I0 * xii^2;
    e2 = e2 + b * I2 * wi;

    I3 = I0 / 2 / (1 + nu1);
    g0 = g0 + b * kappa * I3 * wi;
end

end