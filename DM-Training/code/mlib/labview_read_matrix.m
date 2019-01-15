function M = labview_read_matrix(path)
M = importdata(path, '\t');
end