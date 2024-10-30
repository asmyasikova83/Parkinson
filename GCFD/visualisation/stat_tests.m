% Script to retrieve significant PLVs, do stat tests and visualisation

pattern_p_control = '/home/daniil/workspase/data_pd_aggr_beta_gamma/control_pattern_p.res'
pattern_q_control = '/home/daniil/workspase/data_pd_aggr_beta_gamma/control_pattern_q.res'
ku_control = '/home/daniil/workspase/data_pd_aggr_beta_gamma/control_kuramoto.res'
p_val_p_control = '/home/daniil/workspase/data_pd_aggr_beta_gamma/control_pval_p.res'
p_val_q_control = '/home/daniil/workspase/data_pd_aggr_beta_gamma/control_pval_q.res'

pattern_p_ses_on = '/home/daniil/workspase/data_pd_aggr_beta_gamma/ses_on_pattern_p.res'
pattern_q_ses_on = '/home/daniil/workspase/data_pd_aggr_beta_gamma/ses_on_pattern_q.res'
ku_ses_on = '/home/daniil/workspase/data_pd_aggr_beta_gamma/ses_on_kuramoto.res'
p_val_p_ses_on = '/home/daniil/workspase/data_pd_aggr_beta_gamma/ses_on_pval_p.res'
p_val_q_ses_on = '/home/daniil/workspase/data_pd_aggr_beta_gamma/ses_on_pval_q.res'

% Function to read the content of each file
function data = read_data(file_path)
    % Open the file
    fid = fopen(file_path, 'r');
    % Read each line into a cell array
    data = textscan(fid, '%s', 'Delimiter', '\n');
    % Close the file
    fclose(fid);
    % Convert cell array to a matrix for easy access
    data = data{1};
end

% Read data from each file
pattern_p_control = read_data(pattern_p_control);
pattern_q_control = read_data(pattern_q_control);
kuramoto_control = read_data(ku_control);
p_val_p_control = read_data(p_val_p_control);
p_val_q_control = read_data(p_val_q_control);

% Read data from each file
pattern_p_ses_on = read_data(pattern_p_ses_on);
pattern_q_ses_on = read_data(pattern_q_ses_on);
kuramoto_ses_on = read_data(ku_ses_on);
p_val_p_ses_on = read_data(p_val_p_ses_on);
p_val_q_ses_on = read_data(p_val_q_ses_on);

% Convert the cell array to a numeric array
kuramoto_numeric_control = str2double(kuramoto_control);
kuramoto_numeric_ses_on = str2double(kuramoto_ses_on);
p_val_p_numeric_control = str2double(p_val_p_control);
p_val_q_numeric_control = str2double(p_val_q_control);
p_val_p_numeric_ses_on = str2double(p_val_p_ses_on);
p_val_q_numeric_ses_on = str2double(p_val_q_ses_on);

%Remove insignificant data
chdir('/home/daniil/workspase/gcfd/task/scripts/')
[pattern_q_control_signif] = rm_nonsign_pat(pattern_q_control, p_val_p_numeric_control, p_val_q_numeric_control)
[kuramoto_control_signif] = rm_nonsign_pat(kuramoto_numeric_control, p_val_p_numeric_control, p_val_q_numeric_control)
assert(size(kuramoto_control_signif,1) == size(pattern_q_control_signif,1));

[pattern_q_ses_on_signif] = rm_nonsign_pat(pattern_q_ses_on, p_val_p_numeric_ses_on, p_val_q_numeric_ses_on)
[kuramoto_ses_on_signif] = rm_nonsign_pat(kuramoto_numeric_ses_on, p_val_p_numeric_ses_on, p_val_q_numeric_ses_on)
assert(size(kuramoto_ses_on_signif,1) == size(pattern_q_ses_on_signif,1));

% Assuming x is shorter than y
kuramoto_ses_on_signif_interp = interp1(1:length(kuramoto_ses_on_signif), kuramoto_ses_on_signif, linspace(1, length(kuramoto_ses_on_signif), length(kuramoto_control_signif)), 'linear');

