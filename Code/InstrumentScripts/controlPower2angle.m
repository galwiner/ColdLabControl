 function angleOut = controlPower2angle(powerOnAtoms,ND_list)
%L.D and T.Z 04/03/2020
%power in mW
global p
load('controlAngle2Power.mat');
%calibration was done without attenuation
if nargin==1
    ND_list=[];
end
if ~isempty(ND_list) && any(ND_list~=(15)&ND_list~=(16))
    error('for 480 nm only ND# 15 and 16 are OK')
end
[atten,maxp,minp]=calculateAtten(ND_list,'control'); %maxp and minp are in mW
if powerOnAtoms>maxp || powerOnAtoms<minp
    error('required power is %.2d mW. At this ND setting power on atoms must be between %0.2d mW and %0.2d mW!',powerOnAtoms,minp,maxp)
end
angleOut=interp1(pwr,Angle,powerOnAtoms*1e-3/atten);
if isnan(angleOut)
    error('Bad probe power requirement');
end
end

