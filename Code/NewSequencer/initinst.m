%%init instruments
clear -global inst
global p
global inst
global r
global g2serverApp
% imaqreset %moved into camera initiation 4/9/18 GW
% if ~exist('inst','var')
%     instrreset
% end
 instrreset
if p.DEBUG==1
    return
end
inst.ind = 1;
%FPGA
fprintf('Initializing FPGA communications\n');
inst.com=Tcp2Labview('10.10.10.1',6340);
% inst.com=Tcp2Labview('132.77.41.240',6340);
%Cameras
fprintf('Initializing cameras\n');
if isfield(p,'pfPlaneLiveMode')
    p.pfPLiveMode = p.pfPlaneLiveMode;
end
if isfield(p,'tcLiveMode')
    p.idsLiveMode = p.tcLiveMode;
elseif isfield(p,'pfTopLiveMode')
    p.idsLiveMode = p.pfTopLiveMode;
end
if p.pfLiveMode
    if p.idsLiveMode
        inst.cameras=containers.Map({'pixelfly','ids'},{'',''});
    else
        %ToDO Add kill cockpit action
        if isfield(p,'idsMonitor')&& p.idsMonitor==1
            inst.cameras=containers.Map({'pixelfly','ids'},{'',idsCam('monitor')});
        else
            inst.cameras=containers.Map({'pixelfly','ids'},{'',idsCam('plane')});
        end
    end
else
    system('taskkill /FI "imagename eq CamWare.exe"');
    if p.idsLiveMode
        inst.cameras=containers.Map({'pixelfly','ids'},{pixelfly,''});
    else
        %ToDO Add kill cockpit action
        if isfield(p,'idsMonitor')&& p.idsMonitor==1
            
        inst.cameras=containers.Map({'pixelfly','ids'},{pixelfly,idsCam('monitor')});
        else
            inst.cameras=containers.Map({'pixelfly','ids'},{pixelfly,idsCam('plane')});
        end
%         fprintf('pausing for 1s for camera setup')
%         pause(1);


    end
end
updatePixelfly;
updateIds;
%Shovach
fprintf('INITIALIZING SHOVACH DDS\n');
try
    inst.DDS=Shovach;    
%     inst.DDS.setFreq(1,341.2,0,0); %set 960 dpAOM freq to match n=70 resonance. Was changed from 341.6 on 24/09/19 to account for a magnetic shift from -0.5G bias
%     inst.DDS.setFreq(1,395.2,0,0); %set 960 dpAOM freq to match n=101 resonance. Set 25/9/2019 using fast mode spectroscopy, for field of -0.5G
        resetControlLock(395.2); %use this and not setFreq, to avoide lock jumping. 10/02/20
%     inst.DDS.setFreq(3,136.8); % set 776 aom to match 776 resonance
    inst.DDS.setFreq(3,134);% set 776 aom to match 776 resonance to match a field of -0.5G
    inst.DDS.setFreq(4,200); % probe AOM frequency.
%     inst.DDS.setFreq(2,probeDetToFreq(0,8),0,0);
    %     SHU1_initial_2016(0,1,1);
    %     profile0_A(110,0,0);
%     dds=inst.DDS;
catch err
    warning('Error occurred while initiating DDS! Error: %s',err.message);
end
%MW Source
if ~isfield(p,'mwSource')
    p.mwSource = 0;
end
if p.mwSource
    fprintf('INITIALIZING MW Source\n');
    try
        inst.MWSource=IOnitDDS(0,0,1,0,1,1,'com18');
        %     disp('setting MW Source to DRG mode');
        %     inst.MWSource.setupSweepMode(35,34,5e-6,5e-6,10e3,10e3);
        disp('setting MW Source to DRG mode');
        inst.MWSource.setFreq(34.683000,0,0); %theoretical resonance: 34.678261
    catch err
        warning('Problem communicating with MW source!');
    end
end

%IPG setup
try
fprintf('Initializing IPG Laser\n')
inst.dplaser=IPG();
dplaser=inst.dplaser;
catch err
    warning('can''t connect to IPG.\nERROR: %s\n',err.message)
end

%%SproutSetup
if p.Sprout ==1
    try
        fprintf('Initializing sprout Laser\n')
        inst.sproutLaser=sprout();
        sprt=inst.sproutLaser;
    catch err
        warning('can''t connect to Sprout.\nERROR: %s\n',err.message);
    end
end

%%M2 ICE Setup 
try
inst.m2=m2ctrl();
catch err
    warning('could not start m2 control');
end

