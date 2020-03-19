function dispensersState(state)
global inst
global p
initp
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
p.hasScopResults=0;
if state==1
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DispenserSwitch','duration',0,'value','high'});
p.s.runStep;
fprintf('Dispenser state ON\n');
elseif state==0
p.s = sqncr;
p.s.addBlock({'setDigitalChannel','channel','DispenserSwitch','duration',0,'value','low'});
p.s.runStep;
fprintf('Dispenser state OFF\n');
else 
    error('set state to 1 or 0');
end



