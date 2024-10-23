
% Script for computing single-trial ERSP and p-values and saving the results for each subject and channel
%chans = {4, 8, 12, 19, 23, 27};  % Channel indices (C3, F3, etc.)
chans = {8};%(e.g., C3 = 8, F3 = 4, F4 = 27, C4 = 23, P4 = 19, P3 = 12)

subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', ...
            'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', ...
            'PD_22', 'PD_23', 'PD_26', 'PD_28'};
conditions = {'ses_on', 'ses_off'};
baseFilePath = '/home/daniil/workspase/SET_PD/';
out = '/home/daniil/workspase/SET_PD/ses_on_ses_off/';

% Loop through all subjects
for subjIdx = 1:length(subjects)
    for condIdx = 1:length(conditions)
        % Construct filename and load dataset
        filename = sprintf('%s_%s.set', subjects{subjIdx}, conditions{condIdx});
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
                subjects{subjIdx}, conditions{condIdx}, channelLabel)), 'erspData_subject', 'pvalues_subject', 'times', 'freqs');

            % Display processing message
            disp(['Processed and saved data for Subject: ', subjects{subjIdx}, ...
                  ', Condition: ', conditions{condIdx}, ', Channel: ', channelLabel]);
        end
    end
end