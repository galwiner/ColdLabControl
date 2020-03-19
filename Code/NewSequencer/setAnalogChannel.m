function value = setAnalogChannel(chan,value)
if value<-10 || value>10
    error('value must be between -10:+10! you entered %0.2d',value)
end
global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
if ~any(strcmp(p.ct.Row,chan))
    error('%s is not in channle table!',chan)
end
D_A = p.ct.D_A(find(strcmpi(p.ct.Row,chan)));
if strcmpi(D_A,'D')
    error('%s is an digital channle. setAnalogChannel works only for analog channles')
end
p.s  = sqncr;
p.s.addBlock({'setAnalogChannel','duration',0,'value',value,'channel',chan});
p.s.runStep;
end
	
