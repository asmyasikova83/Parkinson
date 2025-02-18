% Function to read the content of each file
function data = read_data(file_path)   
    % Open the file
    disp(file_path);
    fid = fopen(file_path, 'r');
    % Read each line into a cell array
    data = textscan(fid, '%s', 'Delimiter', '\n');
    % Close the file
    fclose(fid);
    % Convert cell array to a matrix for easy access
    data = data{1};
end