% Calculate Spearman correlation
rho = corr(kuramoto_ses_on_signif_interp', kuramoto_control_signif, 'Type', 'Spearman');

% Display result
disp(['Spearman correlation coefficient: ', num2str(rho)]);

% Plot the vectors
figure;

% Plot both vectors as dots in the same plot
figure;
plot(kuramoto_control_signif, '.', 'MarkerSize', 25, 'DisplayName', 'PLVs control');
hold on;
plot(kuramoto_ses_on_signif, '.', 'MarkerSize', 25, 'DisplayName', 'PLVs ses on');
xlabel('Index');
ylabel('Values');
title(['PLVs control and PLVs ses on with Correlation: ', num2str(rho)]);
legend('show');
grid on;

% Adjust axis properties
set(gca, 'FontSize', 32); % Set font size for axis numbers and ticks
% Set labels, title, and font sizes
xlabel('Index', 'FontSize', 30); % Enlarge X-axis label font
ylabel('Values', 'FontSize', 30); % Enlarge Y-axis label font
title(['PLVs control and PLVs ses on with Correlation: ', num2str(rho)], 'FontSize', 34); % Enlarge title font

% Customize legend
legend('show', 'FontSize', 32);

% Adjust axis properties
set(gca, 'FontSize', 32); % Set font size for axis numbers and ticks
grid on;
hold off;

% Perform the independent t-test
[h, p, ci, stats] = ttest2(kuramoto_ses_on_signif, kuramoto_control_signif);

% Create a new figure
figure;

% Create the first subplot for the control group
ax1 = subplot(1, 2, 1); % 1 row, 2 columns, first subplot
boxplot(kuramoto_control_signif, 'Colors', 'k', 'Widths', 3.5); % Create the boxplot
title('Control Group', 'FontSize', 32); % Title for Control Group
xlabel('Control Group', 'FontSize', 30); % X-axis label
ylabel('Values', 'FontSize', 30); % Y-axis label
ax1.FontSize = 32; % Enlarge axes font size
grid on; % Show grid

% Set the line width for the boxplot elements in the control group
set(findobj(ax1, 'Tag', 'Box'), 'LineWidth', 4); % Adjust box line width
set(findobj(ax1, 'Tag', 'Median'), 'LineWidth', 4); % Adjust median line width
set(findobj(ax1, 'Tag', 'Whisker'), 'LineWidth', 10); % Adjust whisker line width

% Create the second subplot for the SES On group
ax2 = subplot(1, 2, 2); % 1 row, 2 columns, second subplot
boxplot(kuramoto_ses_on_signif, 'Colors', 'r', 'Widths', 3.5); % Create the boxplot
title('SES On Group', 'FontSize', 32); % Title for SES On Group
xlabel('SES On Group', 'FontSize', 30); % X-axis label
ylabel('Values', 'FontSize', 30); % Y-axis label
ax2.FontSize = 32; % Enlarge axes font size
grid on; % Show grid

% Set the line width for the boxplot elements in the SES On group
set(findobj(ax2, 'Tag', 'Box'), 'LineWidth', 4); % Adjust box line width
set(findobj(ax2, 'Tag', 'Median'), 'LineWidth', 4); % Adjust median line width

% Set equal axis range
yLimits = [min([kuramoto_control_signif; kuramoto_ses_on_signif]), ...
           max([kuramoto_control_signif; kuramoto_ses_on_signif])];
ax1.YLim = yLimits; % Set y-limits for Control Group
ax2.YLim = yLimits; % Set y-limits for SES On Group

% Equalize subplot sizes
set(ax1, 'Position', [0.1, 0.1, 0.4, 0.8]); % Adjust position for Control Group
set(ax2, 'Position', [0.55, 0.1, 0.4, 0.8]); % Adjust position for SES On Group

% Add overall title
sgtitle('Comparison of Kuramoto Data Control vs SES On', 'FontSize', 34); % Overall title with enlarged font

