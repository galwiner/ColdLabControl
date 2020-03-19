function freq = coolingDetToFreq(det,multiplier)
if nargin==1
    multiplier=1;
end
%det is in units of MHz
%function to calculate the DDS frequence for a given detuning for the
%cooling laser (5S1/2 F=2 to 5P3/2 F'=3) in Rb87
%We assume that the Master laser is locked to the F=3 F'=4 transition in Rb85

% freq in MHz
%old master
% Master_freq = 384230406.373; %Only the 5S1/2 to p3/2 transition in Rb85
% Master_freq = Master_freq -1264.8885163; %Move to the F=3 level
% Master_freq = Master_freq +100.205; %Move to the F'=4 level
%new master
Master_freq = 3.842271058e+08; %measured on 03/10/18 using sas
fineSplit_freq = 384230484.4685; %5S(1/2) to 5P(3/2) Rb 87
Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
Resonant_freq = Resonant_freq+193.7408; %F'=3 in the upper manifold is shifted up
AOM_shift=-220; %was changed from +220 on 16.12.18. double pass AOM at 110MHz order -1,-1. atoms see 220MHz les than the lock freq so the lock needs to be lower than the res freq.

freq_on_atoms=Resonant_freq+det;
freq_on_WLM=freq_on_atoms-AOM_shift; %because the AOM shifts us -220 MHZ we want to select a laser freq that is 220MHZ below that point
freq=abs((Master_freq-freq_on_WLM))/multiplier; % freq we set for the RF (the beat note freq with the master)

% freq=abs(Resonant_freq-AOM_shift+det-Master_freq)/multiplier;

end

