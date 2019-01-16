function labview_write_matrix(path, M)
dlmwrite(path, M, 'delimiter', '\t', 'precision', '%10.8f', ...
    'newline', 'pc');
end