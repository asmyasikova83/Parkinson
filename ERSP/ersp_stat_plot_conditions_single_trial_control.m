% Script for plotting ERSP data for single trials with bootstrapping

subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
                   'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', ...
                   'PD_32', 'PD_33'}

conditions = {'control'};  % Include both conditions
channelIdx = 8;  % %(e.g., C3 = 8, F3 = 4, F4 = 27, C4 = 23, P4 = 19, P3 = 12)
filepath = '/home/daniil/workspase/SET_PD/ses_off_control/';  % Path to saved ERSP data

% Get channel label
EEG = pop_loadset('/home/daniil/workspase/SET_PD/ses_on/PD_6_ses_on.set');
channelLabel = EEG.chanlocs(channelIdx).labels;  % Get channel label 

% Parameters for bootstrapping
n_bootstraps = 1000;  % Number of bootstrap samples
alpha = 0.05;  % Confidence level for the bootstrap intervals

% Initialize data storage
all_control = {}; % ERSP data for 'control'

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
            all_control{subjIdx} = erspData_subject;  % Store for 'control'    
        else
            warning('File not found: %s', fullfile(filepath, filename));
        end
    end
end

% Initialize arrays for mean ERSP and bootstrap confidence intervals
mean_control_subjects = [];

% Loop through each subject for 'control' conditions
for subjIdx = 1:length(subjects)
    % 'control' condition
    
    n_trials = length(all_control{subjIdx});
    ersp_control_subject = [];
    
    for trialIdx = 1:n_trials
        ersp_control_subject = cat(4, ersp_control_subject, all_control{subjIdx}{trialIdx});
    end
    mean_control_subjects(:, :, subjIdx) = mean(ersp_control_subject, 4);
end

% Bootstrapping for 'control'
numParticipants = length(subjects)
bootstrappedERSP_on = zeros(size(mean_control_subjects, 1), size(mean_control_subjects, 2), n_bootstraps);
for b = 1:n_bootstraps
    % Resample participants with replacement
    resampleIdx = randi(numParticipants, [1, numParticipants]);
    resampledERSP = mean(mean_control_subjects(:, :, resampleIdx), 3);  % Average resampled ERSPs
    bootstrappedERSP_on(:, :, b) = resampledERSP;  % Store bootstrapped ERSP
end

% Compute bootstrap thresholds (e.g., 95% confidence intervals)
lowerBound_control = prctile(bootstrappedERSP_on, 2.5, 3);  % Lower 2.5 percentile
upperBound_control = prctile(bootstrappedERSP_on, 97.5, 3);  % Upper 97.5 percentile

% Compute the mean ERSP across all subjects
mean_control = mean(mean_control_subjects, 3);

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
[timesClean, mean_controlClean] = removeNonIncreasing(times, mean_control);  % Clean rows based on time
[freqsClean, mean_controlClean] = removeNonIncreasing(freqs, mean_control);  % Clean rows based on time

% Also clean the significance mask and bootstrapped thresholds
[~, lowerBound_controlClean] = removeNonIncreasing(times, lowerBound_control);
[~, upperBound_controlClean] = removeNonIncreasing(times, upperBound_control);

% Plot mean ERSP with bootstrap confidence intervals for 'control'
figure;
subplot(1, 2, 1);
imagesc(timesClean, freqsClean, mean_controlClean);
hold on;

% Overlay the contour plot for bootstrap confidence intervals
% Here, 'upperBoundClean - lowerBoundClean' is the confidence interval width
contour(timesClean, freqsClean, upperBound_controlClean - lowerBound_controlClean, 20, 'LineWidth', 2, 'LineColor', 'black');  % Adjust contour levels and line width

colorbar;
set(gca, 'YDir', 'normal');
title(['Mean ERSP (control) - Channel: ', channelLabel], 'FontSize', 32);
xlabel('Time (ms)', 'FontSize', 32);
ylabel('Frequency (Hz)', 'FontSize', 32);
caxis([-2.5 -1])

% Additional adjustments for axes and colorbar
set(gca, 'FontSize', 32);  % Set axis font size
c = colorbar;
set(c, 'FontSize', 30);  % Set colorbar font size

