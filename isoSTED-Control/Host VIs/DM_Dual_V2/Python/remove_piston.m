function [Yout] = remove_piston(Yout)
means = mean(Yout, 1);
Yout = Yout - kron(ones(size(Yout, 1), 1), means);
end
