function setProbeLockScan(center,span,scanTime)

global inst
global p
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    initp
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
p.s  = sqncr;
p.s.addBlock({'SetupDDSSweepCentSpan','center',probeDetToFreq(center,1),'channel',2,'multiplyer',8,'UpTime',scanTime,'span',span});
p.s.runStep;
end
	