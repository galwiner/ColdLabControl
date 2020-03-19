function [PhotPerCycle,PhotPerCycleSDT,unMeanedData] = removeBadCyclesandMean(chN_phot_cycles,NAverage)
%chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle
global p

% if isfield(p,'loopVals') && length(p.loopVals)==2
%     fprintf('treating loopVals{2} as second parameter. not averaging over it.\n');
%     
% end


unMeanedData = nan;
binEdges = 0.5:1:(max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}))+0.5);
photPerCycle(:,1) = histcounts(chN_phot_cycles{1},binEdges);
photPerCycle(:,2) = histcounts(chN_phot_cycles{2},binEdges);
photPerCycle((photPerCycle(:,1)==0),1) = nan;
photPerCycle((photPerCycle(:,2)==0),2) = nan;
% figure;
% plot(1:nbins,photPerCycle)
nCycles = ceil(max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}))/NAverage);
for ii=1:nCycles
    try
        if ii*NAverage>size(photPerCycle,1)
            MeanPhotPerCycle(ii,1) = nanmean(photPerCycle(((ii-1)*NAverage+1):end,1));
            STDPhotPerCycle(ii,1) = nanstd(photPerCycle(((ii-1)*NAverage+1):end,1));
%             unMeanedData{ii,:} = photPerCycle(((ii-1)*NAverage+1):end,1);
        else
            MeanPhotPerCycle(ii,1) = nanmean(photPerCycle(((ii-1)*NAverage+1):ii*NAverage,1));
            STDPhotPerCycle(ii,1) = nanstd(photPerCycle(((ii-1)*NAverage+1):ii*NAverage,1));
%             unMeanedData{ii,:} = photPerCycle(((ii-1)*NAverage+1):ii*NAverage,1);
        end
    catch
       MeanPhotPerCycle(ii,1) = nan; 
    end
    try
        if ii*NAverage>size(photPerCycle,1)
            MeanPhotPerCycle(ii,2) = nanmean(photPerCycle(((ii-1)*NAverage+1):end,2));
            STDPhotPerCycle(ii,2) = nanstd(photPerCycle(((ii-1)*NAverage+1):end,2));
%             unMeanedData{ii,:} = unMeanedData{ii,:}+photPerCycle(((ii-1)*NAverage+1):end,2);
        else
            MeanPhotPerCycle(ii,2) = nanmean(photPerCycle(((ii-1)*NAverage+1):ii*NAverage,2));
            STDPhotPerCycle(ii,2) = nanstd(photPerCycle(((ii-1)*NAverage+1):ii*NAverage,2));
%             unMeanedData{ii,:} = unMeanedData(ii,:)+photPerCycle(((ii-1)*NAverage+1):ii*NAverage,2)';
        end
    catch
        MeanPhotPerCycle(ii,2) = nan;
    end
end
% figure;
% plot(sum(MeanPhotPerCycle,2));
PhotPerCycle = sum(MeanPhotPerCycle,2);
PhotPerCycleSDT = sqrt(STDPhotPerCycle(:,1).^2+STDPhotPerCycle(:,2).^2);
end