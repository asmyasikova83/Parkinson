 %Script form plotting  mean ERSP difference with statistically significant
%mask (ttest, uncorrected, p-value)
% Define variables
subjects_off = {'PD_26', 'PD_28', 'PD_3', 'PD_5', 'PD_28', ...
            'PD_6',  'PD_9',  'PD_11','PD_12','PD_13', ...
            'PD_14', 'PD_28', 'PD_19','PD_16','PD_17'}; % List of subjects

%subjects_off = {'PD_26'};

subjects_control = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
                   'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', ...
                   'PD_32', 'PD_33'}
%subjects_control = {'PD_2'};

conditions = {'ses_off', 'ses_on'};  % Conditions to compare
% Specify channels of interest
channels = {'C3', 'C4'};  % Channels to average

filepath = '/home/daniil/workspase/SET_PD_nobline/single_trial/ses_off_ses_on_control/';  % Path to your saved ERSP data
out = '/home/daniil/workspase/Parkinson/ERSP/nobline_pics/';

% Initialize data storage
all_ersp_control = [];
all_ersp_off = [];

% Loop through channels and load data for each condition
for chIdx = 1:length(channels)
    channelLabel = channels{chIdx};

    % Load ERSP data for each subject and condition
    for subjIdx = 1:length(subjects_control)
        filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', subjects_control{subjIdx}, 'control', channelLabel);
        disp(filename);

        if exist(fullfile(filepath, filename), 'file')
            load(fullfile(filepath, filename), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');
            all_ersp_control{chIdx, subjIdx} = erspData_subject;
        else
            warning('File not found: %s', fullfile(filepath, filename));
        end
    end

    for subjIdx = 1:length(subjects_off)
        filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', subjects_off{subjIdx}, 'ses_on', channelLabel);
        disp(filename);

        if exist(fullfile(filepath, filename), 'file')
            load(fullfile(filepath, filename), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');
            all_ersp_off{chIdx, subjIdx} = erspData_subject;
        else
            warning('File not found: %s', fullfile(filepath, filename));
        end
    end
end

% Initialize arrays for averaged ERSP across channels
mean_ersp_control_subjects = [];
mean_ersp_off_subjects = [];

% Process data for each subject
for subjIdx = 1:length(subjects_control)
    % Process 'control' condition
    ersp_control_subject = [];
    for chIdx = 1:length(channels)
        n_trials_control = length(all_ersp_control{chIdx, subjIdx});
        for trialIdx = 1:n_trials_control
            ersp_control_subject = cat(4, ersp_control_subject, all_ersp_control{chIdx, subjIdx}{trialIdx});
        end
    end
    % Average over trials and channels
    mean_ersp_control_subjects(:, :, subjIdx) = mean(mean(ersp_control_subject, 4), 3);
end

for subjIdx = 1:length(subjects_off)
    % Process 'ses_off' condition
    ersp_off_subject = [];
    for chIdx = 1:length(channels)
        n_trials_off = length(all_ersp_off{chIdx, subjIdx});
        for trialIdx = 1:n_trials_off
            ersp_off_subject = cat(4, ersp_off_subject, all_ersp_off{chIdx, subjIdx}{trialIdx});
        end
    end
    % Average over trials and channels
    mean_ersp_off_subjects(:, :, subjIdx) = mean(mean(ersp_off_subject, 4), 3);
end

% Compute the mean ERSP across subjects for each condition
mean_ersp_control = mean(mean_ersp_control_subjects, 3);
mean_ersp_off = mean(mean_ersp_off_subjects, 3);

% Compute difference between conditions
ersp_diff = mean_ersp_off - mean_ersp_control;

% Perform statistical testing
[h, pvals] = ttest(mean_ersp_control_subjects, mean_ersp_off_subjects, 'Dim', 3);

% Select frequency range of interest
freq_range = [3, 150];
freq_indices = freqs >= freq_range(1) & freqs <= freq_range(2);

% Extract data within the specified frequency range
freqs_selected = freqs(freq_indices);
ersp_diff_selected = ersp_diff(freq_indices, :);

% Mask significant points
pvals_selected = pvals(freq_indices, :);
sig_mask = pvals_selected < 0.05;

% Create the figure and assign it to 'figure_handle'
figure_handle = figure;  % Create and store the figure handle

% Set the figure size (width and height in pixels)
set(figure_handle, 'Position', [200, 200, 1200, 800]);  % [x, y, width, height]

% Plot the ERSP Difference with Significant Mask
imagesc(times, freqs_selected, ersp_diff_selected);
set(gca, 'YDir', 'normal');
hold on;
contour(times, freqs_selected, sig_mask, 1, 'LineColor', 'k', 'LineWidth', 2);
hold off;

% Add labels, title, and color bar
title(['ERSP: ' conditions{1} '-' conditions{2} ' (C3&C4 Aver, p < 0.05)'], 'FontSize', 14);

xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);
caxis([-0.2 0.2]);
set(gca, 'FontSize', 32);
c = colorbar;
set(c, 'FontSize', 30);
grid on;

% Define the output filename
output_filename = fullfile(out, ['Ersp_diff_' conditions{1} '_vs_' conditions{2} '_C3_C4_averaged.png']);


% Save the figure
saveas(figure_handle, output_filename);  % Save the entire figure