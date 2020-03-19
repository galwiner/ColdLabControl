function state = Set776ControlPower(pwr,ndlist)
global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
if nargin<2
    ndlist = 7;
    p.Control776NDList = ndlist;
end
setPower = pwr;
attan = calculateAtten(ndlist);
load('Control776PowerVsAO.mat');
maxp = max(pwr)*attan;
minp = min(pwr)*attan;

if strcmpi(setPower,'max')
    setPower=maxp*1e3*0.999; %in [mW]
    p.control776Power = setPower;    
elseif strcmpi(pwsetPowerr,'min')
    setPower=minp*1e3*1.001; %in [mW]
    p.control776Power = setPower;
else
    p.control776Power = setPower;
end
p.s = sqncr;
p.s.addBlock({'set776ControlPower','value',p.control776Power,'duration',0});
p.s.runStep;
end
	