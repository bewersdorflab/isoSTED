function [Yrs, n1rs, n2rs, apmaskrs] = resample_Yout(Yout, ...
    apmaskorig, n1new, n2new)

nmeas = size(Yout, 2);

nsupporig = sum(apmaskorig(:));
[n1orig, n2orig] = size(apmaskorig);
assert(size(Yout, 2) == nmeas);
assert(size(Yout, 1) == nsupporig);

n1rs = min([n1new, n1orig]);
n2rs = min([n2new, n2orig]);
if n1rs ~= n1orig || n2rs ~= n2orig
    apmaskrs = fourier_apmask(randn(n1rs, n2rs));
    nsupprs = sum(apmaskrs(:));
    Yrs = zeros(nsupprs, nmeas);
    for i=1:nmeas
        Phi_org = make_Phi(Yout(:, i), apmaskorig, 0);
        Phi_rs = resampleinterp(Phi_org, [n1rs, n2rs]);
        Phi_inap = Phi_rs(apmaskrs);

        assert(all(isfinite(Phi_org(apmaskorig))));
        assert(all(isfinite(Phi_rs(apmaskrs))));
        assert(all(isfinite(Phi_inap)));

        Yrs(:, i) = Phi_inap;
    end
else
    Yrs = Yout;
    apmaskrs = apmaskorig;
end
assert(all(isfinite(Yrs(:))));
end
