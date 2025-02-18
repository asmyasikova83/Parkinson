%script to correlate PLVs, Power and cognitive score in PD

dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/nobline_pics/'
% Set the directory containing the data
data_dir = '/home/daniil/workspase/Power_data/nobline/52_120/'
dir_path = '/home/daniil/workspase/Parkinson/Cognitive_measurements/';
freq = {'beta'};
%range = {'30-60 Hz'};

conditions = {'ses_off', 'ses_on'};  % Conditions for both scenarios

power_beta_filename = fullfile(data_dir, ['power_' freq{1} '_' conditions{1} '.txt']);
Power_1 = dlmread(power_beta_filename, '\t');

power_beta_filename = fullfile(data_dir, ['power_' freq{1} '_' conditions{2} '.txt']);
Power_2 = dlmread(power_beta_filename, '\t');

Power = [Power_1; Power_2];
[mmse, naart_int, gender, age, disease_duration_int] = extract_cognitive_behavioral_scores(dir_path, subjects);

% Set the score here: mmse, naart_in, age 
score = [mmse; mmse];
score_label = 'mmse';

if strcmp(score_label, 'Gender')
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
    ax.FontSize = 58;  % Enlarge font size to 32
    fig.Position = [100, 100, 800, 600];  % Resize figure if necessary
    % Enlarge line width for the plot
    ax.LineWidth = 5;  % Set the line width of the plot
    % Set y-axis limits
    %ylim([-0.9, -0.1]);  % Set the y-axis limits to -0.09 and -0.02
    
    % Add title
    title(sprintf('Mann-Whitney: pval=%.3f, %s %s-%s', p, freq{1}, score_label, conditions{1}), 'FontSize', 58);

    % Optionally save the plot
    saveas(ax, fullfile(dir_pics, sprintf('%s_power_kruskal_%s.png', ...
    score_label, conditions{1})))

    % Save ANOVA table
    anova_table = anova1(Power, score);  % If Power and score are your data sets
    save(fullfile(dir_pics, 'anova_table.mat'), 'anova_table');
else
    [r, p] = corr(Power, score, 'Type','Spearman')
    %[r, p] = corr(Power, score)

    % Plot the data with a linear regression line
    % Plot the first group in red
    scatter(mmse, Power_1, 100, 'filled', 'MarkerFaceColor', [1, 0, 1]);  % 
    hold on;

    % Plot the second group in blue
    scatter(mmse, Power_2, 100, 'filled', 'MarkerFaceColor', [0, 0.5, 0]);  % 

    % Add regression line
    coeffs = polyfit(score, Power, 1); % Linear fit
    xFit = linspace(min(score), max(score), 100);
    yFit = polyval(coeffs, xFit);
    plot(xFit, yFit, '-r', 'LineWidth', 4);

    % Customize fonts
    fontSize = 32; % Desired font size
    xlabel(sprintf('%s ', score_label), 'FontSize', fontSize);
    ylabel(sprintf(' %s log power ', freq{1}), 'FontSize', fontSize);
    title(sprintf('Corr: r=%.2f, p=%.4f %s and %s - %s %s ', r, p, freq{1}, score_label, conditions{1}, conditions{2}), 'FontSize', fontSize + 6);

    %Customize tick labels
    set(gca, 'FontSize', fontSize);

    % Set y-axis limit
    %ylim([-2.0, 0.5]);

    % Display grid
    grid on;
    hold off;

    % Enlarge the figure
    set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

    % Optionally save the plot
    saveas(gcf, fullfile(dir_pics, sprintf('%s_%s_corr_%s_%s.png', ...
    score_label, freq{1}, conditions{1}, conditions{2})))
end

