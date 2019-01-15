function [uf] = solve_Hf_l_inf(Hf, zc0, l_inf, zstruct)
H1 = Hf(zstruct.selected_zernikes, zstruct.selected_acts);
zc1 = zc0(zstruct.selected_zernikes);
nact = size(H1, 2);
cvx_begin
variable u(nact, 1)
minimise norm(zc1 + H1*u)
subject to
norm(u, inf) <= l_inf
cvx_end
uf = zeros(numel(zstruct.selected_acts), 1);
uf(zstruct.selected_acts) = u;
end