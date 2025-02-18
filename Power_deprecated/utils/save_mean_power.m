%Convert data struct with powers to power array
function PowerArray = convert_struct_to_array(fpath, avgDataStruct, subjects, freq, condition)

    % Initialize variables
    %condition = conditions{1}; % Choose the specific condition
    numSubjects = length(subjects); % Number of subjects
    PowerArray = []; % To store combined data
    

    for i = 1:numSubjects
        for frIdx = 1:length(freq)
            fr = freq(frIdx);
            subject = subjects{i}; % Get the subject name

            % Extract data for the subjectcondition{1}
            subjectData = avgDataStruct.(condition).(subject).(fr{1});
            PowerArray = [PowerArray; subjectData(:)]; % Append as a column vector
        end
    end

    % Save as a .txt file with the condition in the filename
    txt_filename = fullfile(fpath, ['power_' freq{1} '_' condition '.txt']);
    dlmwrite(txt_filename, PowerArray, 'delimiter', '\t');
end