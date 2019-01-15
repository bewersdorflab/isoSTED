function labview_write_matrix(path, M)
dlmwrite(path, M, 'delimiter', ',', 'precision', 6);
end