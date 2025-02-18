
%script to correlate PLVs, Power and cognitive score in PD

data_dir =  '/home/daniil/workspase/Parkinson/Cognitive_measurements/'
dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/nobline_pics/'
conditions = {'ses_off', 'ses_on'};  % Conditions for both scenarios
kuramoto_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';

subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};

kuramoto_filename = fullfile(kuramoto_fpath, ['kuramoto_' conditions{1} '.txt']);
kuramotos_1 = dlmread(kuramoto_filename, '\t');

kuramoto_filename = fullfile(kuramoto_fpath, ['kuramoto_' conditions{2} '.txt']);
kuramotos_2 = dlmread(kuramoto_filename, '\t');

PLV = [kuramotos_1'; kuramotos_2'];

[mmse, naart_int, gender, age, disease_duration_int] = extract_cognitive_behavioral_scores(data_dir, subjects);

% Set the score here: mmse, naart_in, age 
score = [mmse; mmse];
score_label = 'mmse';

if strcmp(score_label, 'gender')
    %TODO
    % Example categorical variables
    genderBinary = zeros(size(gender));
    genderBinary(strcmp(gender, 'm')) = 1;

    % Perform Mann-Whitney U test
    [p, h, stats] = ranksum(kuramotos', genderBinary) % Mann-Whitney U test

    % The chi-squared statistic is in stats.chisq
    
    % Adjust figure font size and save it
    fig = gcf;
    ax = gca;
    ax.FontSize = 90;  % Enlarge font size to 32
    fig.Position = [100, 100, 800, 600];  % Resize figure if necessary
    % Enlarge line width for the plot
    ax.LineWidth = 5;  % Set the line width of the plot
    % Set y-axis limits
    ylim([0.05, 0.09]);
    
    xlabel(sprintf('%s ', score_label), 'FontSize', 52);
    ylabel('PLV', 'FontSize', 52);
    title(sprintf('Mann-Whitney: pval=%.3f, PLV %s-%s', p, score_label, conditions{1}), 'FontSize', 58);

    % Enlarge the figure'
    set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

    % Optionally save the plot
    saveas(ax, fullfile(dir_pics, sprintf('%s_plv_mw_%s.png', ...
    score_label, conditions{1})))

    % Save ANOVA table
    anova_table = anova1(kuramotos', genderBinary);  % If Power and score are your data sets
    save(fullfile(dir_pics, 'anova_table_plv.mat'), 'anova_table');
else
% Calculate correlation
[r, p] = corr(PLV, score, 'Type', 'Spearman');

% Plot the data with a linear regression line

% Plot the first group in magenta
scatter(mmse, kuramotos_1, 100, 'filled', 'MarkerFaceColor', [1, 0, 1]);  % Magenta color
hold on;

% Plot the second group in dark green
scatter(mmse, kuramotos_2, 100, 'filled', 'MarkerFaceColor', [0, 0.5, 0]);  % Dark green color

% Add regression line
coeffs = polyfit(score, Power, 1); % Linear fit
xFit = linspace(min(score), max(score), 100);
yFit = polyval(coeffs, xFit);
plot(xFit, yFit, '-r', 'LineWidth', 4);

% Add legend in the upper-left corner
legend({'OFF medication (Magenta)', 'ON medication (Dark Green)', 'Regression Line'}, ...
       'Location', 'northwest', 'FontSize', 36);

% Customize fonts
fontSize = 32; % Desired font size
xlabel(sprintf('%s ', score_label), 'FontSize', fontSize);
ylabel('PLV', 'FontSize', fontSize);
title(sprintf('Corr: r=%.2f, p=%.3f %s and %s - combined PD ', r, p, freq{1}, score_label), ...
      'FontSize', fontSize + 6);

% Customize tick labels
set(gca, 'FontSize', fontSize);

% Set y-axis limit
ylim([0.05, 0.07]);

% Display grid
grid on;
hold off;


% Enlarge the figure
set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

% Optionally save the plot
saveas(gcf, fullfile(dir_pics, sprintf('%s_%s_corr_%s_%s.png', ...
score_label, freq{1}, conditions{1}, conditions{2})))
end