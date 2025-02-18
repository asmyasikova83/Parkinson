%script to correlate PLVs, Power and cognitive score in PD

dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/nobline_pics/'
% Set the directory containing the data
data_dir = '/home/daniil/workspase/Power_data/nobline/52_120/'
dir_path = '/home/daniil/workspase/Parkinson/Cognitive_measurements/';
freq = {'broadbandgamma'};
%range = {'30-60 Hz'};
channels = {'C3', 'C4'};
conditions = {'ses_on'};  % Conditions for both scenarios

% Initialize a structure to store power data
dataStruct = struct();

% Loop through all conditions, channels, and subjects
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

    % Loop through all subjects
    for subjIdx = 1:length(subjects)
        subject = subjects{subjIdx};

        % Loop through all channels
        for chanIdx = 1:length(channels)
            channel = channels{chanIdx};

            for frIdx = 1:length(freq)
                fr = freq(frIdx);

                % Construct the filename dynamically
                filename = sprintf('%sPower_subject_%s_condition_%s.mat', fr{1}, subject, condition);
                % Load tdisp(filename);he data
                file_path = fullfile(data_dir, filename);
                if exist(file_path, 'file')
                    data = load(file_path);
                    power = data.average_beta_power_subject; % Extract the power data
                    % Store the data in the nested structure
                    dataStruct.(condition).(subject).(fr{1}) = power;
                else
                    fprintf('File not found: %s\n', file_path);
                end
            end
        end
    end
end
addpath('/home/daniil/workspase/Parkinson/Power/utils');
Power = save_mean_power(data_dir, dataStruct, subjects, freq, conditions{1});

[mmse, naart_int, gender, age, disease_duration_int] = extract_cognitive_behavioral_scores(dir_path, subjects);

% Set the score here: mmse, naart_in, age 
score = mmse;
score_label = 'mmse';

if strcmp(score_label, 'Gender')
    % Example categorical variables

    % Kruskal-Wallis test
    [pval, tbl, stats] = kruskalwallis(Power, score);

    % The chi-squared statistic is in stats.chisq
    chi2stat = tbl{2, 5};  % The chi-squared value is in the 2nd row, 5th column
    disp(chi2stat);
    
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
    title(sprintf('Kruskall-Wallis: pval=%.3f, %s %s-%s', pval, freq{1}, score_label, conditions{1}), 'FontSize', 58);

    % Optionally save the plot
    saveas(ax, fullfile(dir_pics, sprintf('%s_power_kruskal_%s.png', ...
    score_label, conditions{1})))

    % Save ANOVA table
    anova_table = anova1(Power, score);  % If Power and score are your data sets
    save(fullfile(dir_pics, 'anova_table.mat'), 'anova_table');
else
    [r, p] = corr(Power, score)

    % Plot the data with a linear regression line
    figure;
    scatter(score, Power, 100, 'filled','MarkerFaceColor', [0, 0, 0]);  % Black color
    hold on;

    % Add regression line
    coeffs = polyfit(score, Power, 1); % Linear fit
    xFit = linspace(min(score), max(score), 100);
    yFit = polyval(coeffs, xFit);
    plot(xFit, yFit, '-r', 'LineWidth', 4);

    % Customize fonts
    fontSize = 32; % Desired font size
    xlabel(sprintf('%s ', score_label), 'FontSize', fontSize);
    ylabel(sprintf(' %s log power ', freq{1}), 'FontSize', fontSize);
    title(sprintf('Correlation: r=%.2f, p=%.2f %s and %s - %s ', r, p, freq{1}, score_label, conditions{1}), 'FontSize', fontSize + 6);

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
    saveas(gcf, fullfile(dir_pics, sprintf('%s_%s_corr_%s.png', ...
    score_label, freq{1}, conditions{1})))
end

