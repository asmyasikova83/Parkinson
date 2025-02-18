
%script for plotting timecourses

data_dir = '/home/daniil/workspase/Power_data/bline/';
dir_pics = '//home/daniil/workspase/Parkinson/Power/pics_bline';
conditions = {'ses_off'};  % Conditions for both scenarios
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)
freq = {'beta', 'broadbandgamma'};
fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor/';

%Extract significant PLVs (kuramotos)
[combinedKuramotoArray, subject_less_kur, averaged_kuramoto, kuramoto_ses_on_signif, unique_subjects] = extract_kuramotos(fpath, conditions)

% Initialize a structure to store power data
dataStruct = struct();

% Loop through all conditions, channels, and subjects
for condIdx = 1:length(conditions)
    condition = conditions{condIdx};

    % Define subjects based on condition
    if strcmp(condition, 'control')
        subjects = {'PD_2', 'PD_4', 'PD_7', 'PD_8', 'PD_10', 'PD_18', 'PD_20', 'PD_21', 'PD_24', 'PD_25', 'PD_29', 'PD_30', 'PD_32', 'PD_33', 'PD_31'};
    elseif strcmp(condition, 'ses_on') 
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26', 'PD_28'};
    else
        %for pd_28 no sign PLV in ses_off
        assert(strcmp(condition, 'ses_off'));
        subjects = {'PD_3', 'PD_5', 'PD_6', 'PD_9', 'PD_11', 'PD_12', 'PD_13', 'PD_14', 'PD_16', 'PD_17', 'PD_19', 'PD_22', 'PD_23', 'PD_26'};
    end

    % Loop through all subjects
    for subjIdx = 1:length(subjects)
        subject = subjects{subjIdx};

        % Loop through all channels
        for chanIdx = 1:length(channels)
            channel = channels{chanIdx};

            for frIdx = 1:length(freq)
                fr = freq(frIdx);

                % Construct the filename dynamically
                filename = sprintf('%sPower_subject_%s_condition_%s.mat', fr{1}, subject, condition);
                % Load tdisp(filename);he data
                file_path = fullfile(data_dir, filename);
                if exist(file_path, 'file')
                    data = load(file_path);
                    power = data.average_beta_power_subject; % Extract the power data
                    % Store the data in the nested structure
                    dataStruct.(condition).(subject).(fr{1}) = power;
                else
                    fprintf('File not found: %s\n', file_path);
                end
            end
        end
    end
end

[avgDataStruct] = fill_power_data(dataStruct, subject_less_kur, freq, condition);

PowerArray = convert_struct_to_array(avgDataStruct, subjects, freq, condition);

% Perform correlation
[r, p] = corr(PowerArray, combinedKuramotoArray);

% Display correlation coefficient and p-value
fprintf('Correlation coefficient (r): %.2f\n', r);
fprintf('P-value (p): %.2f\n', p);

% Plot the data with a linear regression line
figure;
scatter(PowerArray, combinedKuramotoArray, 100, 'filled');
hold on;

% Add regression line
coeffs = polyfit(PowerArray, combinedKuramotoArray, 1); % Linear fit
xFit = linspace(min(PowerArray), max(PowerArray), 100);
yFit = polyval(coeffs, xFit);
plot(xFit, yFit, '-r', 'LineWidth', 4);

% Customize fonts
fontSize = 32; % Desired font size
xlabel(sprintf('Beta and broadband gamma power (log)'), 'FontSize', fontSize);
ylabel('PLV', 'FontSize', fontSize);
title(sprintf('Correlation: r=%.2f, p=%.2f av. chans C3, C4 - %s ', r, p, conditions{1}), 'FontSize', fontSize + 6);

% Customize tick labels
set(gca, 'FontSize', fontSize);

% Set y-axis limit
%ylim([0.08, 0.18]);

% Display grid
grid on;
hold off;

% Enlarge the figure
set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

% Optionally save the plot
saveas(gcf, fullfile(dir_pics, sprintf('beta_low_gamma_power_plv_corr_%s.png', ...
     conditions{1})))
