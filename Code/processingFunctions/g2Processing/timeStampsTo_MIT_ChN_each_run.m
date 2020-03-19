function chN_each_run=timeStampsTo_MIT_ChN_each_run(ta)
    %ta is the array of shifted time stamps returned by shiftTimeStampsToGateStart
    %chN_each_run is already in the MIT naming convention
   chN_phot_time=cell(1,2);
   for ind=1:length(ta)
       timeFromPrevGate=[];
       cTime=[];
       for gateInd=1:length(ta{ind})
        row=ta{ind}{gateInd};
        row=row-row(1);
        ta{ind}{gateInd}=row(2:end-1); %this is because of the early threshold. do we want to change this? we're getting rid of the first photon
        timeFromPrevGate=vertcat(timeFromPrevGate,(ta{ind}{gateInd})');
        cGate=ta{ind}{gateInd};
        for jnd=2:gateInd
          cGate=cGate+ta{ind}{jnd-1}(end);
          disp(jnd)
        end
        cTime=[cTime,cGate];
       end
   chN_phot_time{ind}=horzcat(cTime',timeFromPrevGate);
   
   end
end
