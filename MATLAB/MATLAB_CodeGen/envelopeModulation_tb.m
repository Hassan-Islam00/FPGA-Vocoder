% file: envelopeModulation_tb.m
% test bench for envelope modulation 
% Author: Hassan Islam 
% Date: 2024-02-20

%%%%%%%%%%%%%%%%%%%%%%%% Description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
A testbench for a vocoder. Inputs a vocal recording by yours truly and a
synthesizer sample into the envelopeModulation module--this test-bench is
also used to generate an HDL test bench that is used to verify the HDL
generated version of envelopeModulation. 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%clear all; 

audioLength = 1; % integer value that will be multiplied by FFT sample length
N = 1024; % Number of samples for FFT and IFFT

[~, fs1] = audioread("../MATLAB_Concept_Code/AudioFiles/synthCarrier.wav",[1,N*audioLength]); % carrier signal
[~, fs2] = audioread("../MATLAB_Concept_Code/AudioFiles/voxHassan.wav",[1,N*audioLength]); % modulator signal

ADC_bitSize = 12;

Fs = fs1; % Sampling Rate
t = 0:1/fs1:((N*audioLength-1)*1/Fs);% time for plots

% Input values
sinewave = (2^ADC_bitSize-1)/2*(sin(2*pi*1000*t)+1);
sinewave2 = (2^ADC_bitSize-1)/2*(sin(2*pi*1000*t + pi/2)+1);
sinewave = fi(sinewave,0,ADC_bitSize,0); % fixed point conversion
sinewave2 = fi(sinewave2,0,ADC_bitSize,0); % fixed point conversion

carrX = sinewave;
modX = sinewave2;

% Extract left channel
% carrX = carrX(:, 1)'; % carrier
% modX = modX(:, 1)'; % modulator

% Plot of carrier signal before processing
figure

subplot(2,1,1)
plot(t,carrX);
title('input carr(t) before FFT and IFFT')

% Plot of modulator signal before processing
subplot(2,1,2)
plot(t,modX);
title('input mod(t) before FFT and IFFT')

Yj = zeros(1,audioLength*N);

% input signals into envelopeModulation
for j = 1:audioLength
    Yf = zeros(1, 5*N);
    validOut = false(1, 5*N);
    for loop = 1:5*N
        i = mod(loop, N);
        if i == 0
            i = N;
        end
        [Yf(loop), validOut(loop)] = envelopeModulation(complex(modX((j-1)*N + i)), ...
            complex(carrX((j-1)*N + i)), (loop <= N));
    end

    % delete invalid outpts
    Yf = Yf(validOut == 1);
    % reverse bit index of result vector
    Yr = bitrevorder(Yf);

    % Store Yf results in Yj for each iteration
    startIndex = (j - 1) * N + 1;
    endIndex = startIndex + N - 1;
    Yj(startIndex:endIndex) = Yr;
end

% Output Vocoded result
sound(real(Yj), fs1);

audiowrite("vocodedResult2.wav",real(Yj) , fs1);

% Plot of envelope modulation result
figure

subplot(2,1,1)
plot(t,real(Yj))
title('output after FFT and IFFT')

% Plot of expected modulation result
subplot(2,1,2)
plot(t,(carrX))
title('expected output after FFT and IFFT')

