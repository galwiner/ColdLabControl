 function AO = ImagingPower2AO(power,varargin)
%L.D  14.10.18
%power in uW
global p
load('ImagingPowerVsAO.mat');
% pwr = pwr(8:end);
% V = V(8:end);
if (any(power>max(pwr*1e6))||any(power<min(pwr*1e6)))
    error('power must be between %0.2f and %0.2f!',min(pwr*1e6),max(pwr*1e6))
end
AO=interp1(pwr,V,power*1e-6);
if isnan(AO)
    error('Bad imaging power requirement');
end
end

