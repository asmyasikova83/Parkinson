% Script for plotting ERSP data for single trials with bootstrapping

subjects = {'PD_26', 'PD_28', 'PD_3', 'PD_5', 'PD_28', ...
            'PD_6',  'PD_9',  'PD_11','PD_12','PD_13', ...
            'PD_14', 'PD_28', 'PD_19','PD_16','PD_17'};
conditions = {'ses_on', 'ses_off'};  % Include both conditions
channelIdx = 8;  % %(e.g., C3 = 8, F3 = 4, F4 = 27, C4 = 23, P4 = 19, P3 = 12)
filepath = '/home/daniil/workspase/SET_PD/ses_on_ses_off/';  % Path to saved ERSP data

% Get channel label
EEG = pop_loadset('/home/daniil/workspase/SET_PD/ses_on/PD_6_ses_on.set');
channelLabel = EEG.chanlocs(channelIdx).labels;  % Get channel label 

% Parameters for bootstrapping
n_bootstraps = 1000;  % Number of bootstrap samples
alpha = 0.05;  % Confidence level for the bootstrap intervals

% Initialize data storage
all_ersp_on = {};  % ERSP data for 'ses_on'
all_ersp_off = {}; % ERSP data for 'ses_off'

% Load ERSP data for each subject and condition
for subjIdx = 1:length(subjects)
    for condIdx = 1:length(conditions)
        % Construct filename and load dataset
        filename = sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
            subjects{subjIdx}, conditions{condIdx}, EEG.chanlocs(channelIdx).labels);
        disp(filename);
        if exist(fullfile(filepath, filename), 'file')  % Check if the file exists
            load(fullfile(filepath, filename), 'erspData_subject', 'times', 'freqs');
            % Store data by condition
            if strcmp(conditions{condIdx}, 'ses_on')
                all_ersp_on{subjIdx} = erspData_subject;  % Store for 'ses_on'
            elseif strcmp(conditions{condIdx}, 'ses_off')
                all_ersp_off{subjIdx} = erspData_subject; % Store for 'ses_off'
            end
        else
            warning('File not found: %s', fullfile(filepath, filename));
        end
    end
end

% Initialize arrays for mean ERSP and bootstrap confidence intervals
mean_ersp_on_subjects = [];
mean_ersp_off_subjects = [];

% Loop through each subject for 'ses_on' and 'ses_off' conditions
for subjIdx = 1:length(subjects)
    % 'ses_on' condition    
    n_trials_on = length(all_ersp_on{subjIdx});
    ersp_on_subject = [];
    
    for trialIdx = 1:n_trials_on
        ersp_on_subject = cat(4, ersp_on_subject, all_ersp_on{subjIdx}{trialIdx});
    end
    mean_ersp_on_subjects(:, :, subjIdx) = mean(ersp_on_subject, 4);
   
    % 'ses_off' condition
    n_trials_off = length(all_ersp_off{subjIdx});
    ersp_off_subject = [];
    
    for trialIdx = 1:n_trials_off
        ersp_off_subject = cat(4, ersp_off_subject, all_ersp_off{subjIdx}{trialIdx});
    end
    mean_ersp_off_subjects(:, :, subjIdx) = mean(ersp_off_subject, 4);
end

% Bootstrapping for 'ses-on'
numParticipants = length(subjects)
bootstrappedERSP_on = zeros(size(mean_ersp_on_subjects, 1), size(mean_ersp_on_subjects, 2), n_bootstraps);
for b = 1:n_bootstraps
    % Resample participants with replacement
    resampleIdx = randi(numParticipants, [1, numParticipants]);
    disp(resampleIdx);
    resampledERSP = mean(mean_ersp_on_subjects(:, :, resampleIdx), 3);  % Average resampled ERSPs
    bootstrappedERSP_on(:, :, b) = resampledERSP;  % Store bootstrapped ERSP
end

