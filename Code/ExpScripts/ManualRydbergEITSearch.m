%Lee 25.9
%The purpes of this code is to search for Rydberg EIT manualy by scaninng
%the control AOM and manualy scan carriar frequency
clear all
run('basicImports.m')
%% Parameters
probeCentFreq = 1510; %in MHz. This is the central offset lock frequency
period = 20; %us
T = period/2;
loadTime = 150e3;
setCurrent = 100*10/220; %The working Current for the MOT
UpDounDelay = 0; %This sets the UpDounDelay between the up scan of the probe and the down scan. Can be used to make sure we don't lose OD
MOTReloadTime = 300e3; %This time between sequencess to waite for the MOT to recapture the atoms. in us
settelTime = 100; %Time for magnetic filed to settel
averagingNum = 10;
%% Initialize DDS to DRG mode with scan parameters for the probe
dds_initial_2017(0,0,1,0,0,0); %initialize to DRG mode
profile0_new(probeCentFreq/16,0,0); %Set scan parameters

%% Sequence
%Load MOT to start
seqUpload(LoadMotSeq(channelTable,0,setCurrent*220/10)); %Sinse LoadMotSeq neads setCurrent in Amps (it converts inside) we convert setCurrent back to Apms
pause(1); %Let MOT build up

prog=CodeGenerator;
com=Tcp2Labview('localhost',6340);
% Seq
prog.GenSeq({Pulse('DigOut1',0,-1),Pulse('DigOut2',0,-1),...%Turn cooling & repump off
    AnalogPulse('AO0',1/40,-1,0),AnalogPulse('AO3',1/40,-1,0),...%Turn off magnetic filed
    Pulse('DigOut8',settelTime,0),Pulse('DigOut9',settelTime+1/40,0),...%Turn on probe & control
    Pulse('DigOut10',settelTime+2/40,T+UpDounDelay),... %Start AOM ramp (probe scan)
    ...%Reload MOT
    AnalogPulse('AO3',settelTime+2*T+UpDounDelay+1,0,10),AnalogPulse('AO0',settelTime+2*T+UpDounDelay+1+1/40,0,setCurrent),...%Turn on magnetic filed
    Pulse('DigOut1',settelTime+2*T+UpDounDelay+3,0),Pulse('DigOut2',settelTime+2*T+UpDounDelay+3,0),...%Turn on cooling
    Pulse('DigOut8',settelTime+2*T+UpDounDelay+3+1/40,-1),Pulse('DigOut9',settelTime+2*T+UpDounDelay+3+1/40,-1)}) %Turn off probe & control
    prog.GenPause(loadTime);
    
prog.GenFinish;
prog.DisplayCode;
com.UploadCode(prog);
com.UpdateFpga;
com.WaitForHostIdle;

for ind = 1:40
    com.Execute(int16(2^8-1));
    com.WaitForHostIdle;
    disp(ind)
end
com.WaitForHostIdle;
com.Delete;
clear prog
