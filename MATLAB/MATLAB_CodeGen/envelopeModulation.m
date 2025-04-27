% file: envelopeModulation.m
% envelope modulation for vocoder processing 
% Author: Hassan Islam 
% Date: 2024-02-20

%{
Function: evnelopeModulation
descp:
        Modulation of carrier signal amplitude based on the envelope of
        the modulation signal. This is the basis of vocoding. 
%}
%#codegen
function [yOut,validOut] = envelopeModulation(tMod, ...
    tCarr, ...
    validIn)

  % Fourier transform
  [fftMod,validOut] = moduleFFT1(tMod,validIn);
  [fftCarr,~] = moduleFFT2(tCarr,validIn);

%{
Compare absolute value of complex outputs from fourier transform and adjust
magnitude of carrier signal if it is greater than the magnitude of the
modulator wave. 
%}

  [validOut, x, y] = envelopeFFTmodulation(fftMod, validOut, fftCarr);
 
  % Inverse Fourier transform
  [yOut,validOut] = moduleIFFT(complex(x,y), validOut);


%%%%%%%%%%%%%%%%%%%%%%% External functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
Function: moduleFFT1
descp:
        instantiation of Fast Fourier transform object for HDL codegen
%}
%#codegen
function [yOut, validOut] = moduleFFT1(yIn,validIn)

  persistent fft128;
  if isempty(fft128)
    fft128 = dsphdl.FFT(BitReversedOutput=false, FFTLength=1024);
  end    
  [yOut,validOut] = fft128(yIn,validIn);


%{
Function: moduleFFT2
descp:
        instantiation of 2nd Fast Fourier transform object for HDL codegen 
%}
%#codegen
function [yOut, validOut] = moduleFFT2(yIn,validIn)

  persistent fft128_2;
  if isempty(fft128_2)
    fft128_2 = dsphdl.FFT(BitReversedOutput=false, FFTLength=1024);
  end    
  [yOut,validOut] = fft128_2(yIn,validIn);


%{
Function: moduleIFFT
descp:
        instantiation of Inverse Fast Fourier transform object for HDL codegen 
%}
%#codegen
function [yOut, validOut] = moduleIFFT(yIn, validIn)

  % ifft of processed signal 
  persistent ifft128;
  if isempty(ifft128)
    ifft128 = dsphdl.IFFT(FFTLength=1024);
  end    
  [yOut,validOut] = ifft128(yIn,validIn); 

%{
Function: Complex2Mag
descp:
        instantiation of complex2Mag object for HDL codegen
%}
%#codegen
function [mag,validOut] = Complex2Mag(yIn,validIn)

  persistent cma;
  if isempty(cma)
    cma = dsphdl.ComplexToMagnitudeAngle(OutputFormat ='Magnitude');
  end   
  [mag,validOut] = cma(yIn,validIn);

%{
Function: Complex2Mag_2
descp:
        instantiation of 2nd complex2Mag object for HDL codegen
%}
%#codegen
function [mag,angle,validOut] = Complex2Mag_2(yIn,validIn)

  persistent cma2;
  if isempty(cma2)
    cma2 = dsphdl.ComplexToMagnitudeAngle(AngleFormat='Radians');
  end   
  [mag,angle,validOut] = cma2(yIn,validIn);


%{
%% Design Note

executing a function multiple times does not necessarily instantiate
multiple hardware modules. Rather than instantiating multiple hardware
modules,multiple calls to a function typically update the state variable.
to generate multiple hardware modules corresponding to each execution of a 
local function, specify two different local functions with the same code 
but different function names. To avoid code duplication, 
consider using System objects to implement the behavior in the function, 
and instantiate the System object™ multiple times.
%}

%#codegen
function [validOut, x, y] = envelopeFFTmodulation(fftMod, validOut, fftCarr)
[fftMod_mag, ~] = Complex2Mag(complex(real(fftMod),imag(fftMod)), validOut);
[fftCarr_mag, angle, validOut] = Complex2Mag_2(complex(real(fftCarr),imag(fftCarr)), validOut);

if (fftCarr_mag > fftMod_mag)
    fftCarr_mag = fftMod_mag;
end   
[x , y] = cordicpol2cart(angle,fftCarr_mag); 
