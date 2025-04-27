%% TimePlots
% Waveform Plots for Vocoder  
% Author: Hassan Islam 
% Date: 2024-02-15

%%%%% Plot time-domain signals

    % parameters
    t = 0:1/fs1:((length(carr_signal)-1)*1/fs1); 
    
    figure;
    subplot(3,1,1);
    plot(t, carr_signal, 'b', 'LineWidth', 1.5);
    title('Synth (Carrier Wave)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    subplot(3,1,2);
    plot(t, mod_signal, 'r', 'LineWidth', 1.5);
    title('Voice (Modulator wave)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    subplot(3,1,3);
    plot(t, vocoded_signal, 'r', 'LineWidth', 1.5);
    title('Vocoded wave');
    xlabel('Time (s)');
    ylabel('Amplitude');


