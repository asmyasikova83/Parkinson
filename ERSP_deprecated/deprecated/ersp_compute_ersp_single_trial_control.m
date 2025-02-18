
% Script for computing single-trial ERSP and p-values and saving the results for each subject and channel
chans = {8, 23};  % Channel indices (C3, F3, etc.)
%chans = {8};%(e.g., C3 = 8, F3 = 4, F4 = 27, C4 = 23, P4 = 19, P3 = 12)

subjects_control = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
                   'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', ...
                   'PD_32', 'PD_33', 'PD_20'}

conditions = {'control'};
baseFilePath = '/home/daniil/workspase/SET_PD_nobline/';
out = '/home/daniil/workspase/SET_PD_nobline/ses_off_ses_on_control/';

% Loop through all subjects
for subjIdx = 1:length(subjects_control)
    for condIdx = 1:length(conditions)
        % Construct filename and load dataset
        %filename = sprintf('%s_%s.set', subjects{subjIdx}, conditions{condIdx});
        filename = sprintf('%s.set', subjects_control{subjIdx});
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
                    'freqs', [2 100], ...
                    'alpha', 0.05, ...  % Statistical significance level (p < 0.05)
                    'plotersp', 'off', ...
                    'plotitc', 'off', ...
                    'trialbase', 'full', ...  % Analyze each trial independently
                    'padratio', 1, ...
                    'mcorrect', 'fdr');  % FDR correction applied

                % Store single-trial ERSP and p-values for the current trial
                erspData_subject{trialIdx} = erspData;
                pvalues_subject{trialIdx} = pvalues;
            end

            % Save ERSP and p-values for this subject, condition, and channel
            save(fullfile(out, sprintf('erspData_subject_%s_condition_%s_%s.mat', ...
                subjects_control{subjIdx}, conditions{condIdx}, channelLabel)), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');

            % Display processing message
            disp(['Processed and saved data for Subject: ', subjects_control{subjIdx}, ...
                  ', Condition: ', conditions{condIdx}, ', Channel: ', channelLabel]);
        end
    end
end