% Define the directory and filenames
out = '/home/daniil/workspase/Power_data/nobline/';
frequency = 'beta';

% Create the filename by incorporating the frequency variable
mat_filename = fullfile(out, sprintf('average_%s_powers_all_conditions.mat', frequency));

labels_filename = '/home/daniil/workspase/Power_data/nobline/subject_labels_all_conditions.txt';

% Load the .mat file containing the average beta powers
loaded_data = load(mat_filename);
average_beta_powers_all_conditions = loaded_data.average_beta_powers_all_conditions;

% Open the file for reading
fid = fopen(labels_filename, 'r');

% Initialize an empty cell array to store labels
all_conditions = {};

% Read each line of the file
tline = fgetl(fid);
while ischar(tline)
    % Append each line to the cell array
    all_conditions = [all_conditions; {tline}];
    % Get the next line
    tline = fgetl(fid);
end

% Close the file after reading
fclose(fid);

% Extract the first 3 elements from the labels
conditions = all_conditions(1:3);

% Display the first 3 labels (optional)
disp('conditions:');
disp(conditions);

% Comparisons
% Perform the Kruskal-Wallis test
[p, tbl, stats] = kruskalwallis(average_beta_powers_all_conditions, conditions');

% Display the p-value
disp(['P-value from Kruskal-Wallis test: ', num2str(p)]);

% Define the filename for saving the Kruskal-Wallis output
output_filename = fullfile(out, sprintf('kruskalwallis_%s_results.mat', frequency));

% Save the outputs to a .mat file
save(output_filename, 'p', 'tbl', 'stats');

% Perform multiple comparisons
figure;  % Create a new figure to display the multiple comparisons
comparison_results = multcompare(stats, 'CType', 'bonferroni');

% Save the results to a variable
output_filename_posthoc = fullfile(out, 'kruskalwallis_posthoc_results.txt');
fid = fopen(output_filename_posthoc, 'w');

% Write the pairwise comparison results to a text file
fprintf(fid, 'Post-Hoc Pairwise Comparisons (Kruskal-Wallis Test)\n');
fprintf(fid, '---------------------------------------------\n');
fprintf(fid, 'Group 1\tGroup 2\tDifference\tLower Bound\tUpper Bound\tP-value\n');
for i = 1:size(comparison_results, 1)
    fprintf(fid, '%d\t%d\t%.4f\t%.4f\t%.4f\t%.4f\n', comparison_results(i, 1:6));
end

% Close the file
fclose(fid);

disp(['Post-hoc comparison results saved to ', output_filename_posthoc]);

% Extract significant comparisons
significant_comparisons = comparison_results(comparison_results(:, 6) < 0.05, :);

% Plot
% Reshape data into a column vector
data = average_beta_powers_all_conditions;

% Create group labels for each value in the data
num_subjects = size(average_beta_powers_all_conditions, 1);
group_labels = repelem(conditions, num_subjects)';  % Repeat each condition label for all subjects

% Plot the boxplots in one figure
figure_handle = figure;  % Create a figure and store its handle
h = boxplot(data, group_labels);

% Set figure size to enlarge it (in pixels)
set(figure_handle, 'Position', [100, 100, 1200, 800]);  % [left, bottom, width, height]

% Set properties for boxplot line width
set(h, 'LineWidth', 3.5);  % Increase boxplot line width

% Customize axis labels and title
xlabel('Condition', 'FontSize', 32, 'FontWeight', 'bold');
ylabel('Log Power', 'FontSize', 30, 'FontWeight', 'bold');
title(sprintf('Average %s Log Power Across Conditions', frequency), 'FontSize', 30, 'FontWeight', 'bold');

% Customize grid
grid on;

% Set axis properties for enlarged font size
set(gca, 'FontSize', 32, 'LineWidth', 3.5);  % Set font size and axis line width

% Highlight significant comparisons on the boxplot
hold on;
%y_max = max(data(:)) + 0.02 * range(data(:));  % Set starting height for significance markers
y_max = max(data(:));

for i = 1:size(significant_comparisons, 1)
    group1 = significant_comparisons(i, 1);
    group2 = significant_comparisons(i, 2);
    p_value = significant_comparisons(i, 6);
    
    % Define the x-coordinates for the two groups being compared
    x1 = group1;
    x2 = group2;

    % Draw a line between the two groups
    plot([x1, x2], [y_max, y_max], 'k-', 'LineWidth', 4);  % Horizontal line for significance
    text(mean([x1, x2]), y_max - 0.1 * range(data(:)), sprintf('p = %.3f', p_value), ...
         'HorizontalAlignment', 'center', 'FontSize', 33, 'FontWeight', 'bold');
    
    % Increment y_max for the next line
    y_max = y_max + 0.015 * range(data(:));
end

% Hold off after plotting
hold off;

% Define the filename for saving the figure
output_filename = fullfile(out, sprintf('boxplot_average_%s_power.jpg', frequency));

% Save the figure as a .jpg file
saveas(figure_handle, output_filename);  % Save the entire figure, not just the boxplot handle