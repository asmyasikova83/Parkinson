figure;
subplot(2,1,1);
plot(freq, log10(psd)); % Raw PSD
xlabel('Frequency (Hz)');
ylabel('log_{10}(PSD)');
title('Raw PSD');

subplot(2,1,2);
plot(freq(valid_indices), normalized_psd(valid_indices)); % Normalized PSD
xlabel('Frequency (Hz)');
ylabel('Normalized log_{10}(PSD)');
title('Normalized PSD');