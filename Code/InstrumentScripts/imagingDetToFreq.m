function freq = imagingDetToFreq(det)
%det is in units of MHz
%function to calculate the DDS frequence for a given detuning for the
%cooling laser (5S1/2 F=2 to 5P3/2 F'=3) in Rb87
%We assume that the Master laser is locked to the F=3 F'=4 transition in Rb85

% freq in MHz
%new master
Master_freq = 3.842271058e+08; %measured on 03/10/18 using sas
laserFreq = Master_freq+1.2112e+03; %1.2112 GHz is the detuning of the cooling laser
fineSplit_freq = 384230484.4685; %5S(1/2) to 5P(3/2) Rb 87
Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
Resonant_freq = Resonant_freq+193.7408; %F'=3 in the upper manifold is shifted up
freq = laserFreq-Resonant_freq-det;
freq = freq/2; %due to double pass AOM
end

