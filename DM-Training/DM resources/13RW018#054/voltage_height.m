function voltage = voltage_height(height)

voltage = (-0.2539+sqrt(0.06446+0.1578*height))/0.07891; % single equation line
voltage = voltage/300*100;

end