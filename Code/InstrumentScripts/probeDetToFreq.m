function freq = probeDetToFreq(det,multiplier,varargin)

if nargin==1
    multiplier=1;
end

if length(varargin)~=0
    lowerLevel=varargin{1};
    upperLevel=varargin{2};
else
    lowerLevel=2;
    upperLevel=3;
end


%det is in units of MHz
%function to calculate the DDS frequence for a given detuning for the
%probe laser (5S1/2 F=2 to 5P3/2 F'=3) in Rb87
%We assume that the Master laser the "new" master laser and that it's
%frequency is 384.23338.
% freq in MHz
Master_freq = 3.842271058e+08; %measured on 03/10/18 using sas

fineSplit_freq = 384230484.4685; %5S(1/2) to 5P(3/2) Rb 87
if lowerLevel==2 && upperLevel==3
    Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
    Resonant_freq = Resonant_freq+193.7408; %F'=3 in the upper manifold is shifted up
elseif lowerLevel==2 && upperLevel==2
    Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
    Resonant_freq = Resonant_freq-72.9113; %F'=2 in the upper manifold is shifted down
elseif lowerLevel==2 && upperLevel==1
    Resonant_freq= fineSplit_freq - 2563.005979089; %F=2 in the lower state is shifted up
    Resonant_freq = Resonant_freq-229.8518; %F'=1 in the upper manifold is shifted up    
elseif lowerLevel==1 && upperLevel==2
        Resonant_freq= fineSplit_freq + 4271.676631815; %F=1 in the lower state is shifted down
        Resonant_freq = Resonant_freq-72.9113; %F'=2 in the upper manifold is shifted down
elseif lowerLevel==1 && upperLevel==1
        Resonant_freq= fineSplit_freq + 4271.676631815; %F=1 in the lower state is shifted down
        Resonant_freq = Resonant_freq-229.8518; %F'=1 in the upper manifold is shifted down
elseif lowerLevel==1 && upperLevel==0
        Resonant_freq= fineSplit_freq + 4271.676631815; %F=1 in the lower state is shifted down
        Resonant_freq = Resonant_freq-302.0738; %F'=0 in the upper manifold is shifted down
else
    error('bad choice of transition level, or transition not implemented in probeDetToFreq');    
end
    


AOM_shift=400; %double pass AOM at 200MHz order +1,+1. atoms see 400MHz more than the lock freq so the lock needs to be lower than the res freq.

freq_on_atoms=Resonant_freq+det;
freq_on_WLM=freq_on_atoms-AOM_shift; %because the AOM shifts us +220 MHZ we want to select a laser freq that is 220MHZ below that point
freq=abs((Master_freq-freq_on_WLM)/multiplier); % freq we set for the RF (the beat note freq with the master)

% freq=abs(Resonant_freq-AOM_shift+det-Master_freq)/multiplier;

end

