
%script for plotting timecourses
out = '/home/daniil/workspase/Parkinson/Power/pics/';
data_dir =  '/home/daniil/workspase/Power_data/'
conditions = {'ses_off', 'ses_on', 'control'};  % Conditions for both scenarios
channelLabel = {'C3'}; % Channel indices (e.g., C3 = 8)
freq = {'broadbandgamma'};
range = {'50-150 Hz'};
% Initialize a figure for plotting
figure;

% Initialize a container for storing beta power data for both conditions
power_ses_off = [];
power_ses_on = [];
sigma = 2;  % Standard deviation for Gaussian smoothing

% Loop over each condition and load data
for condIdx = 1:length(conditions)
    % Construct the filename to load based on the condition and channel
    filename_overall = sprintf('mean_%s_power_%s_db_chan_%s.mat', freq{1}, conditions{condIdx}, channelLabel{1});

    % Load the data from the .mat file
    data = load(fullfile(data_dir, filename_overall));  % Load the saved .mat file

    % Extract the mean_beta_power_db_overall from the loaded data
    mean_power_db_overall = data.mean_power_db_overall;

    % Apply smoothing to the data (e.g., Gaussian smoothing)
    mean_power_db_smoothed = imgaussfilt(mean_power_db_overall, sigma);

    % Plot the smoothed data for this condition
    plot(mean_power_db_smoothed, 'LineWidth', 2);
    hold on;  % Hold to overlay the next condition's plot
end

% Set figure size (width, height) in pixels
set(gcf, 'Position', [400, 400, 1600, 1000]); % Adjust as needed

% Customize the plot appearance
title([conditions{1}, ' ', conditions{2}, ' ',conditions{3}, ' ', channelLabel{1}], 'FontSize', 30)
ylabel([freq{1}, ' power (', range{1}, ')'], 'FontSize', 30);
xlabel('Time (ms)', 'FontSize', 30);
legend(conditions, 'FontSize', 14); % Add legend for both conditions
grid on;

% Optionally save the plot
saveas(gcf, fullfile(out, sprintf('mean_%s_power_overall_%s_vs_%s_vs_%s_chan_%s.png', freq{1}, conditions{1}, conditions{2}, conditions{3}, channelLabel{1})));
