function runs = removeEarlyPhotons(runs,timeThreshold)
%remove any early photon time tags in each gate. This assumes the runs
%input has already been shifted. i.e that the time stamp is measured from
%the start of each gate
if nargin==1
    timeThreshold=1e6; % 1 ps
end

for ind=1:length(runs)
    for jnd=1:length(runs{ind})
        thisGate=runs{ind}{jnd};
        thisGate(abs(thisGate)<timeThreshold)=[];
        runs{ind}{jnd}=thisGate;
    end
end
end

