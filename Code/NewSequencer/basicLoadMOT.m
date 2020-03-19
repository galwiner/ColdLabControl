%Load MOT, cameras in live mode, 40A circular coil
global p
global inst
% initp
try
    strcmpi(inst.com.TcpID.Status,'open');
catch 
    instrreset
    inst.com=Tcp2Labview('10.10.10.1',6340);
end
% p.hasScopResults=0;
% p.hasPicturesResults=0;
% p.pfLiveMode=1;
% p.tcLiveMode=1;
% p.postprocessing=0;
% p.loopVals = {};
% p.loopVars = {};
p.s = sqncr;
p.s.addBlock({'Load MOT'})
p.looping = int16(1);
p.s.runStep();
