function averaged_kur, unique_subjects = average_kuramotos(subject_ses_on_signif) 

% Get unique subjects
    unique_subjects = unique(subject_ses_on_signif);

    % Initialize the array to store averaged Kuramoto values
    averaged_kuramoto = zeros(length(unique_subjects), 1);

    % Loop through unique subjects and calculate the average Kuramoto value for each
    for i = 1:length(unique_subjects)
        % Find indices where the subject is present
        subject_indices = strcmp(subject_ses_on_signif, unique_subjects{i});
    
        % Extract the corresponding Kuramoto values and average them
        averaged_kuramoto(i) = mean(kuramoto_ses_on_signif(subject_indices));
    end
end
