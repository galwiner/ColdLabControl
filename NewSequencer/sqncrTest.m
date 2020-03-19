%sqncr TEST
clear all
global p

global r
global inst
DEBUG=0;
% init(DEBUG);

% s=sqncr();
initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr
% p.MOTReloadTime=p.INNERLOOPVAR;
% p.MOTLoadTime=p.OUTERLOOPVAR;
% p.loopVars = {'MOTReloadTime','MOTLoadTime'};
% p.loopVals={linspace(1e3,0.6e6,2),linspace(1e3,0.6e6,2)};
% atomicAction=Block({'pause','duration',4});
% CompoundAction=Block({'ToF'});
% liveMode=Block({'Live MOT'});
% asincAction = Block({'setICEDetuning','Laser Name','cooling','Detuning',-40});
%CompoundAction=Block({'ToF','coolingPower',p.INNERLOOPVAR});
% AsyncAction=Block({'setDDSfreq','DDSNum',1,'Freq',170});

% LoadMOT=Block({'Load MOT'});
% s.addAction(Block({'Load MOT'}))
% p.loopVars=

% p.s.addBlock(LoadMOT)

% p.s.addBlock(liveMode);
% p.s.getbgImg;
% p.s.addBlock(CompoundAction)
% p.s.addBlock({'ToF'})
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','High','description','picture:trigger pixcam photo'});

% p.s.addBlock({'Load MOT'})
% p.s.addBlock({'Release MOT'})
% p.s.addBlock({'TrigScope'});
% p.s.addBlock({'setDigitalChannel','channel','ProbeSwitch','duration',0,'value','high','description','picture:trigger ICE jump'});...
% p.s.addBlock({'pause','duration',200,'description','picture:ICE freq stabilize'});%Wait for frequency to jump
% p.s.addBlock({'setDigitalChannel','channel','DepumpSwitch','duration',0,'value','low','description','picture:trigger ICE jump'});...
% p.s.addBlock({'pause','duration',10e3})
% p.s.addBlock({{'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','picture: cooling power max'};...
%     {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'};...
%     {'pause','duration',300,'description','picture:ICE freq stabilize'};...%Wait for frequency to jump
%     
%     
%     {'pause','duration',5.6};%pixelfly intrinsic delay
%     {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','High','description','picture:cooling on'};...%Cooling on
%     {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','High','description','picture:repump on'};...%repump on
%     {'pause','duration',p.cameraParams{1}.E2ExposureTime,'description','picture:wait during exposure'};...%Wait for exposure time
%     ...%Set power to what it was and jump to original freq
%     {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','picture:restore cool pwr'};...
%     {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trig ICE det. jump'}...
%     });

% p.s.addBlock({'Load MOT'})
% p.picsPerStep=100;
% p.cameraParams{1}.E2ExposureTime=300;
% for i=1:p.picsPerStep
% p.s.addBlock({'setDigitalChannel','channel','pixelflyTrig','duration',20,'value','High','description','picture:trigger pixcam photo'});
% p.s.addBlock({'setDigitalChannel','channel','UVDiodeSwitch','duration',0,'value','High','description','picture:trigger thorcam photo'});
% p.s.addBlock({'pause','duration',100e3});
% 
% end

% p.compressionTime = 500;
% p.s.addBlock({'Load MOT'})
% p.s.addBlock({'TrigScope'})
% p.s.addBlock({'startAnalogRamp','channel','CircCoil','value','none','duration',p.compressionTime,'EndCurrent',0});
% p.s.addBlock({'pause','duration',p.compressionTime+10});
% p.s.addBlock({'setDigitalChannel','channel','IGBT_circ','duration',0,'value','low'});
% p.s.addBlock({'GenPause','duration',50e3,'channel','none','value','none'});

p.s.addBlock({'Load MOT'})
p.s.addBlock({'TrigScope'})
p.s.addBlock({'Release MOT'})
p.s.addBlock({'GenPause','duration',50e3,'channel','none','value','none'});

% p.s.addBlock({'MOTblink'});
% p.s.addBlock({'setHH','direction','x','current',-0.01});
% p.s.addBlock(asincAction);
% p.s.addBlock({...
%             {'setAnalogChannel','channel','CircCoil','duration',0,'value',220*10/220,'description','Load MOT:set coil current'};...
%             {'pause','duration',1.5e6};...
%             {'setAnalogChannel','channel','CircCoil','duration',0,'value',6*10/220,'description','Load MOT:set coil current'};...
%             {'GenPause','duration',1.5e6,'channel','none','value','none'}...
%             });
% p.s.addBlock({'ToF'});
% p.looping = int16(8);
 p.looping = int16(1);

% cooling=inst.Lasers('cooling');
% rpmp=inst.Lasers('repump');
% cooling.delete;
% rpmp.delete;

% cooling.setIntFreq(coolingDetToFreq(-6.5*p.consts.Gamma,8))
%%
% tc=inst.cameras('thorcam');
% p.cameraParams{2}.exposure=3000;
% tc.startLiveMode;
% updateThorcam()
p.s.run();
% for ind=1:100
%     r.images{2}(:,:,ind)=inst.cameras('thorcam').getImage;
%     pause(0.5);

% end
%  imageViewer([],[],r.images{2});
% imageViewer(inst.cameras('pixelfly').x,inst.cameras('pixelfly').y,r.images{1});
% p.s.fitAll
%%
% imageViewer([],[],squeeze(r.images{1}))
% figure;
% plot(p.loopVals{1}*1e-3,squeeze(max(max(squeeze(r.images{1}),[],1),[],2)));
% xlabel('Reload Time[ms]');
% ylabel('MOT fluorescence after reload. 10ms TOF time');

% %%
% %TEST 1 - sequencer with single atomic action
% s=sqncr();
% s.addBlock(atomicAction);
% s.runStep();
% clear s
% %TEST 2 - sequencer with single compund action
% clear s
% s=sqncr();
% s.addBlock(CompoundAction);
% s.runStep(238,17);

% %TEST 3
% clear s
% s=sqncr();
% s.addBlock(AsyncAction);
% s.runStep();
% 
% %TEST 4
% clear s
% s=sqncr();
% s.addBlock(AsyncAction);
% s.addBlock(CompoundAction);
% s.runStep(100,1);

% %TEST 5
% clear s
% s=sqncr();
% 
% % s.addBlock(AsyncAction);
% s.addBlock(CompoundAction);
% assert(strcmpi(s.seq{1}.name,'ToF'));
% % tic
% s.run;
% % toc
% 
