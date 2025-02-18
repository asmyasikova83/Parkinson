% Script to retrieve significant PLVs, do stat tests and visualisation
addpath('/home/daniil/workspase/Parkinson/Power/utils');
addpath('/home/daniil/workspase/Parkinson/GCFD/gcfd/task/scripts');
%savePath = '/home/daniil/workspase/PLV_report/beta13_30_gamma50_150_whole_nobline/';
%fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_whole_nobline/';

savePath = '/home/daniil/workspase/PLV_report/beta13_30_gamma50_150_p_q_motor_nobline/';
fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';
loc = fpath(end - 13: end-1);

conditions = {'control', 'ses_off', 'ses_on'};

% Initialize an empty array for concatenation
PLVs = [];

for condIdx = 1:length(conditions)
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

    % Call extract_kuramotos to get the reordered PLVs and other outputs
    [combinedKuramotoArray, subject_less_kur, reordered_kuramoto, kuramoto_ses_on_signif, unique_subjects] = extract_kuramotos(fpath, subjects, condition);
    
    % Concatenate reordered_kuramoto vertically (vstack) into PLVs
    PLVs = [PLVs, reordered_kuramoto(:)];
end

mean(PLVs)
std(PLVs)
% Assuming x is shorter than y
%kuramoto_ses_on_signif_interp = interp1(1:length(kuramoto_ses_on_signif), kuramoto_ses_on_signif, linspace(1, length(kuramoto_ses_on_signif), length(kuramoto_control_signif)), 'linear');

% Calculate Spearman correlation
%[rho, p_corr] = corr(kuramoto_ses_on_signif_interp', kuramoto_control_signif, 'Type', 'Spearman');
[rho, p_corr] = corr(PLVs(:, 1), PLVs(:, 2), 'Type', 'Spearman');

% Plot both vectors as dots in the same plot
figure;

% Set figure size (width, height) in pixels
set(gcf, 'Position', [400, 400, 1600, 1000]); % Adjust as needed

%plot(kuramoto_control_signif, '.', 'MarkerSize', 44, 'Color', [0 0 0], 'DisplayName', 'PLVs control'); %ses off [0 0.6 0]
plot(PLVs(:,1), '.', 'MarkerSize', 44, 'Color', [0 0 0], 'DisplayName', 'PLVs control'); %ses off [0 0.6 0]
hold on;
%plot(kuramoto_ses_on_signif, '.', 'MarkerSize', 44, 'Color', [0.5 0 0.5], 'DisplayName', 'PLVs ses on');
plot(PLVs(:,2), '.', 'MarkerSize', 44, 'Color', [1 0 0], 'DisplayName', 'PLVs ses off'); %ses off [0 0.6 0]
hold on;
plot(PLVs(:,3), '.', 'MarkerSize', 44, 'Color', [0.5 0 0.5], 'DisplayName', 'PLVs ses on'); %ses off [0 0.4 0]

xlabel('Group');
ylabel('PLVs');
legend('show');
title_text = 'Beta-gamma phase synchrony';
title(title_text, 'FontSize', 50, 'FontWeight', 'bold');
grid on;

% Adjust axis properties

set(gca, 'FontSize', 42); % Set font size for axis numbers and ticks
% Set labels, title, and font sizes
xlabel('Index', 'FontSize', 40); % Enlarge X-axis label font
ylabel('PLVs', 'FontSize', 40); % Enlarge Y-axis label font
%title('PLVs control vs ses off with Correlation: '); % Enlarge title font

% Customize legend
legend('show', 'FontSize', 42);

% Adjust axis properties
set(gca, 'FontSize', 32); % Set font size for axis numbers and ticks
grid on;
hold off;

baseFileName = 'PLVs_dots';
% Check if the directory name contains "motor_nobline"
saveFileName = [baseFileName, '_', loc, '.png']; % Regular file name with location

% Save the figure
saveas(gcf, fullfile(savePath, saveFileName));


% Reshape data into a single column with corresponding group labels
data = PLVs(:); % Combine all columns into a single vector
% Create group labels for each condition
group_labels = [ones(size(PLVs(:,1)));       % Group 1 for first condition
                2*ones(size(PLVs(:,2)));    % Group 2 for second condition
                3*ones(size(PLVs(:,3)))];   % Group 3 for third condition


% Perform Kruskal-Wallis test
[p_val, tbl, stats] = kruskalwallis(data, group_labels, 'off')

% Display p-value
disp(['p-value: ', num2str(p_val)]);
c = multcompare(stats, 'CType', 'bonferroni'); % Bonferroni correction


% Create a new figure
figure;

% Set figure size (width, height) in pixels
set(gcf, 'Position', [400, 400, 1600, 1000]); % Adjust as needed

data = PLVs;

% Generate group dynamically
group = [];
num_rows = length(PLVs(:, 1)); % Number of rows for the current condition

for i = 1:numel(conditions)    
    group = [group; repmat(conditions(i), num_rows, 1)];
end

% Define custom colors
custom_colors = [0 0 0;   % Green for control
                 1 0 0;     % Red for ses_off
                 0.5 0 0.5]; % Purple for ses_on

% Create a single boxplot
figure;
boxplot(data, group, 'Colors', custom_colors, 'Widths', 0.5); % Combine the boxplots
title('Comparison of Groups', 'FontSize', 22); % Set title
xlabel('Groups', 'FontSize', 20); % X-axis label
ylabel('PLVs', 'FontSize', 20); % Y-axis label
%ylim([0 0.3]); % Set y-axis limits
set(gca, 'FontSize', 22); % Adjust axes font size
grid on; % Show grid

% Make boxplot lines thicker
set(findobj(gca, 'Tag', 'Box'), 'LineWidth', 3); % Adjust box line width
set(findobj(gca, 'Tag', 'Median'), 'LineWidth', 3); % Adjust median line width
set(findobj(gca, 'Tag', 'Whisker'), 'LineWidth', 2); % Adjust whisker line width

grid on; % Show grid

baseFileName = 'PLVs';
saveFileName = [baseFileName, '_', loc, '.png']; % Regular file name with location

% Save the figure
saveas(gcf, fullfile(savePath, saveFileName));



