%% FrequencyPlots
% Fourier Plots for Vocoder  
% Author: Hassan Islam 
% Date: 2024-02-15
 
%%%%% Plot in specific time 
time = 3; % seconds
indx = floor(time*fs1/frameSize);

figure;
frequencies = linspace(-fs1/2, fs1/2, length(F_mod_cell{1}));
    
subplot(4,1,1);
   plot(frequencies, abs(vocoded_frames_cell{indx}), 'm', 'LineWidth', 1.5); 
   title(sprintf('Vocoded Frequency Response @ %d s', time));
   xlabel('Frequency (Hz)');
   ylabel('Magnitude');
     
   %Adjust plot appearance
   grid on;
   xlim([0, fs2/2]);
    
 subplot(4,1,2);
    plot(frequencies, abs(F_carr_cell{indx}), 'm', 'LineWidth', 1.5);
    title(sprintf('Carrier Frequency Response @ %d s', time));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude')
     
   %Adjust plot appearance
    grid on;
    xlim([0, fs2/2]);
    
 subplot(4,1,3);
    plot(frequencies, abs(F_mod_cell{indx}), 'm', 'LineWidth', 1.5);
    title(sprintf('Modulator Frequency Response @ %d s', time));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
     
   %Adjust plot appearance
    grid on;
    xlim([0, fs2/2]);
         
%%%%% plot all frames for carrier

 for i = 1:length(F_carr_cell)

     t = frameSize*i/fs1;

     subplot(4,1,4);
     plot(frequencies, abs(vocoded_frames_cell{i}), 'm', 'LineWidth', 1.5);
     title(sprintf('Vocoded fequency Response @ %0.3f s', t));
     xlabel('Frequency (Hz)');
     ylabel('Magnitude');
 
     %Adjust plot appearance
     grid on;
     xlim([0, fs2/2]);
     ylim([0,0.3]);
 
     pause(1/fs1*frameSize);
 
 end
