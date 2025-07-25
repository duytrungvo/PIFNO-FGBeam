function E = powerlaw(x, z, E1, E2, px, pz, L, h)
    % power law distribution of material properties
    E = E2 + (E1 - E2) * (1 - x / 2 / L).^px .* (z / h + 1 / 2).^pz;
end