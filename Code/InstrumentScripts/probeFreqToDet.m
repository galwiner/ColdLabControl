function det = probeFreqToDet(freq,multiplier,varargin)
%this function inverts the function probeDetToFreq. multiplier is the PLL
%myltiplier (8 is the usual case)
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
if nargin>2
    freqs = probeDetToFreq(-500:500,multiplier,varargin);
else
    freqs = probeDetToFreq(-500:500,multiplier);
end
det = interp1(freqs,-500:500,freq);
end

