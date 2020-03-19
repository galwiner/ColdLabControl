 function AO = Control776Power2AO_withND(powerOnAtoms,ND_list)
%g.w  13.2.19
%power in mW
global p
load('Control776PowerVsAO.mat');

%powerAtoms=powerLaser*atten;
%calibration was done without attenuation
if nargin==1
    ND_list=[];
end
atten=calculateAtten(ND_list); %maxp and minp are in nW
% pwr = pwr(8:end);
% V = V(8:end);
% if (any(power>max(pwr*1e3))||any(power<min(pwr*1e3)))
%     error('power must be between %0.2f and %0.2f!',min(pwr*1e3),max(pwr*1e3))
% end

laserPower=powerOnAtoms/atten;
if (any(laserPower>max(pwr*1e3))||any(laserPower<min(pwr*1e3)))
    error('required power is %.5f mW. At this ND setting power on atoms must be between %0.5f mW and %0.5f mW!',powerOnAtoms,min(pwr*1e3*atten),max(pwr*1e3*atten))
end
AO=Control776Power2AO(laserPower);
end

