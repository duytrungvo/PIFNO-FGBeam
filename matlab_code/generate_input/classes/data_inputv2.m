% class input, generate input for PIFNO
classdef data_inputv2
    properties
        parameters
        distribution_form
        height_fun
        numsample
        input_dim
        nx
        seed_number
        name
    end

    methods
        function obj = data_inputv2(parameters, distribution_form, ...
                height_fun, numsample, input_dim, nx, seed_number)
            obj.parameters = parameters;
            obj.distribution_form = distribution_form;
            obj.height_fun = height_fun;
            obj.numsample = numsample;
            obj.input_dim = input_dim;
            obj.nx = nx;
            obj.seed_number = seed_number;
        end

        function [input, parameter] = generate_input(obj, material_fun)
            lbgeometry = obj.parameters.lbgeometry;
            E1 = obj.parameters.E1; E2 = obj.parameters.E2;
            b = obj.parameters.b; h = obj.parameters.h;
            kappa = obj.parameters.kappa;
            nu1 = obj.parameters.nu1;
            num_data = obj.numsample;
            numparamgeo = length(lbgeometry);
            nx = obj.nx;
            x = linspace(0,1,nx);   % scale data
            % x = linspace(0,obj.parameters.L,nx);  % original data
            parameter = zeros(obj.numsample, 2 + numparamgeo);
            e2 = zeros(nx, 1);
            input = zeros(num_data,nx,obj.input_dim);
            rng(obj.seed_number)
            for i = 1 : num_data
                [px, pz, paramgeo] = random_coefficients(obj);
                parameter(i, 1) = px; parameter(i, 2) = pz;
                parameter(i, 3:end) = paramgeo;
                parfor j = 1 : nx
                    h1 = obj.height_fun(1, h, paramgeo, x(j));
                    [~, ~, e2x, ~] = material_fun(obj.distribution_form, x(j), E1, E2, px, pz, 1, h1, b, kappa, nu1);
                    e2(j) = e2x;
                end
                input(i, :, 1) = e2;

            end         % end of function generate input

        end

        function [px, pz, paramgeo] = random_coefficients(obj)
            lbpx = obj.parameters.lbmaterial(1); ubpx = obj.parameters.ubmaterial(1);
            lbpz = obj.parameters.lbmaterial(2); ubpz = obj.parameters.ubmaterial(2);
            lbgeometry = obj.parameters.lbgeometry; ubgeometry = obj.parameters.ubgeometry;

            numparamgeo = length(lbgeometry);
            lbgeo1 = lbgeometry(1); ubgeo1 = ubgeometry(1);
            if numparamgeo == 2
                lbgeo2 = lbgeometry(2); ubgeo2 = ubgeometry(2);
            end

            px = lbpx;
            if lbpx < ubpx
                px = lbpx + (ubpx - lbpx) * rand;
            end

            pz = lbpz;
            if lbpz < ubpz
                pz = lbpz + (ubpz - lbpz) * rand;
            end

            geo1 = lbgeo1;
            if lbgeo1 < ubgeo1
                geo1 = lbgeo1 + (ubgeo1 - lbgeo1) * rand;
            end

            paramgeo = geo1;
            if numparamgeo == 2
                geo2 = lbgeo2;
                if lbgeo2 < ubgeo2
                    geo2 = lbgeo2 + (ubgeo2 - lbgeo2) * rand;
                end
                paramgeo = [geo1, geo2];
            end
        end         % end of function random coefficients

        function codename = codename(obj)
            lbpx = obj.parameters.lbmaterial(1); ubpx = obj.parameters.ubmaterial(1);
            lbpz = obj.parameters.lbmaterial(2); ubpz = obj.parameters.ubmaterial(2);
            lbgeometry = obj.parameters.lbgeometry; ubgeometry = obj.parameters.ubgeometry;

            numparamgeo = length(lbgeometry);
            lbgeo1 = lbgeometry(1); ubgeo1 = ubgeometry(1);
            if numparamgeo == 2
                lbgeo2 = lbgeometry(2); ubgeo2 = ubgeometry(2);
            end
            codename = [];
            if lbpx == ubpx
                codename = [codename, 'f', stringname(lbpx)];
            else
                codename = [codename, 'r', stringname(lbpx), stringname(ubpx)];
            end

            if lbpz == ubpz
                codename = [codename, 'f', stringname(lbpz)];
            else
                codename = [codename, 'r', stringname(lbpz), stringname(ubpz)];
            end

            if lbgeo1 == ubgeo1
                codename = [codename, 'f', stringname(lbgeo1)];
            else
                codename = [codename, 'r', stringname(lbgeo1), stringname(ubgeo1)];
            end

            if numparamgeo == 2
                if lbgeo2 == ubgeo2
                    codename = [codename, 'f', stringname(lbgeo2)];
                else
                    codename = [codename, 'r', stringname(lbgeo2), stringname(ubgeo2)];
                end
            end
        end         % end of function code name


    end         % end of methods

    methods (Static)
        % find derivative at the end
        function slope(input, parameter)
            n = size(input, 1);
            slp = zeros(n,1);
            w2 = [1/2, -2, 3/2];
            w3 = [-1/3, 3/2, -3, 11/6];
            for i = 1:n
                % slp(i) = w2 * input(i, end-2:end)';     % order 2
                slp(i) = w3 * input(i, end-3:end)';     % order 3
            end
            figure
            plot(parameter(:,1), slp ./ abs(slp), 'or')
            xlabel('$pde1$', Interpreter='latex')
            ylabel('slope index')
            ylim([-1.1, 1.1])
            set(gca, "FontSize", 14)
            figure
            plot(parameter(:,2), slp ./ abs(slp), 'or')
            xlabel('$pde2$', Interpreter='latex')
            ylabel('slope index')
            ylim([-1.1, 1.1])
            set(gca, "FontSize", 14)
            figure
            plot(parameter(:,3), slp ./ abs(slp), 'or')
            xlabel('$geo1$', Interpreter='latex')
            ylabel('slope index')
            ylim([-1.1, 1.1])
            set(gca, "FontSize", 14)
            if size(parameter, 2) == 4
                figure
                plot(parameter(:,4), slp ./ abs(slp), 'or')
                xlabel('$geo2$', Interpreter='latex')
                ylabel('slope index')
                ylim([-1.1, 1.1])
                set(gca, "FontSize", 14)
            end
        end

        % draw function
        function draw(x, input_func, incr)
            figure
            plot(x, input_func(1:incr:end,:))
            xlabel('$\bar{x}$', 'Interpreter','latex')
            ylabel('$EI(\bar{x})$', Interpreter='latex')
            set(gca, "FontSize", 14)
        end

        % save file function
        function save_data(folder_name, filename, ...
                parameters, x, input, variables)

            filepath = fullfile(folder_name, filename);
            save(filepath, "parameters", "x", "input", "variables")

        end
    end         % end of methods static
end

function strname = stringname(number)
strname = num2str(number);
if length(strname) > 2
    strname(2) = [];
end
end