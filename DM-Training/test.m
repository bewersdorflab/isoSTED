modeNumber = 15;

load('.\DM data\13RW018#054_calib_3_2016Sep06_18_13_38\analysis data\Zernike Coefficients.mat');   % load Zc
Zc = Zc';
SUM = sum(abs(Zc(1:30,:)));

modeCoefficients = zeros(1,modeNumber);
for j = 1:15
    modeCoefficients(j) = Zc(j,j);
end

points_new = modeCoefficients./SUM(1:modeNumber);

load('.\DM data\13RW018#054_theoretical modes response\analysis data\Zernike Coefficients.mat');   % load Zc
Zc = Zc';
SUM = sum(abs(Zc(1:30,:)));

k =[2 3 6 4 5 10 9 8 7 15 14 12 11 13 21 20 18 19 27 28];   % image theoretical modes to Zernike modes (Noll index)
modeCoefficients = zeros(1,modeNumber);
for j = 2:modeNumber
    modeCoefficients(k(j-1)) = abs(Zc(k(j-1),j-1));
end

points_theory = modeCoefficients./SUM(1:modeNumber);
points = [points_new',points_theory'];

bar(points*100,'DisplayName','points');
legend('new modes','theoretical modes');
axis([0 16 0 100]);
export_fig('comparison.png','-png','-transparent');