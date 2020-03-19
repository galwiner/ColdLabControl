function state = setControlPower(pwr,ndlist)
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
    ndlist = [];
end
if strcmpi(pwr,'max')
    [~,maxp,minp]=calculateAtten(ndlist,'control');
    pwr=maxp*0.99;
elseif strcmpi(pwr,'min')
    [~,maxp,minp]=calculateAtten(ndlist,'control');
    pwr=minp*1.01;
end
p.s = sqncr;
if isempty(ndlist)
    p.s.addBlock({p.asyncActions.setControlPower,'power',pwr});
else
    p.s.addBlock({p.asyncActions.setControlPower,'power',pwr,'ND',ndlist});
end
p.s.runStep;
end
	
