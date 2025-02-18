%Convert data struct with powers to power array
function PowerArray = convert_struct_to_array_both_conds(avgDataStruct, conditions, freq, subjects, subjectsPerCondition)
% Initialize variables
if length(conditions) >= 2
    numSubjects = 2*length(subjects); % Number of subjects for 2 conditions
    subjects = [subjects; subjects];
else
    assert(length(conditions) == 1);
    numSubjects = length(subjects);
end

disp(length(subjects));

numConditions = length(conditions); % Number of conditions
PowerArray = []; % To store combined data

% Generate cond_list
cond_list = cell(1, length(subjects));
subjectIndex = 1;

for condIdx = 1:length(conditions)
    numSubjectsForCondition = subjectsPerCondition{condIdx};
    for j = 1:numSubjectsForCondition
        cond_list{subjectIndex} = conditions{condIdx};
        subjectIndex = subjectIndex + 1;
    end
end

for condIdx = 1:length(conditions) 
    % Loop through subjects
    for i = 1:numSubjects
        subject = subjects{i}; % Get the subject name
        disp(subject);
        condition = cond_list{i}; % Get the condition for this subject
        disp(condition);   
        % Extract data for the subject and condition
        subjectData = avgDataStruct.(condition).(subject).(freq{1});
        disp(subjectData);    
        % Append as a column vector
        PowerArray = [PowerArray; subjectData(:)];
    end
end