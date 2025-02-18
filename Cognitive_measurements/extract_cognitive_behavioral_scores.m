%extract mmse, naart, gender, age
function [mmse, naart_int, gender, age, disease_duration_int] = extract_cognitive_behavioral_scores(dir_path, subjects)
    % Specify the full path to the file
    file_path = fullfile(dir_path, 'participants.txt');

    % Read the data into a table
    data = readtable(file_path, 'Delimiter', '\t', 'ReadVariableNames', true);

    % Extract the participant_id column
    participant_ids = data.participant_id;

    % Initialize an array to store the extracted integers
    extracted_integers_mmse = zeros(height(data), 1);

    % Loop through each participant ID and extract integers
    for i = 1:height(data)
        % Use regexp to extract numeric digits
        numbers = regexp(participant_ids{i}, '\d+', 'match');
    
        % Convert the extracted numbers to a single integer
        extracted_integers_mmse(i) = str2double(numbers{1}); % Take the first set of digits
    end

    % Replace 'participant_id' values with 'PD_' and the corresponding integer
    for i = 1:height(data)
        data.participant_id{i} = ['PD_' num2str(extracted_integers_mmse(i))];
    end

    % Filter the table by matching participant_id with unique_subjects
    filtered_cognitive_scores_table = data(ismember(data.participant_id, subjects), :);
    filtered_cognitive_scores_table 
    % Get the column indices for MMSE and NAART
    mmse_idx = find(strcmp(data.Properties.VariableNames, 'MMSE'));
    naart_idx = find(strcmp(data.Properties.VariableNames, 'NAART'));
    age_idx = find(strcmp(data.Properties.VariableNames, 'age'));
    gender_idx = find(strcmp(data.Properties.VariableNames, 'gender'));
    disease_duration_idx = find(strcmp(data.Properties.VariableNames, 'disease_duration'));


    % Extract the MMSE 
    mmse = filtered_cognitive_scores_table{:, mmse_idx+1}; % Column after MMSE

    % Extract the NAART and the following column
    naart = filtered_cognitive_scores_table{:, naart_idx+1}; % Column after NAART
    naart_int = cellfun(@str2double, naart);

    % Extract the Age
    age = filtered_cognitive_scores_table{:, age_idx}; % Column after MMSE

    % Extract the Gender
    gender = filtered_cognitive_scores_table{:, gender_idx}; %

    % Extract the disease_duration
    disease_duration = filtered_cognitive_scores_table{:, disease_duration_idx}; %

    disease_duration_int = cellfun(@str2double, disease_duration);
end