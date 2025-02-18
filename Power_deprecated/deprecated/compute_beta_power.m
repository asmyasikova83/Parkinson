
% Script for computing beta power with trial normalization
chans = {8, 23}; % Channel indices (e.g., C3 = 8)

baseFilePath = '/home/daniil/workspase/SET_PD_bline/';
out = '/home/daniil/workspase/Power_data/';

conditions = {'control'};

% Parameters
fr = {'lowgamma'};
if strcmp(fr,'beta')
    lowest_freq = 15; % Keep the lowest frequency at 13 Hz
    highest_freq = 30; % Adjust the highest frequency to a reasonable limit
    num_cycles = 3; % Reduce the number of cycles to something more typical, e.g., 6 cycles
end
if strcmp(fr,'lowgamma')
    lowest_freq = 30; % Keep the lowest frequency at 13 Hz
    highest_freq = 60; % Adjust the highest frequency to a reasonable limit
    num_cycles = 6; % Reduce the number of cycles to something more typical, e.g., 6 cycles
end
time_bandwidth = 0.5;

% Initialize a container for mean beta power across all subjects
mean_power_db_all = [];

% Loop through all subjects
for condIdx = 1:length(conditions)
    if strcmp(conditions{condIdx}, 'control')
        %subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20','PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'  }; % List of subjects
        subjects = {'PD_2'};
    else
        assert(strcmp(conditions{condIdx}, 'ses_on') || strcmp(conditions{condIdx}, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    end    

    for subjIdx = 1:length(subjects)
        % Construct filename and load dataset
        if strcmp(conditions{condIdx}, 'control')
            filename = sprintf('%s.set', subjects{subjIdx});
        else
            assert(strcmp(conditions{condIdx}, 'ses_on') || strcmp(conditions{condIdx}, 'ses_off'));
            filename = sprintf('%s_%s.set', subjects{subjIdx}, conditions{condIdx});
        end
        filepath = fullfile(baseFilePath, conditions{condIdx}, '/');
        EEG = pop_loadset('filename', filename, 'filepath', filepath);
        
        % Loop through all channels
        for chanIdx = 1:length(chans)
            channelIdx = chans{chanIdx};  % Get the current channel index
            channelLabel = EEG.chanlocs(channelIdx).labels;  % Get channel label
            
            % Get number of trials
            n_trials = size(EEG.data, 3);

            % Initialize storage for current subject/condition/channel
            Power_subject = zeros(n_trials, 200);  % Preallocate for beta power
            
            for trialIdx = 1:n_trials
                % Extract data for the current trial
                trial_data = EEG.data(channelIdx, :, trialIdx); 
        
                % Compute time-frequency representation using newtimef
                [tfr, time, freq] = newtimef(trial_data, EEG.pnts, [-1000 2000], EEG.srate, ...
                              [num_cycles time_bandwidth], ... % Use reduced cycles
                              'padratio', 1, ...
                              'baseline', nan, ...  % baseline correction
                              'freqs', [lowest_freq highest_freq], ... % Adjusted frequency range
                              'wletmethod', 'dftfilt3', ...
                              'trialbase', 'full', ...  % Analyze each trial independently
                              'plotitc', 'off');  % Disable plotting for speed

                % Convert back to linear power from dB
                linear_power = tfr;
                % Compute beta power (average over beta frequency range)
                Power_subject(trialIdx, :) = sum(linear_power, 1);  % Average over frequencies
                
            end           
            
            % Convert normalized beta power to decibels (dB)
            %mean_power_db = log10(mean_power + eps); % Adding eps to avoid log(0)
            
            % Average across trials for the subject
            mean_power = mean(Power_subject, 1); % Average summed power across trials

            % Collect mean beta power for all subjects
            mean_power_db_all(subjIdx, :) = mean_power_db; % Store the mean power for this subject
            
            % Save the averaged beta power for this subject, condition, and channel
            save(fullfile(out, sprintf('%sPower_subject_%s_condition_%s_%s.mat', ...
                fr{1}, subjects{subjIdx}, conditions{condIdx}, channelLabel)), 'mean_power_db');

            % Display processing message
            disp(['Processed and saved data for Subject: ', subjects{subjIdx}, ...
                  ', Condition: ', conditions{condIdx}, ', Channel: ', channelLabel]);
        end
    end
end

% Averageacross subjects
mean_power_db_overall = mean(mean_power_db_all, 1); 
disp(mean(mean_power_db_overall, 2));
% Dynamically generate filename using sprintf for the condition
%filename_overall = sprintf('mean_%s_power_%s_db_chan_%s.mat', fr{1}, conditions{condIdx}, channelLabel);

%save(fullfile(out, filename_overall), 'mean_power_db_overall');  % Save only the mean_beta_power_db_overall data

% Display processing message for the overall data
disp(['Processed and saved overall mean ', fr{1},  'power for condition: ', conditions{condIdx}]);
