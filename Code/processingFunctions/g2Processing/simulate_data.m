global p
ODb = 5;
gateTime=20e6;
pulse_duration=gateTime/2;
cycleTime=1e12;
gatesInCycle=p.gateNum;
numCycles=p.NAverage;
gateTimes=[];
photonTimes=[];
photPerGate=1*pulse_duration*1e-6; %1 per uS
%time for gate egde, in mus
for ind=1:numCycles
    gateTimes=[gateTimes,([0:gateTime:(gatesInCycle-1)*gateTime]+cycleTime*(ind-1))];
end

for ind=1:length(gateTimes)
    for pInd=1:poissrnd(photPerGate)
        photonTimes(end+1)=gateTimes(ind)+pulse_duration*rand();
    end    
end
photonTimes=sort(photonTimes);

%physics
rb=0.2e6;

% I=(diff(photonTimes)<0.2e6);
% I=binornd(1,exp(-diff(photonTimes)./rb));
I=binornd(1,1-1./(exp(-diff(photonTimes)/rb)+1));
I=[0,I];

photonTimes(logical(I.*binornd(1,1-exp(-ODb),size(photonTimes))))=[];
% photonTimes(I)=[];
%split between detectors
Ich=logical(round(rand(size(photonTimes))));
photonTimes1 = photonTimes(Ich);
photonTimes2 = photonTimes(~Ich);

sortedPulses={gateTimes,photonTimes1,photonTimes2};

