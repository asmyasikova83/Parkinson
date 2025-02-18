%read significant PLVs
function [combinedKuramotoArray, subject_less_kur, averaged_kuramoto, kuramoto_ses_on_signif, unisubjs, subjectsPerCondition] = extract_kuramotos_both_conds(fpath, subjects, conditions)
    %Function to read and filter significant PLVs (kuramotos)
    addpath '/home/daniil/workspase/Parkinson/GCFD/gcfd/task/scripts/'

    % Initialize the array to store averaged Kuramoto values
    averaged_kuramoto = zeros(2*length(subjects), 1);

    mult = 0;
    unisubjs = [];
    subjectsPerCondition = {};
    % Loop through unique subjects and calculate the average Kuramoto value for each
    for condIdx = 1:length(conditions)
        
        condition = conditions{condIdx};
        
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

        % Get unique subjects
        
        unique_subjects = unique(subject_ses_on_signif);
        unisubjs = [unisubjs; unique_subjects];
        subjectsPerCondition{condIdx} = length(unique_subjects);
        for i = 1:length(unique_subjects)
            
            % Find indices where the subject is present
            subject_indices = strcmp(subject_ses_on_signif, unique_subjects{i});
    
            % Extract the corresponding Kuramoto values and average them
            averaged_kuramoto(mult+i) = mean(kuramoto_ses_on_signif(subject_indices));
        end
        mult = mult + length(unique_subjects);
    end

    % Remove zero values
    averaged_kuramoto = averaged_kuramoto(averaged_kuramoto ~= 0);

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
end