function state = SetZeemanPower(pwr,ndlist)
global inst
global p
if ~isfield(inst,'KeithleyPSU')
    inst.KeithleyPSU = KeithleyPSU('com24');
    inst.KeithleyPSU.setOutput('on'); %set output to 'on'
end
if nargin<2
    ndlist = [];
end
if strcmpi(pwr,'max')
    [~,maxp,minp]=calculateAtten(ndlist,'zeemanPump');
    pwr=maxp*0.99; %in [mW]
    p.zeemanPumpNDList = ndlist;
elseif strcmpi(pwr,'min')
    [~,maxp,minp]=calculateAtten(ndlist,'zeemanPump');
    pwr=minp*1.01; %in [mW]
    p.zeemanPumpNDList = ndlist;
else
    p.zeemanPumpNDList = ndlist;
    p.zeemanPumpPower = pwr;
end
p.s = sqncr;
p.s.addBlock({'setZeemanPumpPower','duration',0,'value',pwr,'ND',ndlist});
p.s.runStep;
end
	
