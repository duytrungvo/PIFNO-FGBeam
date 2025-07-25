function E = exponentiallaw(x, z, E1, E2, px, pz, L, h)
% exponential law distribution of material
Em = E1;
E = Em * exp(px * x / L + pz * (1 / 2 + z / h));
end