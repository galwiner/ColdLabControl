 function rate = rate2probePower_withND(powerOnAtoms,ND_list)
%g.w  2.7.19
%power in mW
global p
load('probePower2AO.mat');
calibrationFactor=4.58; %measured on 19/06/19
%powerAtoms=powerLaser*atten;
%calibration was done without attenuation
if nargin==1
    ND_list=[];
end
[atten,maxp,minp]=calculateAtten(ND_list); %maxp and minp are in nW
% pwr = pwr(8:end);
% V = V(8:end);
% if (any(power>max(pwr*1e3))||any(power<min(pwr*1e3)))
%     error('power must be between %0.2f and %0.2f!',min(pwr*1e3),max(pwr*1e3))
% end
rate=0.25*powerOnAtoms*1e-9;
laserPower=powerOnAtoms/atten/calibrationFactor;
if powerOnAtoms>maxp*1e-6 || powerOnAtoms<minp*1e-6
    error('required power is %.7f nW. At this ND setting power on atoms must be between %0.7f nW and %0.7f nW!',powerOnAtoms*1e6,minp,maxp)
end
AO=interp1(pwr,V,powerOnAtoms*1e-3/atten);
if isnan(AO)
    error('Bad probe power requirement');
end
end

