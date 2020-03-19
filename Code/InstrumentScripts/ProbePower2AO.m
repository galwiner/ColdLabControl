function AO = ProbePower2AO(power_on_atoms,varargin)
%power in mW! (1nW = 1e-6)
% need to measure the calibration curve!

%there's a 21% attenuation on the atoms compared to the probe power after
%the DP. ATTN with ND=6.3 = 5e-5
load('probeCalData.mat');
% figure;
% pwr=pwr(1:27);
% V=V(1:27);
% plot(pwr,V,'o-r')
% pwr1=linspace(min(pwr),max(pwr),1000);
% V1=interp1(pwr,V,pwr1);
% hold on
% plot(pwr1,V1,'o-k')
powerDP=1e-3*power_on_atoms/5e-5/0.21;

if (any(powerDP>23) || any(powerDP<0))
    error('power output cannot exceed 23mW and must be positive.'); %on 03/05/18 this was the case... update as necessary
end

% inversefunc=@(powerDP) atanh((powerDP-d)/a)/b + c;
AO=interp1(pwr,V,powerDP);
if isnan(AO)
error('Bad probe power requirement');
end



end

