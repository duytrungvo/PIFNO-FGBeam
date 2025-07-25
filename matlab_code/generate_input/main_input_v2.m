% generate input for training of PIFNO

clear
close all

addpath classes\
addpath ..\common\

% load parameters
loadparameters_v2

savefil = 'y';
x = linspace(0, 1, nx);

% create class data input
input = data_inputv2(parameters, distribution_form, height_fun, numsample, input_dim, nx, seed_number);
codename = input.codename();

geomodel = char(height_fun);            % geometric model
matmodel = char(distribution_form);     % material model
dataname = [matmodel , '_', geomodel, '_', scalename,'_', ...
    codename, '_', input_type];
filename = ['EB', '_', paramtype, '_', ...
    num2str(nx),'_', 'rng', num2str(seed_number), '_', dataname, '.mat'];

%input folder + input file name
fullfilename = fullfile(inputfolder_name, filename);
% check wheather file is created or not
if exist(fullfilename, 'file') == 2
    fprintf('File %s has already been created!\n', fullfilename)
    data = load(fullfilename);
    input.draw(x, data.input, 1e1)
    input.slope(data.input, data.variables);
    return
end

% generate input func
[input_func, param] = input.generate_input(material_fun);

% save file 
if strcmp(savefil, 'y')    
    data_inputv2.save_data(inputfolder_name, filename, ...
        parameters, x, input_func, param)
end

% plot input functions
data_inputv2.draw(x, input_func, 1e1)
% plot slope index 
data_inputv2.slope(input_func, param);
