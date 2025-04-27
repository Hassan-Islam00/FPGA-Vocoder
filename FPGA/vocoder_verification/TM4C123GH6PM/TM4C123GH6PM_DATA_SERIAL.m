% file: TM4C123GH6PM_SerialDATA
% Author: Hassan Islam 
% Date: 2024-03-04

%%%%%%%%%%%%%%%%%%%%%%%% Description %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Stores data from serial COMM port. Streamed from TM4C123GH6PM
microcontroller, which records output BINARY data from FPGA FFT modules. 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear s

bit_size = 5; 

num_samples = 50;

newLine_characters = (num_samples/bit_size);

s = serialport("COM4",115200);

serialData = read(s,num_samples*bit_size + newLine_characters,"string");

clear s

% Open a file for writing
fileID = fopen('FPGAout.dat', 'w');

% Write the string to the file
fprintf(fileID, '%s', serialData);

% Close the file
fclose(fileID);
