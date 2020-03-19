function mean_phot_per_cycle = meanPhot_per_cycle(phot_per_cycle,average)
% for ii = 1:average:(length(phot_per_cycle)-average)
% mean_phot_per_cycle(ii) = mean(phot_per_cycle(ii:(ii+average-1)));
% end
res = mod(length(phot_per_cycle),average);
if res~=0
    endSize = ceil(length(phot_per_cycle)/average)*average;
    phot_per_cycle(end:endSize) = nan;
end
mean_phot_per_cycle = reshape(phot_per_cycle,[average,length(phot_per_cycle)/average]);
mean_phot_per_cycle = nanmean(mean_phot_per_cycle,1);
end