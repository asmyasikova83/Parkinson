%read significant PLVs
function [combinedKuramotoArray, subject_less_kur, reordered_kuramoto, kuramoto_ses_on_signif, unique_subjects] = extract_kuramotos(fpath, subjects, condition)
    %Function to read and filter significant PLVs (kuramotos)
    addpath '/home/daniil/workspase/Parkinson/GCFD/gcfd/task/scripts/'

    % Initialize the array to store averaged Kuramoto values
    averaged_kuramoto = zeros(length(subjects), 1);
        
    subj_ses_on = sprintf('%s%s_subject.res', fpath, condition);
    ku_ses_on = sprintf('%s%s_kuramoto.res', fpath, condition);
    p_val_p_ses_on = sprintf('%s%s_pval_p.res', fpath, condition);
    p_val_q_ses_on = sprintf('%s%s_pval_q.res', fpath, condition);

    subject_ses_on = read_data(subj_ses_on);
    kuramoto_ses_on = read_data(ku_ses_on);
    p_val_p_ses_on = read_data(p_val_p_ses_on);
    p_val_q_ses_on = read_data(p_val_q_ses_on);

    % Convert the cell array to a numeric array
    kuramoto_numeric_ses_on = str2double(kuramoto_ses_on);
    p_val_p_numeric_ses_on = str2double(p_val_p_ses_on);
    p_val_q_numeric_ses_on = str2double(p_val_q_ses_on);

    %Remove insignificant data
    %chdir('/home/daniil/workspase/Parkinson/GCFD/gcfd/task/scripts/')
    [subject_ses_on_signif] = rm_nonsign_pat(subject_ses_on, p_val_p_numeric_ses_on, p_val_q_numeric_ses_on);
    [kuramoto_ses_on_signif] = rm_nonsign_pat(kuramoto_numeric_ses_on, p_val_p_numeric_ses_on, p_val_q_numeric_ses_on);

    % Check normality using Jarque-Bera test
    %[h, p] = jbtest(kuramoto_ses_on_signif);

    % Display results
    %disp('Jarque-Bera Test:');
    %disp(['h (0=normal, 1=not normal): ', num2str(h)]);
    %disp(['p-value: ', num2str(p)]);

    threshold = 3; % Z-score threshold for outliers

    % Calculate z-scores
    z_scores = (kuramoto_ses_on_signif - mean(kuramoto_ses_on_signif)) / std(kuramoto_ses_on_signif);

    % Identify outliers
    outliers = abs(z_scores) > threshold;

    % Handle outliers (e.g., remove them)
    cleaned_data = kuramoto_ses_on_signif(~outliers);
   
    subject_ses_on_signif = subject_ses_on_signif(~outliers);

    % Plot the original data
    %subplot(1, 2, 1); % Create a subplot in a 1x2 grid, first plot
    %boxplot(kuramoto_ses_on_signif);
    %title('Original Data');
    %xlabel('Data');
    %ylabel('Values');

    % Plot the cleaned data
    %subplot(1, 2, 2); % Create a subplot in a 1x2 grid, second plot
    %boxplot(cleaned_data);
    %title('Cleaned Data');
    %xlabel('Data');
    %ylabel('Values');

    % Save the figure as a JPEG image
    %jpeg_filename = fullfile(fpath, ['comparison_plot_' condition '.jpg']);
    %saveas(gcf, jpeg_filename); % Save the current figure as a JPEG file

    % Optionally, close the figure
    %close(gcf);

    unique_subjects = unique(subject_ses_on_signif);
    
    for i = 1:length(unique_subjects)       
        % Find indices where the subject is present
        subject_indices = strcmp(subject_ses_on_signif, unique_subjects{i});
    
        % Extract the corresponding Kuramoto values and average them
        averaged_kuramoto(i) = mean(cleaned_data(subject_indices));
    end
    

    % Remove zero values
    averaged_kuramoto = averaged_kuramoto(averaged_kuramoto ~= 0);
    % Initialize reordered array
    reordered_kuramoto = zeros(size(subjects));

    % Reorder averaged_kuramoto based on subjects
    for i = 1:length(subjects)
        disp(i);
        % Find the index of the current subject in unique_subjects
        idx = find(strcmp(unique_subjects, subjects{i}));
        reordered_kuramoto(i) = averaged_kuramoto(idx);
    end

    % Save as a .txt file with the condition in the filename
    txt_filename = fullfile(fpath, ['kuramoto_' condition '.txt']);
    dlmwrite(txt_filename, reordered_kuramoto, 'delimiter', '\t');

    % Set the random seed for reproducibility
    rng(42,'twister'); % You can replace 42 with any integer seed value

    % Initialize an empty array to store all Kuramoto values vertically
    combinedKuramotoArray = [];

    % Initialize the subject-less Kuramoto list as a cell array
    subject_less_kur = [];

    % Loop through unique subjects
    for i = 1:length(unique_subjects)
    
        % Find indices where the subject is present
        subject_indices = strcmp(subject_ses_on_signif, unique_subjects{i});
        kuramoto_values = kuramoto_ses_on_signif(subject_indices);
    
        % Randomly select two values from the extracted Kuramoto values
        if length(kuramoto_values) >= 2
            rnd_indices = randperm(length(kuramoto_values), 2);
            % Append the values to the combined array as a column vector
            combinedKuramotoArray = [combinedKuramotoArray; kuramoto_values(rnd_indices)];
        else
            subject_less_kur = [subject_less_kur unique_subjects(i)];
            combinedKuramotoArray = [combinedKuramotoArray; kuramoto_values];
        end

    end