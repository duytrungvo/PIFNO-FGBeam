
function [E1, nu1, E2, nu2, q, kappa, L, h, b] = input_FGbeam1D_exponentiallaw(scalename)
% parameters of the beams

nu1 = 0.3;          % Poisson ratio

nu2 = 0.3;

kappa = 5/6;

% geometric parameters
L = 2;              % length (m)
b = 0.1;            % width (m)
h = 0.1;            % thickness/height (m)
E1 = 210e9;         % Young modulus (Pa)
E2 = 210e9;          % Young modulus (Pa)
q = 1e4;            % N/m

if strcmp(scalename, 'data1')
    % referred to Modeling and analysis of bi-directional functionally graded nanobeams based on nonlocal strain gradient theory
    % Isogeometric size optimization of bi-directional functionally graded beams under static loads
    % Bending behaviour of two directional functionally graded sandwich beams by using a quasi-3d shear deformation theory
    scale = 1;
end

if strcmp(scalename, 'data5')
    scale = q * 0.5;
end

E1 = E1 / scale;         % Young modulus (Pa)
E2 = E2 / scale;
q = q / scale;            % xN/m

end