
%script for plotting timecourses

data_dir =  '/home/daniil/workspase/Power_data/nobline/52_120/'
conditions = {'control'};  % Conditions for both scenarios
channels = {'C3', 'C4'}; % Channel indices (e.g., C3 = 8)
freq = {'broadbandgamma'};
dir_pics = '/home/daniil/workspase/Parkinson/Power/nobline_pics/'
fpath = '/home/daniil/workspase/data_pd_aggr_beta13_30_gamma50_150_frp1_frq4_p_q_motor_nobline/';

% Initialize a structure to store power data

power_beta_filename = fullfile(power_fpath, ['power_' freq{1} '_' conditions{1} '.txt']);
power = dlmread(power_beta_filename, '\t');

kuramoto_filename = fullfile(kuramoto_fpath, ['kuramoto_' conditions{1} '.txt']);
k = dlmread(kuramoto_filename, '\t');

% Perform correlation
[r, p] = corr(power, k');

% Display correlation coefficient and p-value
fprintf('Correlation coefficient (r): %.2f\n', r);
fprintf('P-value (p): %.2f\n', p);

% Plot the data with a linear regression line
figure;
scatter(power, k', 100, 'filled');
hold on;

% Add regression line
coeffs = polyfit(power, k', 1); % Linear fit
xFit = linspace(min(power), max(power), 100);
yFit = polyval(coeffs, xFit);
plot(xFit, yFit, '-r', 'LineWidth', 4);

% Customize fonts
fontSize = 32; % Desired font size
xlabel(sprintf('%s Log Power', freq{1}), 'FontSize', fontSize);
ylabel('PLV', 'FontSize', fontSize);
title(sprintf('Corr %s: r=%.2f, p=%.2f in C3, C4 - %s ', freq{1}, r, p, conditions{1}), 'FontSize', 32);
% Set the y-axis limits
ylim([0.05 0.11]); %broadbandgamma

if strcmp(freq{1}, 'broadbandgamma')
    xlim([-0.6 0.0]);
end
% Customize tick labels
set(gca, 'FontSize', fontSize);

% Set y-axis limit
%ylim([0.07, 0.15]);

% Display grid
grid on;
hold off;

% Enlarge the figure
set(gcf, 'Position', [100, 100, 1600, 1200]); % Adjust figure size (Width x Height in pixels)

% Optionally save the plot
saveas(gcf, fullfile(dir_pics, sprintf('%s_power_plv_corr_%s.png', ...
    freq{1}, conditions{1})))
