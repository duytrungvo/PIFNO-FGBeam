function h1 = height_sin(L, h, param_geo, x)
% variable cross section of beam in sinusoidal form
empty = 0;
for i = 1 : length(param_geo)
    empty = empty + param_geo(i) * sin((2*i-1) * pi * x / L);
end
h1 = h*(1 - empty);
end
