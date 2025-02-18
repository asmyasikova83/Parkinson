
%script to correlate PLVs, Power and cognitive score in PD

data_dir =  '/home/daniil/workspase/Parkinson/Cognitive_measurements/'
dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/nobline_pics/'
conditions = {'control'};  % Conditions for both scenarios
kuramoto_fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';


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
end

kuramoto_filename = fullfile(kuramoto_fpath, ['kuramoto_' conditions{1} '.txt']);
kuramotos = dlmread(kuramoto_filename, '\t');

[mmse, naart_int, gender, age, disease_duration_int] = extract_cognitive_behavioral_scores(data_dir, subjects);

% Set the score here: mmse, naart_in, age 
score = mmse;
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
    [r, p] = corr(kuramotos', score)

    % Plot the data with a linear regression line
    figure;
    scatter(score, kuramotos, 100, 'filled','MarkerFaceColor', [0, 0, 0]);  % Black color
    hold on;

    % Add regression line
    coeffs = polyfit(score, kuramotos', 1); % Linear fit
    xFit = linspace(min(score), max(score), 100);
    yFit = polyval(coeffs, xFit);
    plot(xFit, yFit, '-r', 'LineWidth', 4);

    % Customize fonts
    fontSize = 32; % Desired font size
    xlabel(sprintf('%s ', score_label), 'FontSize', fontSize);
    ylabel('PLV', 'FontSize', fontSize);
    title(sprintf('Correlation: r=%.2f, p=%.2f PLV and %s - %s ', r, p, score_label, conditions{1}), 'FontSize', fontSize + 6);

    %Customize tick labels
    set(gca, 'FontSize', fontSize);

    % Set y-axis limit
    ylim([0.05, 0.09]);

    % Display grid
    grid on;
    hold off;

    % Enlarge the figure
    set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

    % Optionally save the plot
    saveas(gcf, fullfile(dir_pics, sprintf('%s_plv_corr_%s.png', ...
    score_label, conditions{1})))
end