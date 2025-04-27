%% Vocoder
% High-level simulation of a Vocoder as proof of concept for FPGA
% implementation 
% Author: Hassan Islam 
% Date: 2024-02-15

% input audio files--200000 samples each. Files must be the same sample rate
[carr_signal, fs1] = audioread("./AudioFiles/synthCarrier.wav",[1,2200000]); % carrier signal
[mod_signal, fs2] = audioread("./AudioFiles/voxHassan.wav",[1,2200000]); % modulator signal

% Check and scale carrier and modulator signals 

max_amplitude = max(abs(carr_signal));
if max_amplitude > 1.0
    carr_signal = carr_signal / max_amplitude;
end

max_amplitude = max(abs(mod_signal));
if max_amplitude > 1.0
    mod_signal = mod_signal / max_amplitude;
end

% Apply a high-pass filter to remove low-frequency components
cutoff_frequency = 10; 
hp_filter = designfilt('highpassfir', 'FilterOrder', 100, 'CutoffFrequency', cutoff_frequency, 'SampleRate', fs1);
carr_signal = filter(hp_filter, carr_signal);
mod_signal = filter(hp_filter, mod_signal);

% Extract left channel and scale where needed and transform to column vector 
carr_signal = 0.5*0.3 * carr_signal(:, 1)'; % carrier
mod_signal = 0.5*mod_signal(:, 1)'; % modulator

N = length(mod_signal);
frameSize = 1000; % Length of time (in samples) of the Fourier transform captures (frames)
hopSize = 100; % overlap between frames, smaller values have a greater overlap. Note: greater overlaps increase the processing time but greater quality
numframe = ceil(N / frameSize);

%window = kaiser(frameSize); % Window to be applied to input signals
%periodicWindow = repmat(window, numframe, 1)'; % repeated to match length of signals
 
%carr_signal = carr_signal.*periodicWindow;
%mod_signal = mod_signal.*periodicWindow;

% Initialize cell arrays to store results
fft_carr_cell = cell(1, floor((N - frameSize) / hopSize) + 1);
fft_mod_cell = cell(1, floor((N - frameSize) / hopSize) + 1);

for i = 1:floor((N - frameSize) / hopSize) + 1
    startIdx = (i - 1) * hopSize + 1;
    endIdx = startIdx + frameSize - 1;

    % Extract a frame of the signal
    frame_carr = carr_signal(startIdx:endIdx);
    frame_mod = mod_signal(startIdx:endIdx);

    % Compute the Fourier Transform for each chunk
    fft_carr = fftshift(fft(frame_carr) / length(frame_carr)); % carrier
    fft_mod = fftshift(fft(frame_mod) / length(frame_mod)); % modulator

    % Store results in cell arrays
    fft_carr_cell{i} = fft_carr;
    fft_mod_cell{i} = fft_mod;
end

% Array to store envelope values 
envelope = zeros(length(fft_mod_cell{1}), length(fft_mod_cell));

% Find the amplitude for each bin per frame in the modulator wave 
for freq = 1:length(fft_carr_cell{1})
    for frame = 1:length(fft_carr_cell)
        envelope(freq, frame) = (fft_mod_cell{frame}(freq));
        % Each row is how the amplitude of the freq changes over time (frame to frame: left to right)
    end
end

% For every frame, set the max amplitude based on the modulator signal
for frame = 1:length(envelope(1, :)) % Iterate through all the frames
    for freq = 1:length(envelope(:, 1))

        % If the frequency in the carrier is larger than the frequency in
        % the modulator, apply a scaling factor corresponding to their ratio

        if (abs(fft_carr_cell{frame}(freq)) > abs(envelope(freq, frame)))

            fft_carr_cell{frame}(freq) = (abs(envelope(freq, frame)) / abs(fft_carr_cell{frame}(freq))) * fft_carr_cell{frame}(freq);

        end
    end
end

% Take the inverse Fourier transform of each chunk
vocoded_frames_cell = cell(1, length(fft_carr_cell));

for i = 1:length(fft_carr_cell)
    % Retrieve the modified frequency components
    modified_frame = ifft(ifftshift(fft_carr_cell{i})) * length(frame_carr);

    % Store the result in the cell array
    vocoded_frames_cell{i} = modified_frame;
end

% Apply cross-fading to smooth transitions between frames
fade_length = 200; % Adjust the fade length as needed

vocoded_signal = zeros(1, length(carr_signal));

for i = 1:length(vocoded_frames_cell)
    startIdx = (i - 1) * hopSize + 1;
    endIdx = startIdx + frameSize - 1;

    % Apply fade-in
    fade_in = linspace(0, 1, fade_length);
    vocoded_signal(startIdx:startIdx + fade_length - 1) = vocoded_signal(startIdx:startIdx + fade_length - 1) + fade_in .* vocoded_frames_cell{i}(1:fade_length);

    % Apply fade-out
    fade_out = linspace(1, 0, fade_length);
    vocoded_signal(endIdx - fade_length + 1:endIdx) = vocoded_signal(endIdx - fade_length + 1:endIdx) + fade_out .* vocoded_frames_cell{i}(end - fade_length + 1:end);

    % Overlap and add frames
    vocoded_signal(startIdx + fade_length:endIdx - fade_length) = vocoded_signal(startIdx + fade_length:endIdx - fade_length) + vocoded_frames_cell{i}(fade_length + 1:end - fade_length);
end

outputVolume = 0.5; % adjust as needed

outputSampleRate = fs1;

% Play the smoothed signal
sound(outputVolume * vocoded_signal, outputSampleRate);

%audiowrite("vocodedResult3.wav", outputVolume * vocoded_signal, outputSampleRate);
