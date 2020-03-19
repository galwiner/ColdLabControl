function state = SetProbePower(pwr,ndlist)
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
    ndlist = p.probeNDList;
end
if strcmpi(pwr,'max')
    [~,maxp,minp]=calculateAtten(ndlist);
    pwr=maxp*1e-6; %in [mW]
    p.probeNDList = ndlist;
elseif strcmpi(pwr,'min')
    [~,maxp,minp]=calculateAtten(ndlist);
    pwr=minp*1e-6; %in [mW]
    p.probeNDList = ndlist;
else
    p.probeNDList = ndlist;
    p.probePower = pwr;
end
p.s = sqncr;
p.s.addBlock({'setProbePower','duration',0,'value',pwr,'channel','PRBVVAN'});
p.s.runStep;
end
	
