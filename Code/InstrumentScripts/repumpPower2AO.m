function AO = repumpPower2AO(power,varargin)
%L.D G.W 8/1/19
%power is in mW
power = power*1e-3; %move to W
load('rpmpAO2PowerData.mat');
pwr=pwrVals;
V=voltageVals;
if any(power<0)
    error('power output cannot be negative. (cooling beams)'); 
end
if any(power>max(pwr))
    warning('Requested %0.2d but maximal cooling power is %0.2d. Setting power to maximum',power*1e3,max(pwr)*1e3)
    power = max(pwr);
end
if any(power<min(pwr))
    warning('Requested %0.2d but minimal cooling power is %0.2d. Setting power to minimum',power*1e3,min(pwr)*1e3)
    power=min(pwr);
end

AO=interp1(pwr,V,power);
if isnan(AO)
    error('Bad cooling power requirement');
end
end

