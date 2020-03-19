function state = Set480ControlPower(pwr)
global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
setPower = pwr;
load('Control480PowerVsAO.mat');
maxp = max(pwr);
minp = min(pwr);

if strcmpi(setPower,'max')
   
    setPower=maxp*1e3; %in [mW]
    p.controlPower = setPower;    
elseif strcmpi(pwsetPowerr,'min')
    setPower=minp*1e3; %in [mW]
    p.controlPower = setPower;
else
    p.controlPower = setPower;
end
p.s = sqncr;
p.s.addBlock({'set480ControlPower','value',p.controlPower,'duration',0});
p.s.runStep;
end
	