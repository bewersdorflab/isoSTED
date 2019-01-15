function [zstruct] = select_zernike_indeces(zstruct, exclude)
selected_indeces = ones(zstruct.ncoeff, 1);
for i=1:numel(selected_indeces)
    if any(i == exclude)
        selected_indeces(i) = 0;
    end
end
zstruct.selected_zernikes = logical(selected_indeces);
end