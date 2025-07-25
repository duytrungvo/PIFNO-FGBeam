function h1 = height_linear(L, h, param_geo, x)
% variable cross section of beam in linear form

h1 = h * (1 - param_geo(1) * x / L);
end