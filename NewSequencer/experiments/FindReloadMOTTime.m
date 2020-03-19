%The objective of this experiment is to find the reload time for MOT reload.
%The sequence is: load a MOT, release the MOT, pause for 10ms, flash for
%picture, reload for a scaned time, take picture.

initp;
global p
p.ExpDescription = 'find the reload time for MOT reload';
%% setup the loop params
p.loopVars = {'MOTReloadTime'};
p.loopVals={linspace(1e3,0.6e6,10)};
p.hasPicturesResults=1;
p.picsPerStep=1;
p.(p.loopVars{1})=p.INNERLOOPVAR;
%% setup the script

p.s.addBlock({'Load MOT'});
p.s.addBlock({'Release MOT'});
p.s.addBlock({'pause','duration',10e3});
p.s.addBlock({{'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',880,'description','picture: cooling power max'};...
    {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trigger ICE jump'};...
    {'pause','duration',300,'description','picture:ICE freq stabilize'};...%Wait for frequency to jump
    
    
    {'pause','duration',5.6};%pixelfly intrinsic delay
    {'setDigitalChannel','channel','coolingSwitch','duration',0,'value','High','description','picture:cooling on'};...%Cooling on
    {'setDigitalChannel','channel','repumpSwitch','duration',0,'value','High','description','picture:repump on'};...%repump on
    {'pause','duration',p.cameraParams{1}.E2ExposureTime,'description','picture:wait during exposure'};...%Wait for exposure time
    ...%Set power to what it was and jump to original freq
    {'setAnalogChannel','channel','COOLVVAN','duration',0,'coolingPower',p.coolingPower,'description','picture:restore cool pwr'};...
    {'setDigitalChannel','channel','ICEEVTTRIG','duration',1,'value','High','description','picture:trig ICE det. jump'}...
    });
p.s.addBlock({'Reload MOT'});
p.s.addBlock({'TakePic'});
initinst
initr