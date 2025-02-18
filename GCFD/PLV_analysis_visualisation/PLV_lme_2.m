
%script for plotting timecourses

data_cognitive_dir =  '/home/daniil/workspase/Parkinson/Cognitive_measurements/'
conditions = {'control',  'ses_off', 'ses_on'};  % Conditions for both scenarios
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)
freq = {'beta', 'broadbandgamma'};
dir_pics = '/home/daniil/workspase/PLV_report/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/'
kuramoto_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';

% Number of conditions
numConditions = length(conditions);

% Initialize averaged_kuramoto as a cell array with numConditions columns
%15 is length(subjects)
kuramoto =[];

% Initialize power as a cell array with numConditions columns
power_beta = [];
power_gamma = [];

mmse = [];
naart_int = [];
gender = [];
age = [];
disease_duration_int = [];

conds = [];

subjects_for_cognitive_scores = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_32', 'PD_33', 'PD_31'; ...
    'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'; ...
    'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};

subjects_for_cognitive_scores(2, :)

for condIdx = 1:length(conditions)
    disp(condIdx);
    condition = conditions{condIdx};

    % Define subjects based on condition
    if strcmp(condition, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_32', 'PD_33', 'PD_31'};
    elseif strcmp(condition, 'ses_on') 
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    else
        %for pd_28 no sign PLV in ses_off
        assert(strcmp(condition, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    end

    kuramoto_filename = fullfile(kuramoto_fpath, ['kuramoto_' condition '.txt']);
    k = dlmread(kuramoto_filename, '\t');
    kuramoto = [kuramoto; k'];

    % Extract the relevant row and ensure it's processed correctly
    current_subjects = subjects_for_cognitive_scores(condIdx, :);
    
    % Repeat the condition name for the length of current_subjects
    conds = [conds; repmat({condition}, length(current_subjects), 1)];

    % Call the function to extract cognitive and behavioral scores
    [m, n, g, a, d] = extract_cognitive_behavioral_scores(data_cognitive_dir, current_subjects);

    % Concatenate the results
    mmse = [mmse; m];
    naart_int = [naart_int; n];
    gender = [gender; g];
    age = [age; a];
    disease_duration_int = [disease_duration_int; d];
end


SubjectID = (1:length(kuramoto))';

genderBinary = zeros(size(gender));
genderBinary(strcmp(gender, 'm')) = 1;

%Model
T = table(kuramoto, conds,  SubjectID, 'VariableNames', {'y','x1', 'Subject'});
lme = fitglme(T, 'y ~ 1 + x1 + (1|Subject)');

% Display results
disp(lme);
% Extract the fixed effects coefficients table
coeff_table = lme.Coefficients;

% Display the p-values
p_values = coeff_table.pValue;

p_fdr = mafdr(p_values(2:end), 'BHFDR', true)

% Compare fixed effects and random effects
%anova_lme = anova(lme);
%disp('LME Fixed Effects Significance Test:');
%disp(anova_lme);

% Create a contrast vector: ses_on - ses_off
% Coefficient order: [Intercept, x1_ses_off, x1_ses_on]
contrast_vector = [0, -1, 1]; % Compare "ses_on" vs "ses_off"

% Perform the custom contrast test
[p_seson_sesoff, F, df] = coefTest(lme, contrast_vector);

% Gather all p-values (e.g., fixed effects and pairwise contrasts)
% Extract fixed effects p-values from the model
fixed_pvalues = lme.Coefficients.pValue(2:end); % Exclude Intercept
fixed_names = lme.Coefficients.Name(2:end);

% Append the custom contrast p-value
all_pvalues = [fixed_pvalues; p_seson_sesoff];
all_tests = [fixed_names; "ses_on vs ses_off"];

p_fdr_secondary  = mafdr(all_pvalues, 'BHFDR', true)

% Prepare a compatible stats-like object for Tukey's HSD
groups = conditions; % Get unique levels of the grouping variable
n_groups = length(conditions);

% Extract groups and values
groups = unique(T.x1); % Get unique group names
n_groups = numel(groups);
y = T.y; % Dependent variable
x1 = T.x1; % Group variable

% Initialize figure
fig = figure('Units', 'pixels', 'Position', [1000, 1000, 1200, 800]);

% Boxplot
h = boxplot(y, x1, 'Colors', 'k', 'Symbol', 'o', 'Widths', 0.6); % Boxplot handle
set(findobj(h, 'Type', 'Line'), 'LineWidth', 4); % Make lines thicker
hold on;

% Pairwise comparisons with ranksum (Mann-Whitney U test)
y_max = max(y);
y_offset = 0.1 * (y_max - min(y)); % Reduced space for annotations

% Counter to increment bar levels
bar_level = 1;
% Append the last value of p_fdr_secondary to p_fdr
fdr_complete = [p_fdr; p_fdr_secondary(end)];

% Precompute the indices for pairwise comparisons
pair_idx = 0;

% Loop through pairwise comparisons
for i = 1:n_groups
    for j = i+1:n_groups
        % Increment index for pairwise p-values
        pair_idx = pair_idx + 1;

        % Extract significance level from fdr_complete
        current_p = fdr_complete(pair_idx);
        
        % Determine significance level
        if current_p < 0.001
            sig = '***';
        elseif current_p < 0.01
            sig = '**';
        elseif current_p < 0.05
            sig = '*';
        else
            sig = 'n.s.';
        end
        
        % Add significance annotation at incremented levels
        x1_pos = i;
        x2_pos = j;
        y_pos = y_max + y_offset * pair_idx; % Increment bar level dynamically
        h_bar = y_offset / 4; % Height of the bar
        
        % Draw significance bar
        plot([x1_pos, x1_pos, x2_pos, x2_pos], [y_pos, y_pos + h_bar, y_pos + h_bar, y_pos], ...
            'k-', 'LineWidth', 2.5);
        
        % Add text annotation above the bar
        text(mean([x1_pos, x2_pos]), y_pos + 2.5 * h_bar, sig, ...
            'HorizontalAlignment', 'center', 'FontSize', 24, 'FontWeight', 'bold');
    end
end
% Customize the plot
% Split the last segment by the '_' delimiter
parts = dir_pics(1:end-1);
words = strsplit(parts, '_');
annotation = strjoin(words(end-1:end), ' '); % Combine last two words
title(annotation);
ylabel('PLVs');

xlabel('Conditions');
ylim([min(y), y_max + y_offset * 4]); % Adjust y-axis range
set(gca, 'FontSize', 28); % Axis font size
hold off;

% Save the figure with proper handling
output_file = fullfile(dir_pics, 'PLV_boxplot_with_significance.png');
print(fig, output_file, '-dpng', '-r300'); % High-resolution save
disp(['Figure saved to: ', output_file]);

%[rho, p] = corr(kuramoto(1:15), kuramoto(31:45) )

% Create the scatter plot
%figure;
%scatter(kuramoto(1:15), kuramoto(31:45), 'filled');

%grid on;
%xlabel('Power Beta');
%ylabel('Power Gamma');
%title('Correlation Between Power Beta and Power Gamma');
