function freq = repumpDetToFreq(det,multiplier)
%function to calculate the DDS frequence for a given detuning for the
%repump laser (5s1/2 F=1 to 5P3/2 F'=2)
%Det is in units of Gamma where Gamma = 2? · 6.065(9) MHz
% freq in MHz
Master_freq = 384230406.373; %Only the 5S1/2 to p3/2 transition in Rb85
Master_freq = Master_freq -1264.888; %Move to the F=3 level
Master_freq = Master_freq +100.205; %Move to the F'=4 level

fineSplit_freq = 384230484.4685; %5S(1/2) to 5P(3/2)
Resonant_freq= fineSplit_freq + 4271.67663181519; %F=1 in the lower state is shifted down
Resonant_freq = Resonant_freq-72.9113; %F'=2 in the upper manifold is shifted down
AOM_shift=0; %single pass at 110 in the -1 order 

freq=abs(Resonant_freq-AOM_shift+det-Master_freq)/multiplier;

end