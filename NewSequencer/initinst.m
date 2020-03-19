%%init instruments
clear -global inst
global p
global inst
global r
% imaqreset %moved into camera initiation 4/9/18 GW
% if ~exist('inst','var')
%     instrreset
% end
 instrreset
if p.DEBUG==1
    return
end
inst.ind = 1;
fprintf('Initializing FPGA communications\n');

inst.com=Tcp2Labview('10.10.10.1',6340);
fprintf('Initializing cameras\n');
if isfield(p,'pfLiveMode')
    p.pfPlaneLiveMode = p.pfLiveMode;
end
if isfield(p,'tcLiveMode')
    p.pfTopLiveMode = p.tcLiveMode;
end
if p.pfPlaneLiveMode
    if p.pfTopLiveMode
        inst.cameras=containers.Map({'pixelflyPlane','pixelflyTop'},{'',''});
    else
        system('taskkill /FI "imagename eq CamWare.exe"');
        imaqreset
        inst.cameras=containers.Map({'pixelflyPlane','pixelflyTop'},{'',pixelfly('top')});
    end
else
    if p.pfTopLiveMode
        system('taskkill /FI "imagename eq CamWare.exe"');
        imaqreset
        inst.cameras=containers.Map({'pixelflyPlane','pixelflyTop'},{pixelfly('plane'),''});
    else
        system('taskkill /FI "imagename eq CamWare.exe"');
        imaqreset
        inst.cameras=containers.Map({'pixelflyPlane','pixelflyTop'},{pixelfly('plane'),pixelfly('top')});
    end
end
updatePixelfly;

fprintf('Initializing AHH PSU\n')
psuSetup;
fprintf('INITIALIZING SHOVACH DDS\n');
%     fprintf('Initializing cooling channel DDS\n')
try
    inst.DDS=Shovach;
    fprintf('setting cooling channel freq\n');
%     inst.DDS.setFreq(1,110,0,0);
    %     SHU1_initial_2016(0,1,1);
    %     profile0_A(110,0,0);
catch err
    warning('Problem communicating with DDS!');
end
try
    inst.MWSource=IOnitDDS(0,0,1,0,1,1,'com10');
    disp('setting MW Source to DRG mode');
%     inst.MWSource.setupSweepMode(35,34,5e-6,5e-6,10e3,10e3);
inst.MWSource.setFreq(34.683000,0,0); %theoretical resonance: 34.678261
catch err
    warning('Problem communicating with MW source!');
end
fprintf('Initializing bias PSUs\n')
inst.BiasCoils={BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'),BiasPSU('TCPIP::10.10.10.107::inst0::INSTR')}; %{1} is biasPSU1 and {2} is biasPSU2
inst.BiasCoils{1}.resetPSU;
inst.BiasCoils{2}.resetPSU;
inst.BiasCoils{1}.setCurrent(1,p.HHYCurrent);
inst.BiasCoils{1}.setCurrent(2,p.HHZCurrent);
inst.BiasCoils{2}.setCurrent(2,p.HHXCurrent);
inst.BiasCoils{1}.setOutput(1,1);
inst.BiasCoils{1}.setOutput(2,1);
inst.BiasCoils{2}.setOutput(2,1);
inst.BiasCoils{1}.setVoltageLimit(1,p.HHYVoltageLimit);
inst.BiasCoils{1}.setVoltageLimit(2,p.HHZVoltageLimit);
inst.BiasCoils{2}.setVoltageLimit(2,p.HHXVoltageLimit);
fprintf('killing ICE_Control.exe\n');
system('taskkill /FI "imagename eq ICE_control.exe"');
fprintf('Initializing laser communications\n');

inst.Lasers=containers.Map({'cooling','repump'},{ICELaser('COM8',2,3,4),ICELaser('COM8',4,1,2)});
%     inst.Lasers('cooling').setEventNum(3);
inst.Lasers('cooling').setEventNum(2);
inst.Lasers('cooling').setAddress(7);

inst.Lasers('cooling').setIntFreq(p.coolingLockFreq);
%old master
% inst.Lasers('cooling').setEventData(coolingDetToFreq(p.coolingDet,8),1,1,0);
% inst.Lasers('cooling').setEventData(coolingDetToFreq(0,8),2,1,0);
% assert(all(round(inst.Lasers('cooling').getEventData(1),3)==[1,round(coolingDetToFreq(p.coolingDet,8),3),0]),'failure in ICE freq. configuration')
% assert(all(round(inst.Lasers('cooling').getEventData(2),3)==[1,round(coolingDetToFreq(0,8),3),0]),'failure in ICE freq. configuration');
%new master
inst.Lasers('cooling').setEventData(p.coolingLockFreq,1,3,0);
inst.Lasers('cooling').setEventData(coolingDetToFreq(0,8),2,3,0);
assert(all(round(inst.Lasers('cooling').getEventData(1),3)==[3,round(p.coolingLockFreq,3),0]),'failure in ICE freq. configuration')
assert(all(round(inst.Lasers('cooling').getEventData(2),3)==[3,round(coolingDetToFreq(0,8),3),0]),'failure in ICE freq. configuration');
inst.Lasers('repump').setAddress(0);
% old master
% inst.Lasers('repump').setIntFreq(repumpDetToFreq(0,32));
% assert(round(inst.Lasers('repump').getIntFreq(),4)==round(173.4858,4),'failure in ICE freq. configuration');
% new master
inst.Lasers('repump').setIntFreq(repumpDetToFreq(0,64));
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
    {'setAnalogChannel','channel','RPMPVCO','duration',0,'value',RepumpVCOFreq2AO(110),'description','set repump VCO to 110 MHz'};...
    {'setAnalogChannel','channel','ImagingVCO','duration',0,'value',ImagingVCOFreq2AO(220+abs(p.coolingLockDet)),'description','set imaging VCO to resonanse'};...
    {'setAnalogChannel','channel','ImagingVVAN','duration',0,'value',p.imagingPower,'description','set imaging power'}});
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