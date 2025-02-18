
%script for plotting timecourses

power_fpath =  '/home/daniil/workspase/Power_data/nobline/52_120/'
data_cognitive_dir =  '/home/daniil/workspase/Parkinson/Cognitive_measurements/'
conditions = {'control',  'ses_off', 'ses_on'};  % Conditions for both scenarios
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)
freq = {'beta', 'broadbandgamma'};
dir_pics = '/home/daniil/workspase/Power_data/pics_article/'
kuramoto_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_whole_nobline/';

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

    power_beta_filename = fullfile(power_fpath, ['power_' freq{1} '_' condition '.txt']);
    p_b = dlmread(power_beta_filename, '\t');
    power_beta = [power_beta; p_b];

    power_gamma_filename = fullfile(power_fpath, ['power_' freq{2} '_' condition '.txt']);
    p_g = dlmread(power_gamma_filename, '\t');
    power_gamma = [power_gamma; p_g];

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

%collinearity
% Compute VIFs for fixed effects in a model
% Define the categorical data
% Define the categorical data
dumconds = {'control', 'control', 'control', 'control', 'control', 'control', ...
         'control', 'control', 'control', 'control', 'control', 'control', ...
         'control', 'control', 'control', 'ses_off', 'ses_off', 'ses_off', ...
         'ses_off', 'ses_off', 'ses_off', 'ses_off', 'ses_off', 'ses_off', ...
         'ses_off', 'ses_off', 'ses_off', 'ses_off', 'ses_off', 'ses_off', ...
         'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', ...
         'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', 'ses_on', ...
         'ses_on'};

% Convert the categorical data to a categorical type
x1 = categorical(dumconds);

% Create dummy variables from the categorical variable
X = dummyvar(x1');  % Create dummy variables (will include a reference category)

% Remove the first column (the reference category, 'control' in this case)
X = X(:, 2:end);  % Keep only the remaining dummy variables

% Compute the correlation matrix of the dummy variables
corr_matrix = corr(X);

% Compute the Variance Inflation Factors (VIFs)
vif = diag(inv(corr_matrix));  % VIF for each dummy variable

% Display results
disp('Correlation matrix:');
disp(corr_matrix);

disp('Variance Inflation Factors (VIFs):');
disp(vif);

%one group of subjects in control conditiin, one PD group in OFF and ON 
SubjectID = [1:15, repmat(16:30, 1, 2)]';

genderBinary = zeros(size(gender));
genderBinary(strcmp(gender, 'm')) = 1;

%Model
% Create a dataset/table for convenience
%, PowerArray, genderBinary,

T = table(kuramoto, conds,  SubjectID, 'VariableNames', {'y','x1', 'Subject'});
%T = table(genderBinary, averaged_kuramoto, SubjectID, 'VariableNames', {'y','x1','Subject'});
% Define a model formula (using Wilkinson notation)
% e.g. "y ~ x1 + x2 + (1|Subject)" includes a random intercept for Subject.
%lme = fitglme(T, 'y ~ x1 + x2 + x3 + (1|Subject)', ...
%              'Distribution', 'binomial', 'Link', 'logit');
lme = fitglme(T, 'y ~ x1 + (1|Subject)');

% Display results
disp(lme);

% Perform ANOVA (use 'residual' or 'none' for DFMethod)
tbl = anova(lme, 'DFMethod', 'residual');

% Display ANOVA table
disp(tbl);

% Assuming 'lme' is your fitted linear mixed-effects model and 'T' is your data table

% Get the actual response values from the table
y = T.y;  % Replace 'y' with the actual response variable name in your table

% Get the predicted values from the fitted model (only fixed effects)
y_hat_fixed = predict(lme);

% Calculate marginal R-squared:
% Fit a model with only the fixed effects (exclude random effects)
lme_fixed = fitlme(T, 'y ~ x1');  % Replace 'x1' with your actual fixed effect predictor(s)

% Get the predicted values from the fixed-only model
y_hat_fixed_only = predict(lme_fixed);

% Calculate residuals for the fixed-only model
residuals_fixed = y - y_hat_fixed_only;

% Total sum of squares (TSS) for the original model
TSS = sum((y - mean(y)).^2);

% Residual sum of squares (RSS) for the fixed-only model
RSS_fixed = sum(residuals_fixed.^2);

% Marginal R-squared (only fixed effects)
r_squared_marginal = 1 - (RSS_fixed / TSS);
disp(['Marginal R-squared: ', num2str(r_squared_marginal)]);

% Now compute conditional R-squared (which you already did):

% Get the random effects from the model
re = randomEffects(lme);

% If random effects are returned as an array, convert it to a table
if istable(re)
    random_effects = re;
else
    random_effects = table(re, 'VariableNames', {'RandomEffect'});
    % Create a new column 'Subject' with values from 1 to 30
    random_effects.Subject = (1:height(random_effects))';  % Adjust to match the number of rows in 'random_effects'
end

% Ensure that the random effects are aligned with the rows in the original table
[~, idx] = ismember(T.Subject, random_effects.Subject);  % Match the 'Subject' values

% Add the random effects to the predictions (full model)
y_hat_random = y_hat_fixed + random_effects.RandomEffect(idx);

% Calculate residuals for the full model (with both fixed and random effects)
residuals_full = y - y_hat_random;

% Residual sum of squares (RSS) for the full model
RSS_full = sum(residuals_full.^2);

% Conditional R-squared (both fixed and random effects)
r_squared_conditional = 1 - (RSS_full / TSS);
disp(['Conditional R-squared: ', num2str(r_squared_conditional)]);

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

p_fdr_secondary = mafdr(all_pvalues, 'BHFDR', true)

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
ylabel('PLV');
xlabel('Conditions');
ylim([0.05 0.115]); % Adjust y-axis range
%ylim([-0.6 0.3]); % Adjust gamma y-axis range
%ylim([0.0 2.3]); % Adjust y-axis range
set(gca, 'FontSize', 28); % Axis font size
hold off;

% Save the figure with proper handling
output_file = fullfile(dir_pics, 'Power_boxplot_with_significance.png');
print(fig, output_file, '-dpng', '-r300'); % High-resolution save
disp(['Figure saved to: ', output_file]);