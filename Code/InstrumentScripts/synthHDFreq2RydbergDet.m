function det = synthHDFreq2RydbergDet(freq,n,varargin)
if nargin==1
n = 101;
end
if nargin>2
    l = varargin{1};
    if nargin>3
         order = varargin{2};
    else
       order = 1;
    end
else
    l = 0;
    order = 1;
end
%freq of resonance, known from EIT
switch l
    case 0
        switch n
            case 101
                resFreq = 395.2*2;
            case 91
                resFreq = 1370;
            case 92
                resFreq = 162;
            case 80
                resFreq = 1100; %coupling to -1 order (scan backwards!)
        end
    case 1
        switch n
            case 90
                resFreq = 379.5; %taken from data of 090320_08__depletion_spectroscopy_zoom_in 
        end
    case 2
        switch n
            case 89
                resFreq = 2326/2; %taken from data of 090320_08__depletion_spectroscopy_zoom_in 
        end
    case 3
        switch n
            case 90
                resFreq = 702.5; %taken from data of 090320_08__depletion_spectroscopy_zoom_in 
        end
end
det = order*(freq-resFreq)*2;
end
