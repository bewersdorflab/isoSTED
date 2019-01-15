function height = height_voltage(voltage)

voltage = voltage/100*300;
height = 0.03945*voltage^2+0.2539*voltage;   % sigle equation line

end