%AHH setup
fprintf('Initializing AHH PSU\n')
psuSetup;
%Bias PSU
fprintf('Initializing bias PSUs\n')
inst.BiasFieldManager=biasFieldManager();
% inst.BiasCoils={BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'),BiasPSU('TCPIP::10.10.10.107::inst0::INSTR')}; %{1} is biasPSU1 and {2} is biasPSU2
inst.BiasCoils={inst.BiasFieldManager.bias1,inst.BiasFieldManager.bias2};
% inst.BiasCoils{1}.resetPSU;
% inst.BiasCoils{2}.resetPSU;
inst.BiasCoils{1}.setCurrent(1,p.HHYCurrent);
inst.BiasCoils{1}.setCurrent(2,p.HHZCurrent);
inst.BiasCoils{2}.setCurrent(2,p.HHXCurrent);
inst.BiasCoils{2}.setCurrent(1,p.HHZCurrent);
inst.BiasCoils{1}.setOutput(1,1);
inst.BiasCoils{1}.setOutput(2,1);
inst.BiasCoils{2}.setOutput(2,1);
inst.BiasCoils{2}.setOutput(1,1);
inst.BiasCoils{1}.setVoltageLimit(1,p.HHYVoltageLimit);
inst.BiasCoils{1}.setVoltageLimit(2,p.HHZVoltageLimit);
inst.BiasCoils{2}.setVoltageLimit(1,p.HHZVoltageLimit);
inst.BiasCoils{2}.setVoltageLimit(2,p.HHXVoltageLimit);
%%EField managment
if p.biasE==1
inst.BiasE=coldEfieldGenerator();
end
%Cooling and Repump lasers
fprintf('killing ICE_Control.exe\n');
system('taskkill /FI "imagename eq ICE_control.exe"');
fprintf('Initializing laser communications\n');

inst.Lasers=containers.Map({'cooling','repump'},{ICELaser('COM8',4,3,4),ICELaser('COM8',2,1,2)});
cooling=inst.Lasers('cooling');
repump=inst.Lasers('repump');
%     inst.Lasers('cooling').setEventNum(3);
inst.Lasers('cooling').setEventNum(2);
inst.Lasers('repump').setEventNum(2);
inst.Lasers('cooling').setAddress(7);

inst.Lasers('cooling').setIntFreq(p.coolingLockFreq);
%old master
% inst.Lasers('cooling').setEventData(coolingDetToFreq(p.coolingDet,8),1,1,0);
% inst.Lasers('cooling').setEventData(coolingDetToFreq(0,8),2,1,0);
% assert(all(round(inst.Lasers('cooling').getEventData(1),3)==[1,round(coolingDetToFreq(p.coolingDet,8),3),0]),'failure in ICE freq. configuration')
% assert(all(round(inst.Lasers('cooling').getEventData(2),3)==[1,round(coolingDetToFreq(0,8),3),0]),'failure in ICE freq. configuration');
%new master
inst.Lasers('cooling').setEventData(p.coolingLockFreq,1,3,0);
inst.Lasers('cooling').setEventData(coolingDetToFreq(-286+p.zeemanDetuning,8),2,3,0); %Changed to -286 for zeeman pumping (depump)  -20-266 (266 is the F=2 to F=3 split, 20 is the difference between the DPAOM and the single pass AOM frequencies)
assert(all(round(inst.Lasers('cooling').getEventData(1),3)==[3,round(p.coolingLockFreq,3),0]),'failure in ICE freq. configuration')
assert(all(round(inst.Lasers('cooling').getEventData(2),2)==[3,round(coolingDetToFreq(-286+p.zeemanDetuning,8),2),0]),'failure in ICE freq. configuration');
inst.Lasers('repump').setAddress(1);
% old master
% inst.Lasers('repump').setIntFreq(repumpDetToFreq(0,32));
% assert(round(inst.Lasers('repump').getIntFreq(),4)==round(173.4858,4),'failure in ICE freq. configuration');
% new master
%(obj,freq,row,mode,feedFwd)
inst.Lasers('repump').setIntFreq(repumpDetToFreq(0,64));
inst.Lasers('repump').setEventData(repumpDetToFreq(0,64),1,15,0);
inst.Lasers('repump').setEventData(repumpDetToFreq(p.zeemanRepumpDetuning,64),2,15,0); 
assert(round(inst.Lasers('repump').getIntFreq(),4)==round(repumpDetToFreq(0,64),4),'failure in ICE freq. configuration');
%     inst.Lasers('cooling').setEventData(coolingDetToFreq(-70,8),3,1,0); %-70 MHz, following Sparkes
inst.Lasers('cooling').setCurrentEvent(1);

%scopes
if p.hasScopResults
    fprintf('Initializing osciloscopes\n')
    inst.scopes={keysightScope('10.10.10.118','MOTSCOPE','ip')};
    if isfield(p,'numOfScopPoints')
       inst.scopes{1}.setNumPoints(p.numOfScopPoints)
    end
end

%function gen
if p.FunctionGen
fprintf('Initializing function generators\n');
inst.rigol1=rigolFunctionGen('10.10.10.123');
end
%FPGA INIT SEQ
fprintf('Running FPGA INIT SEQ\n');

tmpSqncr=sqncr();
tmpSqncr.addBlock({{'setDigitalChannel','channel','ICEADDR0','duration',0,'value','High','description','ICE ADDR 0 SET'};...
    {'setDigitalChannel','channel','ICEADDR1','duration',0,'value','High','description','ICE ADDR 1 SET'};...
    {'setDigitalChannel','channel','ICEADDR2','duration',0,'value','High','description','ICE ADDR 2 SET'};...
    {'setDigitalChannel','channel','ICEADDR2','duration',0,'value','High','description','ICE ADDR 2 SET'};...
    {'setDigitalChannel','channel','IGBT_circ','duration',0,'value','High','description','circ IGBT open (high)'};...
    {'setAnalogChannel','channel','COOLVCO','duration',0,'value',CoolingVCOFreq2AO(110),'description','set cooling VCO to 110 MHz'};...
%     {'setAnalogChannel','channel','RPMPVCO','duration',0,'value',RepumpVCOFreq2AO(110),'description','set repump VCO to 110 MHz'};...
%     {'setAnalogChannel','channel','ImagingVCO','duration',0,'value',ImagingVCOFreq2AO(imagingDetToFreq(0)),'description','set imaging VCO to resonanse'};...
%     {'setAnalogChannel','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'};...
    {'setDigitalChannel','channel','coolingShutter','duration',0,'value',p.zShutter,'description','cooling z shutter open'};...
    {'setDigitalChannel','channel','ZeemanShutter','duration',0,'value','low','description','Zeeman shutter set to low'};...
    {'setDigitalChannel','channel',p.chanNames.ZEEMANSwitch,'duration',0,'value','high','description','Zeeman switch set to high'};...
    {'setDigitalChannel','channel','SPCMShutter','duration',0,'value','low','description','SPCM shutter set to low'};...
    {'setDigitalChannel','channel','TTGate','duration',0,'value','low','description','SPCM gate low'};...
    {'setDigitalChannel','channel','imagingTTL','duration',0,'value','low','description','imaging Switch off'};...
    {'setBlueDTPower','value','max','duration',0};...
    {'setPurpleDTPower','value','max','duration',0};...
    {'GenPause','duration',5e4}});

% tmpSqncr.addBlock({'setAnalogChannel','channel','PRBVVAN','value',ProbePower2AO(p.probePower),'duration',0,'description','set probe power: 100nW'});
tmpSqncr.runStep();
%setup spectrum analyser
if p.hasSpecResults
    if p.handheldSpecRes
        inst.spectrumAna{2} = spectrumAnalizer('handheld');
    else
        inst.spectrumAna{2} = '';
    end
    if p.benchtopSpecRes
        inst.spectrumAna{1} = spectrumAnalizer('benchtop');
    else
        inst.spectrumAna{1} = '';
    end
end
updateSpectrumAnalyzer;
if p.hasTTresults
inst.tt=TimeTagger;
inst.tt.setTestSignal(1,false);
inst.tt.setTestSignal(2,false);
inst.tt.setTestSignal(3,false);
inst.tt.setTriggerLevel(1,0.5);
inst.tt.setTriggerLevel(2,1);
inst.tt.setTriggerLevel(3,1);
if isfield(p,'g2measurement')
    if p.g2measurement
        h = findall(0,'name','ttReader');
        if ~isempty(h)
            close(h)
        end
        
        if isempty(g2serverApp)
            g2serverApp=ttReader;
        end
    end
end
end

%KeithleyPSU, 2 channels from 0 to 10 V (used) and one from 0-5 V unused.
inst.KeithleyPSU = KeithleyPSU('com24');
inst.KeithleyPSU.setOutput('on'); %set output to 'on'

if isfield(p,'synthHD')&&p.synthHD==1
    try
    inst.synthHD = synthHD('com2');
    catch
        warning('can''t connect to synthHD')
    end
end

if isfield(p,'kdc') && p.kdc==1
    fprintf('initiating KDC control\n');
    inst.kdc = KDCControl(p.kdcSN);
end
