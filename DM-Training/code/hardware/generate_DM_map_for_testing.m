function generate_DM_map_for_testing(flatmap,C)

global setup;

map_DM=[2:11,13:132,134:143];

setup.DM.flat_map=flatmap;
% setup.DM.flat_map_1=zeros(144,1);
setup.DM.map=zeros(144,setup.zernike_poly_num);

% for i=1:140
%     setup.DM.flat_map_1(map_DM(i))=flat_map_1(i)/0.3*100;
% end

for i=1:setup.zernike_poly_num
    setup.DM.map(:,i)=setup.DM.map(:,i)+setup.DM.flat_map;%+setup.DM.flat_map_1;
end

setup.DM.control_matrix=C;

for i=1:setup.zernike_poly_num
    for j=1:140
        setup.DM.map(map_DM(j),i)=voltage_height(height_voltage(setup.DM.map(map_DM(j),i))+setup.DM.control_matrix(j,i)*setup.delta);
    end
end
setup.DM.map=abs(setup.DM.map);

end