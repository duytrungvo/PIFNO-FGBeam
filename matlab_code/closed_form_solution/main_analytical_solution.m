% fem solution of FG beam using Euler Bernoulli beam theory

clear
close all

addpath 'classes\'
addpath '..\common\'

% for BC = ["CS", "SS", "CF"]
% load parameter file
loadparameters_v2
if strcmp(input_type, 'train')
    fprintf('The data is required as test not %s', input_type)
    return
end
savefil = 'y';

N = 2^7+1;      % number of elements
% create class femFGbeam
analyticalsol = closedformsolution(parameters, BC, height_fun, material_fun, distribution_form);
codename = analyticalsol.codename();
geomodel = char(height_fun);            % geometric model                             
matmodel = char(distribution_form);     % material model
dataname = [matmodel , '_', geomodel, '_', scalename,'_', ...
    codename, '_', input_type];
filename = ['exactEB', '_', paramtype, '_', ...
    num2str(nx),'_', 'rng', num2str(seed_number), '_', dataname, '.mat'];
fullfilename = fullfile(BC,filename);
% check file wheather created or not
if exist(fullfilename, 'file') == 2
    fprintf('File %s has already been created!\n', fullfilename)
    data = load(fullfilename);
    key = 18;
    px = data.variables(key,1);
    pz = data.variables(key,2);
    param_geo = data.variables(key,3:end);
    analyticalsol.visualize_domain(N, px, pz, param_geo, zeros(N,1), zeros(N,1))     % 
    analyticalsol.visualize_domain(N, px, pz, param_geo, data.sol(key,:,1), data.rotation(key, :))
    return
end

% load input data
dg = analyticalsol.load_input(height_fun, distribution_form, ...
    scalename, paramtype, codename, input_type, nx, seed_number, inputfolder_name);

numsample = length(dg.variables);
sol = zeros(numsample, N, 2);
rotation = zeros(numsample, N);

NG = 8; % 8 for tapered beam; 24 for emptied beam
q = analyticalsol.parameters.q;
x = linspace(0, L, N);
tic
for i = 1:numsample   
    px = dg.variables(i,1);
    pz = dg.variables(i,2);
    param_geo = dg.variables(i,3:end); 
    [C1, C2, C3, C4] = analyticalsol.coefficients(NG, q, px, pz, param_geo);
    for j = 1:length(x)
        w(j) = analyticalsol.displacement(x(j), NG, q, px, pz, C1, C2, C3, C4, param_geo);
        phi(j) = analyticalsol.rotation(x(j), NG, px, pz, C1, C2, C3, q, param_geo);
    end
    M = analyticalsol.bendingmoment(x, q, C1, C2);

    sol(i, :, 1) = w;
    sol(i, :, 2) = M;
    rotation(i, :) = phi;
end
toc

fprintf('Max deflection of displacement for px = %0.4f, pz = %0.4f, param_geo = [',px, pz)
fprintf('%g ', param_geo)
fprintf('], BC = %s, is %f \n', BC, max(abs(w * P)))

% visualize undeformed shape of the beam  
key = 5;
px = dg.variables(key,1);
pz = dg.variables(key,2);
param_geo = dg.variables(key,3:end);
analyticalsol.visualize_domain(N, px, pz, param_geo, 0*sol(key,:,1), 0*rotation(key, :))
analyticalsol.visualize_domain(N, px, pz, param_geo, sol(key,:,1), rotation(key, :))

if strcmp(savefil, 'y')    
    save(fullfilename, "parameters", "sol", "x", "rotation")
    save(fullfilename, "-struct", "dg", "variables","-append")    
end
% end