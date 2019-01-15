
function update_DM

global setup;
global hardware;

UPDATE_multiDM(hardware.DM.driver_info, setup.DM.map(:,setup.loop));

end