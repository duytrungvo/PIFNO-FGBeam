classdef closedformsolution
    properties
        BC
        parameters
        height_fun
        material_fun
        distribution_form
    end

    methods

        function obj = closedformsolution(parameters, BC, height_fun, material_fun, distribution_form)
            obj.parameters = parameters;
            obj.BC = BC;
            obj.height_fun = height_fun;
            obj.material_fun = material_fun;
            obj.distribution_form = distribution_form;
        end

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

        function [C1, C2, C3, C4] = coefficients(obj, NG, q, px, pz, alpha)
            BC = obj.BC;
            height_fun = obj.height_fun;
            material_fun = obj.material_fun;
            distribution_form = obj.distribution_form;
            L = obj.parameters.L;
            if strcmp(BC, 'CC')
                C3 = 0;
                C4 = 0;
                T(1,1) = obj.func(L, NG, px, pz, 1, 0, 0, alpha);
                T(1,2) = obj.func(L, NG, px, pz, 0, 1, 0, alpha);
                T(2,1) = obj.displacement(L, NG, 0, px, pz, 1, 0, 0, 0, alpha);
                T(2,2) = obj.displacement(L, NG, 0, px, pz, 0, 1, 0, 0, alpha);
                d(1,1) = -obj.func(L, NG, px, pz, 0, 0, q, alpha);
                d(2,1) = -obj.displacement(L, NG, q, px, pz, 0, 0, 0, 0, alpha);
                solC = T \ d;
                C1 = solC(1);
                C2 = solC(2);
            end

            if strcmp(BC, 'CS')
                C3 = 0;
                C4 = 0;
                T(1,1) = 1; T(1,2) = L;
                T(2,1) = obj.displacement(L, NG, 0, px, pz, 1, 0, 0, 0, alpha);
                T(2,2) = obj.displacement(L, NG, 0, px, pz, 0, 1, 0, 0, alpha);
                d(1,1) = q * L^2 / 2;
                d(2,1) = -obj.displacement(L, NG, q, px, pz, 0, 0, 0, 0, alpha);
                solC = T \ d;
                C1 = solC(1);
                C2 = solC(2);
            end

            if strcmp(BC, 'SS')
                C1 = 0;
                C2 = q*L/2;
                C3 = -obj.displacement(L, NG, q, px, pz, C1, C2, 0, 0, alpha) / L;
                C4 = 0;
            end
            if strcmp(BC, 'CF')
                C1 = -q*L^2/2;
                C2 = q*L;
                C3 = 0;
                C4 = 0;
            end

        end     % end of function coefficients

        function wx = displacement(obj, x, NG, q, px, pz, C1, C2, C3, C4, alpha)
            % q = obj.parameters.q;
            [point,w] = lgwt(NG,-1,1);
            wx = 0;
            detJ = x/2;
            for i = 1:NG
                xi = point(i);
                s = x/2 * xi + x/2;
                wx = wx + obj.func(s, NG, px, pz, C1, C2, q, alpha) * w(i) * detJ;
            end

            wx = wx + C3 * x + C4;
        end     % end of function displacement

        function phi = rotation(obj, x, NG, px, pz, C1, C2, C3, q, alpha)
                phi = obj.func(x, NG, px, pz, C1, C2, q, alpha) + C3;
        end     % end of function phi

        function f = func(obj, s, NG, px, pz, C1, C2, q, alpha)
            height_fun = obj.height_fun;
            material_fun = obj.material_fun;
            distribution_form = obj.distribution_form;

            % load parameters
            E1 = obj.parameters.E1;         % Young modulus (Pa)
            E2 = obj.parameters.E2;

            nu1 = obj.parameters.nu1;          % Poisson ratio
            % nu2 = obj.parameters.nu2;
            kappa = obj.parameters.kappa;

            % geometric parameters
            L = obj.parameters.L;              % length (m)
            W = obj.parameters.h;            % width/height (m)
            thk = obj.parameters.b;         % thickness (m)

            [point, w] = lgwt(NG,-1,1);
            f = 0;
            detJ = s/2;
            for i = 1:NG
                xi = point(i);
                t = s/2 * xi + s/2;
                h1 = height_fun(L, W, alpha, t);
                [~, ~, e2e, ~] = material_fun(distribution_form, t, E1, E2, px, pz, L, h1, thk, kappa, nu1);
                f = f + (-q * t^2 + t * C2 + q * t^2 / 2 + C1) / e2e * w(i) * detJ;
            end

        end         % end of function func        

        function visualize_domain(obj, N, px, pz, param_geo, w, phi)
            
            height_fun = obj.height_fun;            
            distribution_form = obj.distribution_form;

            E1 = obj.parameters.E1; E2 = obj.parameters.E2;
            L = obj.parameters.L; h = obj.parameters.h;
            NE = N-1;
            Ny = 10;
            x = zeros(NE+1, Ny);
            z = zeros(NE+1, Ny);
            Exz = zeros(NE+1, Ny);
            xi = linspace(0, 1, NE+1);
            xt = xi * L;

            for i = 1 : NE + 1
                x(i, :) = repmat(xt(i), 1, Ny);
                h1 = height_fun(L, h, param_geo, xt(i));
                z(i, :) = linspace(-h1/2, h1/2, Ny);
                Exz(i, :) = distribution_form(x(i,:), z(i,:), E1, E2, px, pz, L, h1);
            end

            % Exz = distribution_form(x, z, E1, E2, px, pz, L, h);

            um = zeros(NE+1, Ny);
            for i = 1 : NE + 1
                um(i,:) = -z(i, :) .* phi(i);
            end

            wm = zeros(NE+1, Ny);
            for i = 1 : Ny
                wm(:, i) = w;
            end

            scale = 4;
            figure
            s = pcolor(x + um, (z + wm * 10) * scale , Exz);
            colormap('jet')
            colorbar
            title(['$px$ = ', num2str(px), ', $pz$ = ', num2str(pz), ...
                ', param geo = ', num2str(param_geo)], Interpreter="latex")
            s.FaceColor="interp";
            s.LineStyle='none';
            axis equal %fill %image %padded %tight %equal
            axis off
        end         % end of function visualization

    end             % end of methods
    methods (Static)
        % load data
        function dg = load_input(height_fun, distribution_form, ...
                scalename, paramtype, codename, input_type, nx, seed_number, dfolder)
            geomodel = char(height_fun);            % geometric model
            matmodel = char(distribution_form);     % material model
            % maxparamgeo = '0';
            dataname = [matmodel , '_', geomodel, '_', scalename,'_', ...
                codename, '_', input_type];
            dfilename = ['EB', '_', paramtype, '_', ...
                num2str(nx),'_', 'rng', num2str(seed_number), '_', dataname];
            % dfolder = '..\generate_data\bi_directional_FGbeam\';
            dfullname = fullfile(dfolder, dfilename);
            dg = load(dfullname);
        end         % end of function load input

        function M = bendingmoment(x, q, C1, C2)
            M = -q * x.^2 + x * C2 + q * x.^2 / 2 + C1;
        end         % end of function bending moment

    end             % end of methods static

end

function strname = stringname(number)
strname = num2str(number);
if length(strname) > 2
    strname(2) = [];
end
end
