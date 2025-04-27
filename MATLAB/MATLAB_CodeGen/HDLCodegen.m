% file: HDLCodegen.m
% Stimulates FFT128, IFFT128 Matlab modules with values.
% Author: Hassan Islam 
% Date: 2024-03-04

%%%%%%%%%%%%%%%%%%%%%%%% Description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
This program stimulates FFT128, IFFT128 Matlab modules with input data
which is used to define data types of FFT128, IFFT128 System Verilog
Codegen. Conversion from floating to fixed point values. This also
generates HDLtestVector.dat file for System Verilog testing. 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ADC_bitSize = 16; % size of ADC being used 

N = 1024; % frame size
Fs = 40000; % sampling rate
t = (0:N-1)'/Fs;

% Input values
%%sinewave = (2^ADC_bitSize-10000)/2*(sin(2*pi*1000*t)+1) + 8000;
sinewave = (2^ADC_bitSize-1)/2*(sin(2*pi*1000*t)+1);
sinewave = fi(sinewave,0,ADC_bitSize,0); % fixed point conversion

figure
plot(t,sinewave);

% input to FFT128.m module
Yf = zeros(1,4*N);
validOut = false(1,4*N);
for loop = 1:1:4*N
    if (mod(loop, N) == 0)
        i = N;
    else
        i = mod(loop, N);
    end
    [Yf(loop),validOut(loop)] = FFT1024(complex(sinewave(i)),(loop <= N));
end

figure

Yf = Yf(validOut == 1); % output of FFT128.m 

% plot of FFT128.m output
plot(Fs/2*linspace(0,1,N/2), 2*abs(Yf(1:N/2)/N))
title('Single-Sided Amplitude Spectrum ')
xlabel('Frequency (Hz)')
ylabel('Output of FFT (f)')


% IMPORTANT ADJUST THE FI LENGTH TO MATCH VECTOR SIZE OF FFT OUTPUT IF FFT SIZE IS CHANGED
Yf = fi(Yf,1,27); % fixed point conversion, input to IFFT128.m

% input to IFFT128.m module
Yj = zeros(1,4*N);
validOut = false(1,4*N);
for loop = 1:1:4*N
    if (mod(loop, N) == 0)
        i = N;
    else
        i = mod(loop, N);
    end
    [Yj(loop),validOut(loop)] = IFFT1024(complex(Yf(i)),(loop <= N));
end

Yj = Yj(validOut ==1); % output of IFFT128.m
Yj = bitrevorder(Yj);
Yj = fi(Yj,0,24);

% plot of IFFT128.m output
figure;
plot(t,real(Yj));
title('Output of IFFT128 ')
xlabel('time (s)')
ylabel('Output of IFFT (f)')

