
% Script for computing single-trial ERSP and p-values and saving the results for each subject and channel
chans = {8, 23};  % Channel indices (C3, F3, etc.)
%chans = {8};%(e.g., C3 = 8, F3 = 4, F4 = 27, C4 = 23, P4 = 19, P3 = 12)

%subjects = { 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
%                   'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', ...
%                   'PD_32', 'PD_33', 'PD_20'}
%'PD_2',
subjects = {'PD_26','PD_28', 'PD_3', 'PD_5', 'PD_28', ...
            'PD_6',  'PD_9',  'PD_11','PD_12','PD_13', ...
            'PD_14', 'PD_28', 'PD_19','PD_16','PD_17'}; % List of subjects

%subjects = {'PD_26'};

conditions = {'ses_off'};
baseFilePath = '/home/daniil/workspase/SET_PD_nobline/';
out = '/home/daniil/workspase/SET_PD_nobline/single_trial/ses_off_ses_on_control/';

% Loop through all subjects
for subjIdx = 1:length(subjects)
    for condIdx = 1:length(conditions)
        % Construct filename and load dataset
        filename = sprintf('%s.set', subjects{subjIdx});
        filepath = fullfile(baseFilePath, conditions{condIdx}, '/');
        EEG = pop_loadset('filename', filename, 'filepath', filepath);
        
        % Loop through all channels
        for chanIdx = 1:length(chans)
            channelIdx = chans{chanIdx};  % Get the current channel index
            channelLabel = EEG.chanlocs(channelIdx).labels;  % Get channel label
            
            disp('size(EEG.data, 3)number of trials');
            disp('number of trials');

            % Get number of trials
            n_trials = size(EEG.data, 3);

            % Initialize storage for current subject/condition/channel
            erspData_subject = cell(n_trials, 1);
            pvalues_subject = cell(n_trials, 1);

            % Loop through trials to compute ERSP for each trial individually
            for trialIdx = 1:n_trials
                [erspData, itcData, powbase, times, freqs, erspboot, itcboot, pvalues] = ...
                    newtimef(EEG.data(channelIdx, :, trialIdx), EEG.pnts, [-1000 2000], EEG.srate, [3 0.5], ...
                    'baseline', NaN, ...  % No baseline correction
                    'freqs', [3 150], ...
                    'alpha', 0.05, ...  % Statistical significance level (p < 0.05)
                    'plotersp', 'off', ...
                    'plotitc', 'off', ...
                    'trialbase', 'full', ...  % Analyze each trial independently
                    'padratio', 1);

                % Store single-trial ERSP and p-values for the current trial
                % ersp_data is your newtimef output
                c = 1;  % Small constant to handle log(0)
                ersp_data_signed_log = sign(erspData) .* log(abs(erspData) + c);
                erspData_subject{trialIdx} = ersp_data_signed_log;
                % Step 2: Exclude specific frequencies (e.g., 1, 2, 60 Hz)
                excluded_freqs = [60, 120];
                excluded_indices = ismember(round(freqs), excluded_freqs);  % Logical index for excluded frequencies

                % Step 3: Compute average log over the spectrum (excluding the specified frequencies)
                valid_indices = ~excluded_indices;  % Logical index for valid frequencies
                average_log = mean(ersp_data_signed_log(valid_indices, :), 1);  % Average across valid frequencies

                % Step 4: Subtract the average log from the signed log data
                ersp_data_normalized = ersp_data_signed_log - average_log;
                pvalues_subject{trialIdx} = pvalues;
            end

            % Save ERSP and p-values for this subject, condition, and channel
            save(fullfile(out, sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
                subjects{subjIdx}, conditions{condIdx}, channelLabel)), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');

            % Display processing message
            disp(['Processed and saved data for Subject: ', subjects{subjIdx}, ...
                  ', Condition: ', conditions{condIdx}, ', Channel: ', channelLabel]);
        end
    end
end