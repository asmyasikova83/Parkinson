% Define parameters
%chans = {8, 23};
chans = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32};
baseFilePath = '/home/daniil/workspase/SET_PD_nobline/';
out = '/home/daniil/workspase/Parkinson/Power/nobline_pics';

conditions = {'ses_on', 'ses_off', 'control'};
%conditions = {'control'};


% Welch method parameters
window_length = 256; % Window length in samples (256 ms)
overlap = 128;       % Overlap in samples (128 ms)
nfft = 512;          % Number of FFT points (optional, usually >= window_length)
fs = EEG.srate;      % Sampling frequency from EEG structure

% Initialize storage for average log10(PSD) across conditions
mean_psd_log_all = cell(length(conditions), 1);

% Loop through all conditions
for condIdx = 1:length(conditions)
    if strcmp(conditions{condIdx}, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', ...
                    'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_31', 'PD_32', 'PD_33'};
    else
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', ...
                    'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};        
    end
    
    % Initialize storage for PSDs across subjects
    all_psd_log = [];
    
    for subjIdx = 1:length(subjects)
        % Construct filename and load dataset
        filename = sprintf('%s.set', subjects{subjIdx});
        filepath = fullfile(baseFilePath, conditions{condIdx}, '/');
        EEG = pop_loadset('filename', filename, 'filepath', filepath);
        
        % Initialize storage for PSD of all channels for this subject
        psd_log_channels = zeros(nfft/2+1, length(chans));
        
        % Loop through all channels
        for chanIdx = 1:length(chans)
            channelIdx = chans{chanIdx}; % Get the current channel index
            channel_data = EEG.data(channelIdx, :, :); % Shape: (1 x timepoints x trials)
            channel_data = squeeze(channel_data); % Reshape to (timepoints x trials)
            data = channel_data(:); % Flatten to 1D vector

            % Compute PSD using pwelch
            [psd, freq] = pwelch(data, window_length, overlap, nfft, fs);

            % Store log10(PSD) for the current channel
            psd_log_channels(:, chanIdx) = log10(psd);
        end

        % Average across channels for this subject
        mean_psd_log_subject = mean(psd_log_channels, 2);

        % Store for all subjects in this condition
        all_psd_log = [all_psd_log, mean_psd_log_subject]; %#ok<AGROW>
    end

    % Calculate mean log10(PSD) across subjects for the condition
    mean_psd_log_all{condIdx} = mean(all_psd_log, 2);
end

% Filter data for the range 5–50 Hz
freq_min = 5; % Minimum frequency for the plot
freq_max = 50; % Maximum frequency for the plot
freq_idx = (freq >= freq_min) & (freq <= freq_max); % Indices of frequencies in the range 5–50 Hz
freq_filtered = freq(freq_idx); % Frequencies in the range 5–50 Hz
mean_psd_log_all_filtered = cellfun(@(x) x(freq_idx), mean_psd_log_all, 'UniformOutput', false);

% Plot mean log10(PSD) for all conditions
figure;
hold on;
colors = lines(length(conditions)); % Distinct colors for each condition
for condIdx = 1:length(conditions)
    plot(freq_filtered, mean_psd_log_all_filtered{condIdx}, 'Color', colors(condIdx, :), 'LineWidth', 1.5, ...
         'DisplayName', conditions{condIdx});
end
% Plot the data
figure_handle = figure; % Create a figure and store its handle

% Assuming you already have the data to plot
hold on;

% Example plotting loop (replace with your actual data)
colors = lines(length(conditions)); % Distinct colors for each condition
for condIdx = 1:length(conditions)
    plot(freq_filtered, mean_psd_log_all_filtered{condIdx}, 'Color', colors(condIdx, :), 'LineWidth', 3, ...
         'DisplayName', conditions{condIdx});
end

% Customize plot
hold off;
xlabel('Frequency (Hz)', 'FontSize', 30, 'FontWeight', 'bold');
ylabel('Mean log_{10}(PSD)', 'FontSize', 30, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 36); % Set legend font size
title('Mean log_{10}(PSD) Averaged Over Channels and Subjects (5–50 Hz)', 'FontSize', 34, 'FontWeight', 'bold');
ylim([-1.4 0.4]); % Set y-axis limits
grid on;

% Set axis properties for enlarged font size
set(gca, 'FontSize', 30, 'LineWidth', 4);  % Set font size and axis line width

% Define the filename for saving the figure
output_filename = fullfile(out, 'mean_PSD_plot_5_50Hz.jpg');

% Save the figure as a .jpg file
saveas(figure_handle, output_filename);