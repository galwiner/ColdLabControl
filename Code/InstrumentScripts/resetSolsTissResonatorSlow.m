function  resetSolsTissResonatorSlow(startVal,endVal)
global p
dv = 0.5e-1;
dt = 0.1;
diraction = endVal-startVal;
step = dv*diraction;
vals = startVal:step:endVal;
for ii = 1:length(vals)
   setAnalogChannel(p.chanNames.SolsTisSlow,vals(ii));
   pause(dt);
end
end
