% Define parameters
chans = {8, 23}; % Channel indices (e.g., C3 = 8)
%
%chans = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32};
baseFilePath = '/home/daniil/workspase/SET_PD_nobline/';
out = '/home/daniil/workspase/Power_data/nobline/52_120/';

conditions = {'control', 'ses_off', 'ses_on'};

% Welch method parameters
window_length = 256; % Window length in samples (256 ms)
overlap = 128;       % Overlap in samples (128 ms)
nfft = 512;          % Number of FFT points (optional, usually >= window_length)
fs = EEG.srate;      % Sampling frequency from EEG structure


% Define the beta frequency range
frequency = {'beta'};
if strcmp(frequency, 'broadbandgamma')
    % when normalizing, we 
    beta_range = [52, 120];
end
if strcmp(frequency, 'lowgamma')
    beta_range = [30, 60];
end
if strcmp(frequency, 'beta')
    beta_range = [13, 30];
end

% Initialize storage for average beta power per subject and condition
average_beta_powers = [];
subject_labels = {};
% Initialize storage for average beta powers and subject labels for each condition
average_beta_powers_all_conditions = [];
subject_labels_all_conditions = [];

% Loop through all conditions
for condIdx = 1:length(conditions)
    % Determine the subjects for the current condition
    if strcmp(conditions{condIdx}, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'};
    else
        assert(strcmp(conditions{condIdx}, 'ses_on') || strcmp(conditions{condIdx}, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    end

    % Initialize storage for current condition
    average_beta_powers = [];
    subject_labels = {};

    for subjIdx = 1:length(subjects)
        % Construct filename and load dataset
        filename = sprintf('%s.set', subjects{subjIdx});
        filepath = fullfile(baseFilePath, conditions{condIdx}, '/');
        disp(filepath);
        disp(filename);
        EEG = pop_loadset('filename', filename, 'filepath', filepath);

        % Initialize storage for beta power from all channels
        beta_powers = zeros(length(chans), 1);

        % Loop through all channels
        for chanIdx = 1:length(chans)
            channelIdx = chans{chanIdx};  % Get the current channel index
            channelLabel = EEG.chanlocs(channelIdx).labels;  % Get channel label

            channel_data = EEG.data(channelIdx, :, :); % Shape: (1 x timepoints x trials)
            channel_data = squeeze(channel_data);     % Reshape to (timepoints x trials)

            % Now combine the averaged data into a single long segment (reshape to 1D)
            data = channel_data(:);  % Flatten to 1D vector

            % Compute the PSD using pwelch
            [psd, freq] = pwelch(data, window_length, overlap, nfft, fs);

            % Define valid frequency range excluding 60 Hz and 120 Hz (with tolerance)
            tolerance = 1;  % Exclude ±1 Hz around harmonics
            valid_indices = (freq >= 1 & freq <= 150 & ...
                ~(freq >= 60 - tolerance & freq <= 60 + tolerance) & ...
                ~(freq >= 120 - tolerance & freq <= 120 + tolerance));

            % Normalize the PSD
            normalized_psd = log10(psd) - mean(log10(psd(valid_indices)));

            % Extract beta range and compute log power
            beta_indices = (freq >= beta_range(1) & freq <= beta_range(2));
            beta = normalized_psd(beta_indices);

            beta_log = mean(beta);

            % Compute the average log beta power for the current channel
            beta_powers(chanIdx) = beta_log;

            % Save the averaged beta power for this subject, condition, and channel
            save(fullfile(out, sprintf('%sPower_subject_%s_condition_%s_%s.mat', ...
                frequency{1}, subjects{subjIdx}, conditions{condIdx}, channelLabel)), 'beta_log');
  
            % Optional: Display intermediate results
            fprintf('Normalized beta power for subject: %s, channel: %s = %.4f\n', ...
                subjects{subjIdx}, channelLabel, beta_powers(chanIdx));
        end

        % Compute the overall average beta power across channels for the current subject
        average_beta_power_subject = mean(beta_powers);

        % Save the averaged beta power for this subject, condition
        save(fullfile(out, sprintf('%sPower_subject_%s_condition_%s.mat', ...
            frequency{1}, subjects{subjIdx}, conditions{condIdx})), 'average_beta_power_subject');       

        % Stack the average beta power for each subject column-wise
        average_beta_powers = [average_beta_powers, average_beta_power_subject]; % Append column-wise

        % Stack the subject labels column-wise
        subject_labels = [subject_labels, {sprintf('%s', conditions{condIdx})}]; % Append column-wise as a cell array

        % Display the result for the subject
        fprintf('Average normalized beta power across channels for subject: %s = %.4f\n', ...
                subjects{subjIdx}, average_beta_power_subject);
    end

    % Append the current condition's results to the overall storage
    
    average_beta_powers_all_conditions = [average_beta_powers_all_conditions; average_beta_powers];
    subject_labels_all_conditions = [subject_labels_all_conditions; subject_labels]; % Concatenate cell array
end

average_beta_powers_all_conditions = average_beta_powers_all_conditions';

disp(mean(average_beta_powers_all_conditions));

save(fullfile(out, sprintf('average_%s_powers_all_conditions.mat', frequency{1})), 'average_beta_powers_all_conditions');
%labels_filename = '/home/daniil/workspase/Power_data/nobline/subject_labels_all_conditions.txt';

% Open the file for writing
%fid = fopen(labels_filename, 'w');

% Write each label to the file
%for labelIdx = 1:length(subject_labels_all_conditions)
%    fprintf(fid, '%s\n', subject_labels_all_conditions{labelIdx});
%end

% Close the file
%fclose(fid);
