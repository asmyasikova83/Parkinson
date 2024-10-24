%Script form plotting  mean ERSP difference with statistically significant
%mask (ttest, uncorrected, p-value)
% Define variables
subjects = {'PD_26', 'PD_28', 'PD_3', 'PD_5', 'PD_28', ...
            'PD_6',  'PD_9',  'PD_11','PD_12','PD_13', ...
            'PD_14', 'PD_28', 'PD_19','PD_16','PD_17'}; % List of subjects

conditions = {'ses_on', 'ses_off'};  % Conditions to compare
channelLabel = 'P3'

filepath = '/home/daniil/workspase/SET_PD/ses_on_ses_off/';  % Path to your saved ERSP data

% Initialize data storage
all_ersp_on = [];  % ERSP data for 'ses_on'
all_ersp_off = []; % ERSP data for 'ses_off'

% Load ERSP data for each subject and condition
for subjIdx = 1:length(subjects)
    for condIdx = 1:length(conditions)
        % Construct filename and load dataset
        filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
            subjects{subjIdx}, conditions{condIdx}, channelLabel);
        
        disp(filename);

        if exist(fullfile(filepath, filename), 'file')  % Check if the file exists
            load(fullfile(filepath, filename), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');
            % Store data by condition
            if strcmp(conditions{condIdx}, 'ses_on')
                all_ersp_on{subjIdx} = erspData_subject;  % Store for each subject
            elseif strcmp(conditions{condIdx}, 'ses_off')
                all_ersp_off{subjIdx} = erspData_subject; % Store for 'ses_off'
            end
        else
            warning('File not found: %s', fullfile(filepath, filename));
        end
    end
end

% Preallocate arrays for ERSP data by stacking all trials across subjects
all_ersp_on_stack = [];
all_ersp_off_stack = [];

% Initialize arrays to store mean ERSP for each subject
mean_ersp_on_subjects = [];
mean_ersp_off_subjects = [];

% Loop through each subject and concatenate trials
for subjIdx = 1:length(subjects)
    n_trials_on = length(all_ersp_on{subjIdx});   % Number of trials for 'ses_on' condition
    
    % Stack all 'ses_on' trials for the current subject
    ersp_on_subject = [];  % Initialize temporary storage for 'ses_on'
    for trialIdx = 1:n_trials_on
        % Stack trials along the 4th dimension
        ersp_on_subject = cat(4, ersp_on_subject, all_ersp_on{subjIdx}{trialIdx});
    end

    % Average across trials for the current subject
    mean_ersp_on_subjects(:, :, subjIdx) = mean(ersp_on_subject, 4);  % Average for 'ses_on'

    % Stack all 'ses_off' trials for the current subject
    % Uncomment the following section if you have 'ses_off' trials
    ersp_off_subject = [];  % Initialize temporary storage for 'ses_off'
    n_trials_off = length(all_ersp_off{subjIdx});   % Number of trials for 'ses_off' condition
    for trialIdx = 1:n_trials_off
         ersp_off_subject = cat(4, ersp_off_subject, all_ersp_off{subjIdx}{trialIdx});
    end
    mean_ersp_off_subjects(:, :, subjIdx) = mean(ersp_off_subject, 4);  % Average for 'ses_off'
end

% Compute the mean ERSP across all subjects for each condition
mean_ersp_on = mean(mean_ersp_on_subjects, 3);  % Average across subjects for 'ses_on'
mean_ersp_off = mean(mean_ersp_off_subjects, 3);  % Average for 'ses_off'

% Compute difference between conditions (can also compute ratio)
ersp_diff = mean_ersp_on - mean_ersp_off;

% Statistical test (e.g., paired t-test across subjects for each time-freq point)
[h, pvals] = ttest(mean_ersp_on_subjects,mean_ersp_off_subjects, 'Dim', 3);

disp(size(mean_ersp_on_subjects));
%disp(pvals);

% Visualize the ERSP difference and significant points
figure;

% Plot the difference in ERSP between conditions
subplot(1, 2, 1);
imagesc(times, freqs, ersp_diff);
set(gca, 'YDir', 'normal');
colorbar;
title(['ERSP Difference (ses\_on - ses\_off) - ', channelLabel], 'FontSize', 14);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size



% Create a mask for significant points based on p-values
sig_mask = pvals < 0.05;  % Adjust the threshold as needed (e.g., 0.05 for significance)

% Ensure the mask is in the correct format (logical array)
sig_mask = logical(sig_mask);  % Convert to logical if not already

% Apply the mask to the ERSP difference data
ersp_diff_sig = ersp_diff;  % Start with the original ERSP difference
ersp_diff_sig(~sig_mask) = 0;  % Zero out non-significant points

% Plot the statistically significant ERSP difference
subplot(1, 2, 2);
imagesc(times, freqs, ersp_diff_sig);
set(gca, 'YDir', 'normal');
colorbar;
title(['Significant ERSP Difference (p < 0.05) - ', channelLabel], 'FontSize', 14);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size