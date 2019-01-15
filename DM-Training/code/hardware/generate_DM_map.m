function generate_DM_map

global setup;

% Load mirror corresponding matrix
flat_map = setup.DM.flat_map;

stepNumber = length(setup.DM.pokeArray);  % step number for each actuator
matrixLength = stepNumber * 140;
setup.DM.map=zeros(144,matrixLength);
setup.DM.uin=zeros(140,matrixLength);

for j=1:matrixLength
    setup.DM.map(:,j)=setup.DM.map(:,j)+flat_map;
end

map_DM=[2:11,13:132,134:143];   % we only have 140 actuators, although we have 144 component in flat matrix

for j=1:140
    for jj = 1:stepNumber
        setup.DM.uin(j,stepNumber*(j-1)+jj) = setup.DM.pokeArray(jj);
    end
end

for j=1:140
    for jj = 1:stepNumber
        setup.DM.map(map_DM(j),stepNumber*(j-1)+jj) = voltage_height(height_voltage(setup.DM.map(map_DM(j),stepNumber*(j-1)+jj))+setup.delta*setup.DM.pokeArray(jj));
    end
end

disp('DM map generated!');

end