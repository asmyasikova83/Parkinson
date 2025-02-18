%function to fill a datastructure with power data the size of kuramoto

function [avgDataStruct] = fill_power_data(dataStruct, subject_less_kur, freq, conditions)
    addpath '/home/daniil/workspase/Parkinson/Power'
    % Initialize structure for channel-averaged data
    avgDataStruct = struct();

    % Get all subjects in dataStruct for the given condition
    allSubjects = fieldnames(dataStruct.(conditions{1}));

    % Loop through all subjects
    for i = 1:length(allSubjects)
        subject = allSubjects{i};
    
        if ismember(subject, subject_less_kur)
            % Handle subjects in subject_less_kur with filtered data
            rnd_freq_indices = randperm(length(freq), length(freq)); % Randomly select two indices
            selected_freq = char(freq(rnd_freq_indices(1))); % Pick one randomly selected frequency
        
            if isfield(dataStruct.(subject).(conditions{1}), selected_freq)
                % Extract and wrap the filtered data
                filtered_data = dataStruct.(subject).(conditions{1}).(selected_freq);
                filtered_data_wrapped = struct(selected_freq, filtered_data);
            
                % Store the filtered data in avgDataStruct
                avgDataStruct.(subject).(conditions{1}) = filtered_data_wrapped;
            else
                warning('Frequency %s not found for subject %s in condition %s.', selected_freq, subject, condition);
            end
        else
            % Transfer unchanged data for all other subjects
            if isfield(dataStruct.(conditions{1}), subject)
                avgDataStruct.(subject).(conditions{1}) = dataStruct.(subject).(conditions{1});
            else
                warning('Subject %s not found in DataStruct.', subject);
            end
        end
    end
end