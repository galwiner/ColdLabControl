function state = set776ControlPower(pwr,ndlist)
global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
if nargin==2
    p.Control776NDList = ndlist;
end
p.probePower = pwr;
p.s = sqncr;
p.s.addBlock({'set776ControlPower','duration',0,'value',pwr,'channel','ImagingVVAN'});
p.s.runStep;
end
	