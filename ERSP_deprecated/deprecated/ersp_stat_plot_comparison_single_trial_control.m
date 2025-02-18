 %Script form plotting  mean ERSP difference with statistically significant
%mask (ttest, uncorrected, p-value)
% Define variables
subjects_off = {'PD_26', 'PD_28', 'PD_3', 'PD_5', 'PD_28', ...
            'PD_6',  'PD_9',  'PD_11','PD_12','PD_13', ...
            'PD_14', 'PD_28', 'PD_19','PD_16','PD_17'}; % List of subjects

subjects_control = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
                   'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', ...
                   'PD_32', 'PD_33'}

conditions = {'ses_off', 'control'};  % Conditions to compare
channelLabel = 'C3'

filepath = '/home/daniil/workspase/SET_PD/ses_off_ses_on_control/';  % Path to your saved ERSP data

% Initialize data storage
all_ersp_control = [];  % ERSP data for 'ses_on'
all_ersp_off = []; % ERSP data for 'ses_off'

% Load ERSP data for each subject and condition
for subjIdx = 1:length(subjects_control)
    % Construct filename and load dataset
    filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
    subjects_control{subjIdx}, 'control', channelLabel);
        
    disp(filename);

    if exist(fullfile(filepath, filename), 'file')  % Check if the file exists
        load(fullfile(filepath, filename), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');
        % Store data by condition
        all_ersp_control{subjIdx} = erspData_subject; % Store for 'ses_off'
    else
        warning('File not found: %s', fullfile(filepath, filename))    
    end
end

% Load ERSP data for each subject and condition
for subjIdx = 1:length(subjects_off)
    % Construct filename and load dataset
    filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
	
	%ses on
    subjects_off{subjIdx}, 'ses_off', channelLabel);
        
    disp(filename);

    if exist(fullfile(filepath, filename), 'file')  % Check if the file exists
        load(fullfile(filepath, filename), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');
        % Store data by condition
        all_ersp_off{subjIdx} = erspData_subject; % Store for 'ses_off'
    else
        warning('File not found: %s', fullfile(filepath, filename));
    end
end

% Initialize arrays to store mean ERSP for each subject
mean_ersp_control_subjects = [];
mean_ersp_off_subjects = [];

% Loop through each subject and concatenate trials
for subjIdx = 1:length(subjects_control)
    n_trials_control = length(all_ersp_control{subjIdx});   % Number of trials for 'cotrol' condition
    
    % Stack all 'control' trials for the current subject
    ersp_control_subject = [];  % Initialize temporary storage for 'control'
    for trialIdx = 1:n_trials_control
        % Stack trials along the 4th dimension
        ersp_control_subject = cat(4, ersp_control_subject, all_ersp_control{subjIdx}{trialIdx});
    end

    % Average across trials for the current subject
    mean_ersp_control_subjects(:, :, subjIdx) = mean(ersp_control_subject, 4);  % Average for 'ses_off'
end

for subjIdx = 1:length(subjects_off)
    n_trials_off = length(all_ersp_off{subjIdx});   % Number of trials for 'ses_off' condition
    
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
mean_ersp_control = mean(mean_ersp_control_subjects, 3);  % Average across subjects for 'control'
mean_ersp_off = mean(mean_ersp_off_subjects, 3);  % Average for 'ses_off'

% Compute difference between conditions (can also compute ratio)
ersp_diff = mean_ersp_off - mean_ersp_control;

% Statistical test (e.g., paired t-test across subjects for each time-freq point)
[h, pvals] = ttest(mean_ersp_control_subjects,mean_ersp_off_subjects, 'Dim', 3);

% Visualize the ERSP difference and significant points
figure;

% Plot the difference in ERSP between conditions
subplot(1, 2, 1);
imagesc(times, freqs, ersp_diff);
set(gca, 'YDir', 'normal');
colorbar;

%ses on
title(['ERSP Difference (ses\_off - ses\_control) - ', channelLabel], 'FontSize', 14);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);
caxis([-1.5  1.5])

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
caxis([-1.5  1.5])

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size