
function [E1, nu1, E2, nu2, q, kappa, L, h, b] = input_FGbeam1D(scalename)
% parameters of the beams

nu1 = 0.3;          % Poisson ratio

nu2 = 0.3;

kappa = 5/6;

% geometric parameters
L = 2;              % length (m)
b = 0.1;            % width (m)
h = 0.1;            % thickness/height (m)
E1 = 380e9;         % Young modulus (Pa)
E2 = 70e9;          % Young modulus (Pa)
q = 1e4;            % N/m

if strcmp(scalename, 'data1')
    % referred to Modeling and analysis of bi-directional functionally graded nanobeams based on nonlocal strain gradient theory
    % Isogeometric size optimization of bi-directional functionally graded beams under static loads
    % Bending behaviour of two directional functionally graded sandwich beams by using a quasi-3d shear deformation theory
    scale = 1;
end

if strcmp(scalename, 'data2')
    scale = 1502;
end

if strcmp(scalename, 'data3')
    scale = 226;
end

if strcmp(scalename, 'data4')
    scale = q;
end

if strcmp(scalename, 'data5')
    scale = q * 0.5;
end

if strcmp(scalename, 'data5a')
    L = 10;
    scale = q * 0.5;
end

if strcmp(scalename, 'data6')
    scale = q * 1e1;
end

if strcmp(scalename, 'data7')
    scale = 1117;
end

if strcmp(scalename, 'data8')
    scale = q * 100;
end

if strcmp(scalename, 'data9')
    scale = q * 1e-2;
end

if strcmp(scalename, 'data10')
    % origianl form 
    % L = 2;
    scale = 1;
end

E1 = E1 / scale;         % Young modulus (Pa)
E2 = E2 / scale;
q = q / scale;            % xN/m


end