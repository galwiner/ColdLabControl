function probePower = AO2ProbePower(AO)
%power in mW! (1nW = 1e-6)
% need to measure the calibration curve!

%there's a 21% attenuation on the atoms compared to the probe power after
%the DP. ATTN with ND=6.3 = 5e-5
% 
% powerDP=power_on_atoms/5e-5/0.21;
% 
% if (any(powerDP>30) || any(powerDP<0))
%     error('power output cannot exceed 30mW and must be positive.'); %on 03/05/18 this was the case... update as necessary
% end


a=16.05;
b=0.8259;
c=2.186;
d=14.51;
% 
AOtoProbe=@(x) a*tanh(b*(x-c))+d; %based on fit to tanh performed on 03/05/18 
% inversefunc=@(powerDP) atanh((powerDP-d)/a)/b + c;
% AO=inversefunc(powerDP);
probePower=5e-5*0.21*AOtoProbe(AO);

end

