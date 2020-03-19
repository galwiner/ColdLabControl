function [gateShape,time] = getGateShape(chN_phot_time,chN_phot_cycles,cyclesToMean)
if nargin==2
    cyclesToMean = 1;
end
cycleNum = max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}));
if strcmpi(cyclesToMean,'all')
    cyclesToMean = cycleNum;
end
SupCycleList = 1:floor(cycleNum/cyclesToMean);
gateShape = zeros(2,200,length(SupCycleList));
maxTime = max(max(chN_phot_time{1}(:,2)),max(chN_phot_time{2}(:,2)));
time = linspace(0,maxTime,200);
timeBins = time;
timeBins(end+1) = timeBins(end)+timeBins(2)-timeBins(1);
for ii = 1:length(SupCycleList)
   cycleList = SupCycleList(ii):(SupCycleList(ii)+cyclesToMean-1);
   for jj = 1:length(cycleList)
   [N1,~] = histcounts(chN_phot_time{1}(chN_phot_cycles{1}==cycleList(jj),2),timeBins);
   gateShape(1,:,ii) = gateShape(1,:,ii)+N1;
   [N2,~] = histcounts(chN_phot_time{2}(chN_phot_cycles{2}==cycleList(jj),2),timeBins);
   gateShape(2,:,ii) = gateShape(2,:,ii)+N2;
   end
end

end