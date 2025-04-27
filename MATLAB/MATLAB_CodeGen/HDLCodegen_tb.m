% file: HDLCodegen_tb.m
% test bench to evaluate FFT and IFFT outputs from CODEGEN
% Author: Hassan Islam 
% Date: 2024-03-04

%%%%%%%%%%%%%%%%%%%%%%%% Description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Test bench compares the output from the FFT and IFFT System Verilog
modules generated from Matlab's native CODEGEN, to the 
expected results. Input test vector is a single sine
wave at 1 kHz stored in "HDLtestVector.dat". Since the FFT and IFFT are 
inverse operations, we expect the output of the Sytem Verilog modules 
to be the same as the Input test vector. 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; 

% load in result vector from /FPGA/FFT128/hdlsrc 
data_out = load('../../FPGA/FFT1024/hdlsrc/yResult_re_IFFT.dat');
data_valid = load('../../FPGA/FFT1024/hdlsrc/yResult_ValidOut.dat');

% data extracted from when first output is valid  
data_out = data_out(data_valid == 1); 

frame_size = 1024; % frame size
frame_num = floor(length(data_out)/frame_size); % number of frames in sample data

Fs = 40000; % sampling rate
t = (0:frame_size-1)'/(Fs);

% Expected values
sinewave = (2^16-1)/2*(sin(2*pi*1000*t)+1);
%%sinewave = fi(sinewave,0,16,0);

% failure flag
fail = 0;

% Allow for error in comparison between expected and result
error = 5 ;

for i=1:length(data_out)/frame_size

    % re-ordering of bit index, an artifact of the FFT and IFFT operations
    data = bitrevorder(data_out((1+frame_size*(i-1)):(i)*frame_size)); 

    % test if data is within error range of sine
    range = ((sinewave-error) < data) & (data < (sinewave+error));

    if range
        fail; 
    else 
        fail = 1;
        fprintf("\nFailed on i = %d",i)
        fail_vector = data(range == 0);
    end 

end

% test results
if(fail == 1)
   fprintf("\n\n******TestBench FAILED******\nTolerance value = +-%.2f\n****************************",error);
   fprintf("\nfail_vector generated. Lists all values that did not meet threshold\n\n\n")
else 
   fprintf("\n\n******TestBench PASSED******\nTolerance value = +-%.2f\n****************************\n\n\n",error);
end
    
% plot single frame (128 points) of data
figure;

% expected values
subplot(2,1,1);
plot(t,sinewave);
title('Expected Result')
xlabel('Frequency (Hz)')
ylabel('Output of IFFT (f)')


data = bitrevorder(data_out((1:1024))); 

% output data plot
subplot(2,1,2)
plot(t,data);
title('FFT and IFFT Result from HDL generated Code ')
xlabel('Frequency (Hz)')
ylabel('Output of IFFT (f)')