function AO = zeemanRepumpPower2AO(power_on_atoms,ND)
%power in mW!
if nargin ==1
    ND = [];
end
load('ZeemanRepumpPower2AO.mat');
[atten,mx,mn]=calculateAtten(ND,'zeemanRepump');
power=1e-3*power_on_atoms;

if (any(power_on_atoms>mx) || any(power_on_atoms<mn))
    error('required power is %0.2d mW. At this ND setting power on atoms must be between %0.2d mW and %0.2d mW!',power_on_atoms,mn,mx)
end
AO=interp1(pwr,V,power/atten);
if isnan(AO)
error('Bad zeeman repump power requirement');
end
end

