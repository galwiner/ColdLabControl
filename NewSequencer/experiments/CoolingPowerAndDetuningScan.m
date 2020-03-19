%The objective of this experiment is to find the reload time for MOT reload.
%The sequence is: load a MOT, release the MOT, pause for 10ms, flash for
%picture, reload for a scaned time, take picture.

initp;
global p

%% setup the loop params
p.loopVars = {'coolingPower','coolingDetuning'};
p.loopVals={linspace(400,880,5),linspace(-8,-3,5)*p.consts.Gamma};
p.hasPicturesResults=1;
p.picsPerStep=p.NTOF;
p.(p.loopVars{1})=p.INNERLOOPVAR;
p.(p.loopVars{2})=p.OUTERLOOPVAR;
%% setup the script
p.s.addBlock({'setICEDetuning','Laser Name','cooling','Detuning',p.coolingDetuning});
p.s.addBlock({'ToF'});
initinst
initr