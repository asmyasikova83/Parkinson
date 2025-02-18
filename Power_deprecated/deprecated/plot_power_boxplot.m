
%script for plotting timecourses
out = '/home/daniil/workspase/Parkinson/Power/pics/';
data_dir =  '/home/daniil/workspase/Power_data/'
conditions = {'ses_on'};  % Conditions for both scenarios
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)
freq = {'lowgamma'};
range = {'30-60 Hz'};
dir_pics = '/home/daniil/workspase/Parkinson/Beta_gamma/pics/'

% Initialize a structure to store power data
dataStruct = struct();

% Loop through all conditions, channels, and subjects
for condIdx = 1:length(conditions)
    condition = conditions{condIdx};

    % Define subjects based on condition
    if strcmp(condition, 'control')
        %for pd_7 beta, low gamma power is an outlier 'PD_7',
        subjects = {'PD_2', 'PD_4', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'};
    elseif strcmp(condition, 'ses_on') 
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    else
        %for pd_28 no averaged PLV in ses_off
        assert(strcmp(condition, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26'};
    end

    % Loop through all subjects
    for subjIdx = 1:length(subjects)
        subject = subjects{subjIdx};

        % Loop through all channels
        for chanIdx = 1:length(channels)
            channel = channels{chanIdx};

            % Construct the filename dynamically
            filename = sprintf('%sPower_subject_%s_condition_%s_%s.mat', freq{1}, subject, condition, channel);

            % Load the data
            file_path = fullfile(data_dir, filename);
            if exist(file_path, 'file')
                data = load(file_path);
                power = data.mean_power_db; % Extract the power data

                % Store the data in the nested structure
                dataStruct.(condition).(subject).(channel) = power;
            else
                fprintf('File not found: %s\n', file_path);
            end
        end
    end
end



% Initialize structure for channel-averaged data
avgDataStruct = struct();

% Loop through conditions
for condIdx = 1:length(conditions)
    condition = conditions{condIdx};

    % Loop through subjects
    subjectNames = fieldnames(dataStruct.(condition));
    for subjIdx = 1:length(subjectNames)
        subject = subjectNames{subjIdx};

        % Initialize temporary storage for channel data
        allChannelData = [];

        % Loop through channels
        channelNames = fieldnames(dataStruct.(condition).(subject));
        for chanIdx = 1:length(channelNames)
            channel = channelNames{chanIdx};

            % Append channel data to the temporary storage
            power = dataStruct.(condition).(subject).(channel);
            allChannelData = [allChannelData; power];
        end

        % Compute the mean across all channels
        if ~isempty(allChannelData)
            avgPower = mean(allChannelData, 1); % Average along the channel axis
            avgDataStruct.(condition).(subject) = avgPower; % Store averaged data
            % Compute the mean across time points
            avgPowerTime = mean(avgPower, 2); % Average along the time axis
    
            % Store the final averaged data
            avgDataStruct.(condition).(subject) = avgPowerTime; 
        else
            fprintf('No data to average for subject %s under condition %s.\n', subject, condition);
        end
    end
end

% Initialize variables
condition = conditions{1}; % Choose the specific condition
numSubjects = length(subjects); % Number of subjects
PowerArray = []; % To store combined data

% Loop through all subjects and concatenate their data
for i = 1:numSubjects
    subject = subjects{i}; % Get the subject name
    subjectData = avgDataStruct.(condition).(subject); % Extract data for the subject
    PowerArray = [PowerArray; subjectData(:)]; % Append as a column vector
end

%TODO - 3 containers with power data associated with the conditions
% Perform correlation
[r, p] = corr(power1, power2);

% Display correlation coefficient and p-value
fprintf('Correlation coefficient (r): %.2f\n', r);
fprintf('P-value (p): %.2f\n', p);

% Plot the data with a linear regression line
figure;
scatter(power1, power2, 100, 'filled');
hold on;

% Add regression line
coeffs = polyfit(power1, power2, 1); % Linear fit
xFit = linspace(min(power1), max(power2), 100);
yFit = polyval(coeffs, xFit);
plot(xFit, yFit, '-r', 'LineWidth', 4);

% Customize fonts
fontSize = 32; % Desired font size
xlabel(sprintf('%s Power (dB)', freq{1}), 'FontSize', fontSize);
ylabel('PLV', 'FontSize', fontSize);
title(sprintf('Correlation: r=%.2f, p=%.2f av. chans C3, C4 - %s ', r, p, conditions{1}), 'FontSize', fontSize + 6);

% Customize tick labels
set(gca, 'FontSize', fontSize);

% Set y-axis limit
ylim([0.07, 0.15]);

% Display grid
grid on;
hold off;

% Enlarge the figure
set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

% Optionally save the plot
saveas(gcf, fullfile(dir_pics, sprintf('mean_%s_power_plv_corr_%s.png', ...
    freq{1}, conditions{1})))
