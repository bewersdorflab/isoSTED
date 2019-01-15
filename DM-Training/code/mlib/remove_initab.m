function [Yrs, Ym] = remove_initab(Yrs)
Ym = mean(Yrs, 2);
Yrs = Yrs - kron(ones(1, size(Yrs, 2)), Ym);
end