%Lee 19.9
%The purpes of this code is to search for Rydberg EIT by scaninng the probe
%and control and reading the spectrum.
clear all
run('basicImports.m')
%% Parameters
probeSpan = 200; %in MHz
probeCentFreq = 1530; %in MHz. This is the central offset lock frequency
probedt = 1; %us. This is the time between jumps of the probe scan
if probedt>262
    error('The maximal time between steps is 262\mus!');
end
probedf = 200e3; % Hz. This is the step size of the probe
UpFreq = (probeCentFreq+probeSpan/2)/16; %MHz. This is the highest DDS frequency of the scan
DownFreq =(probeCentFreq-probeSpan/2)/16;%MHz
DDSspan = (UpFreq-DownFreq)*1e6; %Hz. Used to calculate number of jumps fpr the probe
probeN = floor(DDSspan/probedf); %Total number of jumps
T = probeN*probedt; %In us
controlSpan = 200; %MHz
controlDf = 5; %MHz. This is the controle resolution.
controlN = controlSpan/controlDf;
setCurrent = 100*10/220; %The working Current for the MOT
UpDounDelay = 0; %This sets the UpDounDelay between the up scan of the probe and the down scan. Can be used to make sure we don't lose OD
MOTReloadTime = 300e3; %This time between sequencess to waite for the MOT to recapture the atoms. in us
settelTime = 100; %Time for magnetic filed to settel
controlMhz2V = 1/1500; %This is the ratio between the M^2 PZT slow (up to 50HZ) piezo control.
averagingNum = 10;
%% Initialize DDS to DRG mode with scan parameters for the probe
dds_initial_2017(0,1,0,0,0,0); %initialize to DRG mode
DRG_LAB_new_2017(UpFreq,DownFreq,probedt*1e-6,probedt*1e-6,probedf,probedf); %Set scan parameters

%% Sequence
%Load MOT to start
seqUpload(LoadMotSeq(channelTable,0,setCurrent*220/10)); %Sinse LoadMotSeq neads setCurrent in Amps (it converts inside) we convert setCurrent back to Apms
pause(1); %Let MOT build up
seqUpload({AnalogPulse('AO4',0,0,0)}); %Set the M^2 slow pzt to start from 0
pause(1);
com=Tcp2Labview('localhost',6340);%Oprn TCP/IP for FPGA
%% Set up scope
chanNum = 3;
exist scop;
if ans
    fclose(scop);
    clear scop;
end
scop=SetScope2409(chanNum);

%%
    seqUpload({AnalogPulse('AO4',0,0,controlDf*40*controlMhz2V)})
for ind = 1:controlN
    controlV = controlDf*ind*controlMhz2V; %This is the voltage that goes to the M^2 slow PZT. it changes in each loop.
    for indav = 1:averagingNum
        prog=CodeGenerator;
        com=Tcp2Labview('localhost',6340);
        prog.GenSeq({Pulse('DigOut1',0,-1),Pulse('DigOut2',0,-1),...%Turn cooling & repump off
            AnalogPulse('AO0',1/40,-1,0),AnalogPulse('AO3',1/40,-1,0),...%Turn off magnetic filed
            Pulse('DigOut8',settelTime,0),Pulse('DigOut9',settelTime+1/40,0),...%Turn on probe & control
            Pulse('DigOut6',settelTime+2/40,T+UpDounDelay),... %Start DDS ramp (probe scan)
            ...%Reload MOT
            AnalogPulse('AO3',settelTime+2*T+UpDounDelay+1,0,10),AnalogPulse('AO0',settelTime+2*T+UpDounDelay+1+1/40,0,setCurrent),...%Turn on magnetic filed
            Pulse('DigOut1',settelTime+2*T+UpDounDelay+3,0),Pulse('DigOut2',settelTime+2*T+UpDounDelay+3,0),...%Turn on cooling
            Pulse('DigOut8',settelTime+2*T+UpDounDelay+3+1/40,-1),Pulse('DigOut9',settelTime+2*T+UpDounDelay+3+1/40,-1)}) %Turn off probe & control
            
            
            prog.GenFinish;
            %prog.DisplayCode;
            com.UploadCode(prog);
            com.UpdateFpga;
            com.WaitForHostIdle;
            com.Execute(1);
            com.WaitForHostIdle;
            disp(ind);
            com.Delete;
            clear prog
            [tmptime,tmpchanData,time2save] = GetScopeData(scop,chanNum);
            if time2save<MOTReloadTime*1e-6
            pause(MOTReloadTime*1e-6-time2save)
            end
            if indav ==1
                Time = tmptime;
                ChanData = tmpchanData;
            else
                Time = Time +tmptime;
                ChanData = ChanData+tmpchanData;
            end
    end
    averageChanData(:,ind) =ChanData/averagingNum;
    averageTime(:,ind) = Time/averagingNum;
end
seqUpload({ AnalogPulse('AO4',0,0,0)});

%% Data analesys and plotting
for ind = 1:controlN
    smoothData(:,ind) = smooth(averageChanData(:,ind));
end
normdata = smoothData./max(smoothData,[],1);
undrSampData = interp1(1:1:1e4,normdata,1:10:1e4);
undrSampTime = interp1(1:1:1e4,averageTime,1:10:1e4);
figure;
hold on

for ind = 1:controlN
    plot(undrSampTime(end/8:end/2,ind),undrSampData(end/8:end/2,ind)+(ind-1)*5e-2)
end

%% Delete and close
fclose(scop);
delete(scop);
clear scop;


