%script to correlate PLVs, Power and cognitive score in PD
conditions = {'ses_on', 'control'};  % Conditions for both scenarios
dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/pics/'
% Set the directory containing the data
data_dir = '/home/daniil/workspase/Power_data/'
dir_path = '/home/daniil/workspase/Parkinson/Cognitive_measurements/';
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)

dir_pics = '/home/daniil/workspase/Parkinson/Cognitive_measurements/pics/'

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

% Get the column indices for MMSE and NAART
mmse_idx = find(strcmp(data.Properties.VariableNames, 'MMSE'));
naart_idx = find(strcmp(data.Properties.VariableNames, 'NAART'));
age_idx = find(strcmp(data.Properties.VariableNames, 'age'));
gender_idx = find(strcmp(data.Properties.VariableNames, 'gender'));

% Predefine variables for storing grouped data
allAges = [];
allGender = [];

groupLabels = [];

for condIdx = 1:length(conditions)
    condition = conditions{condIdx}

    % Define subjects based on condition
    if strcmp(condition, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'};
        % Number of samples in each group
        n1 = length(subjects);
    else strcmp(condition, 'ses_on') 
        % Change label to 'PD' for this condition
        condition = 'PD'; % Update the group label
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
        n2 = length(subjects);
  end

    % Filter the table by matching participant_id with unique_subjects
    filtered_cognitive_scores_table = data(ismember(data.participant_id, subjects), :);

    % Extract the Age
    age = filtered_cognitive_scores_table{:, age_idx}; % Column after MMSE
    gender = filtered_cognitive_scores_table{:, gender_idx};

    % Append the ages and corresponding group labels
    allAges = [allAges; age];
    allGender = [allGender; gender];

    groupLabels = [groupLabels; repmat({condition}, size(age))];
end

% Convert groupLabels to categorical for plotting
groupLabels = categorical(groupLabels);

% Perform a Mann-Whitney U test (Wilcoxon rank-sum test)
[p, h, stats] = ranksum(allAges(groupLabels == 'control'), allAges(groupLabels == 'PD'));

control_mean_age = mean(allAges(groupLabels == 'control'));
control_std_age = std(allAges(groupLabels == 'control'));

pd_mean_age = mean(allAges(groupLabels == 'PD'));
pd_std_age = std(allAges(groupLabels == 'PD'));

% Extract rank sum for the smaller group
R = stats.ranksum;

% Compute U value for group1 (smaller group)
U = R - (n1 * (n1 + 1)) / 2;

% Display the p-value
disp(['Mann-Whitney U test p-value: ', num2str(p)]);
disp(U);

% Create a grouped boxplot
figure;
h = boxplot(allAges, groupLabels, 'Notch', 'on'); % Adjust line width

% Customize font sizes
set(gca, 'FontSize', 56); % Set font size for axes
xlabel('Condition', 'FontSize', 56); % X-axis label font size
ylabel('Age', 'FontSize', 56); % Y-axis label font size

% Add the p-value to the title
title(['Box Plots of Age Across Conditions (p = ', num2str(p, '%.3f'), ')'], 'FontSize', 56); % Title font size with p-value

% Ensure the figure is displayed properly
grid on; % Optional: add a grid for better readability

% Count unique values and their frequencies
[uniqueGenders, ~, genderIdx] = unique(allGender(groupLabels == 'control'));
genderCounts = histcounts(genderIdx, 1:(numel(uniqueGenders) + 1));

% Create a bar chart
bar(genderCounts);
set(gca, 'XTickLabel', uniqueGenders, 'XTick', 1:numel(uniqueGenders));