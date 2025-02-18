% Define the filename for reading the Kruskal-Wallis results
out = '/home/daniil/workspase/Power_data/nobline/';
output_filename = fullfile(out, 'kruskalwallis_lowgamma_results.mat');

% Load the Kruskal-Wallis results from the .mat file
loaded_data = load(output_filename);

% Extract the variables from the loaded structure
p = loaded_data.p;
tbl = loaded_data.tbl;
stats = loaded_data.stats;

% Display loaded data (optional)
disp('Loaded p-value:');
disp(p);
disp('Loaded table:');
disp(tbl);
disp('Loaded stats:');
disp(stats);