 function AO = Control776Power2AO(power,varargin)
%L.D&T.Z  17.04.19
%power in mW
global p
load('Control776PowerVsAO.mat');
% pwr = pwr(8:end);
% V = V(8:end);
if nargin>1
    ndList = varargin{1};
else
    ndList = [];
end
attan = calculateAtten(ndList);
power = power/attan;
if (any(power>max(pwr*1e3))||any(power<min(pwr*1e3)))
    error('power must be between %0.2f and %0.2f mW, you asked for %0.3f mW!',min(pwr*1e3)*attan,max(pwr*1e3)*attan,power*attan)
end
AO=interp1(pwr,V,power*1e-3);
if isnan(AO)
    error('Bad imaging power requirement');
end
end

