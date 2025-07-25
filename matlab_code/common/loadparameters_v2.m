% control file

scalename = 'data5';

input_type = 'test';            % train and test and validate
distribution_form = @powerlaw;  % @exponentiallaw; %@powerlaw;
height_fun = @height_linear;       % profile of height function: @height_linear; @height_sin;
material_fun = @materialcoeff;
paramtype = 'bi';              % two/three/four different parameters

BC = 'CF';
numsample = 40000;
if strcmp(input_type, 'test')
    numsample = 2000;
end

if isequal(distribution_form, @powerlaw)
    [E1, nu1, E2, nu2, q, kappa, L, h, b] = input_FGbeam1D(scalename);  % power law
elseif isequal(distribution_form, @exponentiallaw)
    [E1, nu1, E2, nu2, q, kappa, L, h, b] = input_FGbeam1D_exponentiallaw(scalename);  % exponential law
end

parameters.E1 = E1; parameters.nu1 = nu1; parameters.E2 = E2;
parameters.nu2 = nu2; parameters.q = q; parameters.kappa = kappa;
parameters.L = L; parameters.h = h; parameters.b = b;
parameters.lbmaterial = [0, 0]; parameters.ubmaterial = [6, 6];
parameters.lbgeometry = [0.5]; parameters.ubgeometry = [0.5];

P = 100 * E2 * h^3 * b / q / L^4;
input_dim = 1;
nx = 2^10+1;
if strcmp(input_type, 'train')
    seed_number = 0;
elseif strcmp(input_type, 'test')
    seed_number = 1;
elseif strcmp(input_type, 'validate')
    seed_number = 'x';
end
% input folder path
inputfolder_name = ['D:\data_immigration_LocalDiskC\semesters\3rd' ...
    '\science_research\results\generate_data\bidirectionalFGbeam'];
