% Define the subjects and conditions
conditions = {'control', 'ses_off'}; % List of conditions {'control', 'ses_off'} {'ses_on', 'ses_off'}
channels = {'C3'}; % Channel indices (e.g., C3 = 8)
% Apply smoothing to the data (e.g., Gaussian smoothing)
sigma = 2;  % Standard deviation for Gaussian smoothing
freq = {'beta'};
range = {'15-30 Hz'};

% Define output folder
out = '/home/daniil/workspase/Power_data/'; % Adjust based on your file directory
dir_pics = '/home/daniil/workspase/Parkinson/Power/pics/'

% Initialize a container for storing the stacked data
data_control = []; % This will hold the vstacked data (Subjects x Timepoints)
data_ses_on = []; % This will hold the vstacked data (Subjects x Timepoints)
data_ses_off = []; % This will hold the vstacked data (Subjects x Timepoints)

% Initialize a cell array to store the labels (if needed for visualization or analysis)
subject_labels = {}; % To store subject names

% Loop through all subjects, conditions, and channels to load the data and vstack
for condIdx = 1:length(conditions)
    if strcmp(conditions{condIdx}, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20','PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'  }; % List of subjects
    else
        assert(strcmp(conditions{condIdx}, 'ses_on') || strcmp(conditions{condIdx}, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19','PD_22','PD_23', 'PD_26', 'PD_28'}; %'PD_22',ses on ses off
    end 
    for subjIdx = 1:length(subjects)    
        % Construct the filename dynamically for each subject, condition, and channel
        filename = sprintf('%sPower_subject_%s_condition_%s_%s.mat', freq{1},subjects{subjIdx}, conditions{condIdx}, channels{1});

        % Load the data
        file_path = fullfile(out, filename);
        data = load(file_path);

        % Extract the broadband gamma power for the subject, condition, and channel
        power = data.mean_power_db;

        %Vstack the data by adding this subject's to the respective condition arrays
        if strcmp(conditions{condIdx}, 'ses_off')                
            data_ses_off = [data_ses_off; power];
        elseif strcmp(conditions{condIdx}, 'ses_on')
            data_ses_on = [data_ses_on; power];
        elseif strcmp(conditions{condIdx}, 'control')
            data_control = [data_control; power];
        end
    end
end

% Perform a paired t-test between the two conditions at each time point

if (strcmp(conditions{1}, 'control') && strcmp(conditions{2}, 'ses_on'))
    [~, p_values] = ttest(data_control, data_ses_on);
elseif (strcmp(conditions{1}, 'control') && strcmp(conditions{2}, 'ses_off'));
    [~, p_values] = ttest(data_control, data_ses_off);
elseif (strcmp(conditions{1}, 'ses_on') && strcmp(conditions{2}, 'ses_off'))
    [~, p_values] = ttest(data_ses_on, data_ses_off);
else
    disp('Check the conditions. May be the order is wrong');
end
% Mark significant time points on the plot (e.g., p < 0.05)
significant_points = find(p_values < 0.05);  % Indices of significant time points

% Plot the smoothed data for each condition
% Initialize the figure
figure;
hold on;

if ~isempty(data_ses_off)
    mean_data_ses_off = mean(data_ses_off, 1);
    mean_data_ses_off_smoothed = imgaussfilt(mean_data_ses_off, sigma);
    data_to_plot = mean_data_ses_off_smoothed;
    plot(mean_data_ses_off_smoothed, 'LineWidth', 2, 'DisplayName', 'ses_off');
end

if ~isempty(data_ses_on)
    mean_data_ses_on = mean(data_ses_on, 1);
    mean_data_ses_on_smoothed = imgaussfilt(mean_data_ses_on, sigma);
    data_to_plot = mean_data_ses_on_smoothed;
    plot(mean_data_ses_on_smoothed, 'LineWidth', 2, 'DisplayName', 'ses_on');
end    

if ~isempty(data_control)
    mean_data_control = mean(data_control, 1);
    mean_data_control_smoothed = imgaussfilt(mean_data_control, sigma);
    data_to_plot = mean_data_control_smoothed;
    plot(mean_data_control_smoothed, 'LineWidth', 2, 'Color', [0.6, 0.3, 0], 'DisplayName', 'control');
end

% Highlight significant points
if ~isempty(significant_points)
    % Create a zero array of the same size as mean_data_ses_on_smoothed
    significant_array = zeros(size(data_to_plot));
    
    % Mark significant points
    significant_array(significant_points) = data_to_plot(significant_points);

    % Overlay asterisks at significant points
    plot(find(significant_array ~= 0), significant_array(significant_array ~= 0), ...
        'k*', 'MarkerSize', 32,  'LineWidth', 4, 'DisplayName', 'p-vals < 0.05');
end

% Add labels, title, and legend
xlabel('Time Points');
ylabel(sprintf('%s Power (dB)', freq{1}))
title('Comparison of Conditions with Significant Regions in ', channels{1});
legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal'); % Move legend to center bottom
set(gca, 'FontSize', 32);

hold off;

% Enlarge the figure
set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

% Optionally save the plot
saveas(gcf, fullfile(dir_pics, sprintf('mean_%s_power_stat_%s_vs_%s_chan_%s.png', ...
    freq{1}, conditions{1}, conditions{2}, channels{1})))