% Bootstrapping for 'ses-off'
bootstrappedERSP_off = zeros(size(mean_ersp_off_subjects, 1), size(mean_ersp_off_subjects, 2), n_bootstraps);
for b = 1:n_bootstraps
    % Resample participants with replacement
    resampleIdx = randi(numParticipants, [1, numParticipants]);
    resampledERSP = mean(mean_ersp_off_subjects(:, :, resampleIdx), 3);  % Average resampled ERSPs
    bootstrappedERSP_off(:, :, b) = resampledERSP;  % Store bootstrapped ERSP
end

% Compute bootstrap thresholds (e.g., 95% confidence intervals)
lowerBound_on = prctile(bootstrappedERSP_on, 2.5, 3);  % Lower 2.5 percentile
upperBound_on = prctile(bootstrappedERSP_on, 97.5, 3);  % Upper 97.5 percentile
lowerBound_off = prctile(bootstrappedERSP_off, 2.5, 3);  % Lower 2.5 percentile
upperBound_off = prctile(bootstrappedERSP_off, 97.5, 3);  % Upper 97.5 percentile

% Compute the mean ERSP across all subjects
mean_ersp_on = mean(mean_ersp_on_subjects, 3);
mean_ersp_off = mean(mean_ersp_off_subjects, 3);

% Function to remove non-increasing or repeated values
function [cleanedVector, cleanedData] = removeNonIncreasing(vector, dataMatrix)
    % Ensure that the vector and the corresponding data matrix are compatible
    % dim indicates whether we are cleaning rows (1) or columns (2) in the dataMatrix
    diffVector = diff(vector);
    invalidIndices = find(diffVector <= 0) + 1;  % Find indices of non-increasing value
    cleanedVector = vector;
    cleanedData = dataMatrix;
    
    if ~isempty(invalidIndices)
        % Remove the non-increasing values from the vector
        cleanedVector(invalidIndices) = [];
        % Remove rows from dataMatrix (i.e., times)
        cleanedData(:, invalidIndices) = [];
    end
end

% Check and clean
[timesClean, mean_ersp_onClean] = removeNonIncreasing(times, mean_ersp_on);  % Clean rows based on time
[freqsClean, mean_ersp_onClean] = removeNonIncreasing(freqs, mean_ersp_on);  % Clean rows based on time

% Also clean the significance mask and bootstrapped thresholds
[~, lowerBound_onClean] = removeNonIncreasing(times, lowerBound_on);
[~, upperBound_onClean] = removeNonIncreasing(times, upperBound_on);

[timesClean, mean_ersp_offClean] = removeNonIncreasing(times, mean_ersp_off);  % Clean rows based on time
[freqsClean, mean_ersp_offClean] = removeNonIncreasing(freqs, mean_ersp_off);  % Clean rows based on time

% Also clean the significance mask and bootstrapped thresholds
[~, lowerBound_offClean] = removeNonIncreasing(times, lowerBound_off);
[~, upperBound_offClean] = removeNonIncreasing(times, upperBound_off);

% Plot mean ERSP with bootstrap confidence intervals for 'ses_on'
figure;
subplot(1, 2, 1);
imagesc(timesClean, freqsClean, mean_ersp_onClean);
hold on;

% Overlay the contour plot for bootstrap confidence intervals
% Here, 'upperBoundClean - lowerBoundClean' is the confidence interval width
contour(timesClean, freqsClean, upperBound_onClean - lowerBound_onClean, 20, 'LineWidth', 2, 'LineColor', 'black');  % Adjust contour levels and line width

colorbar;
set(gca, 'YDir', 'normal');
title(['Mean ERSP (ses\_on) - Channel: ', channelLabel], 'FontSize', 32);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);
caxis([-2.5 -1])

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size

% Plot mean ERSP with bootstrap confidence intervals for 'ses_off'
subplot(1, 2, 2);
imagesc(timesClean, freqsClean, mean_ersp_offClean);
hold on;

% Overlay the contour plot for bootstrap confidence intervals
contour(timesClean, freqsClean, upperBound_offClean - lowerBound_offClean, 20, 'LineWidth', 2, 'LineColor', 'black');  % Adjust contour levels and line width

colorbar;
set(gca, 'YDir', 'normal');
title(['Mean ERSP (ses\_off) - Channel: ', channelLabel], 'FontSize', 32);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);
caxis([-2.5 -1])

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size

