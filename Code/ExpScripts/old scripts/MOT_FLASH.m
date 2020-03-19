clear all
basicImports
seqUpload(LoadMotSeq(channelTable))
% seq={Pulse(channelTable.PhysicalName{'ScopeTrigger'},0,20000),...
%      Pulse(channelTable.PhysicalName{'repump'},0,0),...
%      Pulse(channelTable.PhysicalName{'repump'},0.2e6,-1)};

seq={Pulse(channelTable.PhysicalName{'ScopeTrigger'},0,20000),...
     AnalogPulse(channelTable.PhysicalName{'IGBT'},0,0,0),... %Turn off IGBT
     AnalogPulse(channelTable.PhysicalName{'CircCoil'},0,0,0),...%Turn off Current
     AnalogPulse(channelTable.PhysicalName{'IGBT'},50e3,0,5),... %Turn on IGBT
     AnalogPulse(channelTable.PhysicalName{'CircCoil'},50e3,0,70*10/220),...%Turn on Current,...
     };
prog=CodeGenerator;
prog.GenSeq(seq);
prog.GenPause(3000e3);
prog.GenFinish;
prog.DisplayCode;

com=Tcp2Labview('localhost',6340);
    com.UploadCode(prog);
    com.UpdateFpga;
    com.WaitForHostIdle;
for ind=1:5000
    com.Execute(20);
end
com.Delete;