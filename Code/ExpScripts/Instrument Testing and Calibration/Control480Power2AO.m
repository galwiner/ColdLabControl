 function AO = Control480Power2AO(power,varargin)
%power in mW
global p
load('Control480PowerVsAO.mat');
if (any(power>max(pwr*1e3))||any(power<min(pwr*1e3)))
    error('power must be between %0.2f and %0.2f mW, you asked for %0.3f mW!',min(pwr*1e3),max(pwr*1e3),power)
end
AO=interp1(pwr,V,power*1e-3);
if isnan(AO)
    error('Bad imaging power requirement');
end
end

