
% Define the file path
file_path = '/home/daniil/workspase/Parkinson/GCFD/PLV_analysis_visualisation/spurious_PLV.csv';

% Read the CSV file into a table
T = readtable(file_path);

% Fit a Generalized Linear Mixed-Effects Model (GLME)
lme = fitglme(T, 'kuramoto ~ 1 + analysis*condition + (1|subject)');

% Display the model results
disp(lme)

% Perform ANOVA (use 'residual' or 'none' for DFMethod)
tbl = anova(lme, 'DFMethod', 'residual');

% Display ANOVA table
disp(tbl);


% Define a contrast matrix with the correct number of columns (6 in this case)
% Each row in the contrast matrix corresponds to a hypothesis test (e.g., condition comparisons)
contrast_matrix = [
    0 1 -1 0 0 0;   % control_motor vs control_whole (main effect of condition)
    0 0 1 -1 0 0;   % ses_off_motor vs ses_off_whole (main effect of condition)
    0 0 0 0 1 -1;   % interaction terms, if needed, modify for specific conditions
];

% Perform the contrast test using the contrast matrix
[p_val, contrast_estimate, stats] = coefTest(lme, contrast_matrix);

% Display the results
disp('P-values for pairwise comparisons:');
disp(p_val);
disp('Contrast estimates:');
disp(contrast_estimate);
disp('Stats:');
disp(stats);