function state = setDTbeamPower(pwr,beam)
%pwr in W
global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
if nargin==1
    beam = 'blue';
end
if strcmpi(beam,'b')
    beam = 'blue';
elseif strcmpi(beam,'p')
    beam = 'purple';
elseif strcmpi(beam,'both')
    beam = 'both';
end
p.s = sqncr;
switch lower(beam)
    case 'blue'
        p.s.addBlock({'setBlueDTPower','duration',0,'value',pwr});
    case 'purple'
        p.s.addBlock({'setPurpleDTPower','duration',0,'value',pwr})
    case 'both'
        p.s.addBlock({'setBlueDTPower','duration',0,'value',pwr});
        p.s.addBlock({'setPurpleDTPower','duration',0,'value',pwr})
end
p.s.runStep;
end
	
