function chN_phot_time=timeStampsTo_MIT_ChNtime(matfilename)
    %ta is the array of shifted time stamps returned by shiftTimeStampsToGateStart
    %chN_phot_time is already in the MIT naming convention
   load(matfilename);
   runNum=getRunNumFromFile(matfilename)
   ta=timeArray;
   chN_phot_time=cell(1,2);
   
   cycleTime=20000; % in uS (will take this from p. 20mS for developing the idea)
   
   for ind=1:length(ta)
       timeFromPrevGate=[]; %time in gate
       cTime=[]; %cumalative time in cycle
       gatePosInRun=[]; %gate num in run 
       runNumVect=[]; %run number
       
       for gateInd=1:length(ta{ind}) %cycling over gates in *Run*
        row=ta{ind}{gateInd};
        row=row-row(1);
        ta{ind}{gateInd}=row(2:end-1); %this is because of the early threshold. do we want to change this? we're getting rid of the first photon
        timeFromPrevGate=vertcat(timeFromPrevGate,(ta{ind}{gateInd})');
        cGate=ta{ind}{gateInd};
        gatePosInRun=[gatePosInRun ones(size(ta{ind}{gateInd})).*gateInd];
        runNumVect=[runNumVect ones(size(ta{ind}{gateInd})).*runNum];
        for jnd=2:gateInd
          cGate=cGate+ta{ind}{jnd-1}(end);
        end
        cTime=[cTime,cGate];
        
       end
   cycleInRun=ceil(cTime/cycleTime);
   numCycles=max(cycleInRun);
%    gateInCycle
   cTime=mod(cTime,cycleTime);
   chN_phot_time{ind}=horzcat(cTime',timeFromPrevGate,gatePosInRun',runNumVect');
   
   end
end
