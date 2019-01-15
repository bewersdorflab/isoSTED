function [uf] = solve_Hf_ls(Hf, zc0, zstruct)
H1 = Hf(zstruct.selected_zernikes, zstruct.selected_acts);
zc1 = zc0(zstruct.selected_zernikes);
u = -H1\zc1;
uf = zeros(numel(zstruct.selected_acts), 1);
uf(zstruct.selected_acts) = u;
end