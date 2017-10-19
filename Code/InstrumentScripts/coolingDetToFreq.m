function freq = coolingDetToFreq(det,multiplier)
%det is in units of MHz
%function to calculate the DDS frequence for a given detuning for the
%cooling laser (5S1/2 F=2 to 5P3/2 F'=3) in Rb87
%We assume that the Master laser is locked to the F=3 F'=4 transition in Rb85

% freq in MHz
Master_freq = 384230406.373; %Only the 5S1/2 to p3/2 transition in Rb85
Master_freq = Master_freq -1264.888; %Move to the F=3 level
Master_freq = Master_freq +100.205; %Move to the F'=4 level

fineSplit_freq = 384230484.4685; %5S(1/2) to 5P(3/2) Rb 87
Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
Resonant_freq = Resonant_freq+193.7408; %F'=3 in the upper manifold is shifted up
AOM_shift=220; %double pass AOM at 110MHz order +1,+1. atoms see 220MHz more than the lock freq so the lock needs to be lower than the res freq.

% freq=abs(Resonant_freq-AOM_shift+det-Master_freq)/multiplier;
freq=(Master_freq+AOM_shift-Resonant_freq+det)/multiplier;
end

