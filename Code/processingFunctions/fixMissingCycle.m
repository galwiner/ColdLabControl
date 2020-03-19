for jj = 1:length(missingCycles)
    phot_per_cycle(end+1) = nan;
    phot_per_cycle = [phot_per_cycle(1:missingCycles(jj)-1),nan,phot_per_cycle((missingCycles(jj)):(end-1))];
    chN_phot_cycles{1}(chN_phot_cycles{1}>=missingCycles(jj)) = chN_phot_cycles{1}(chN_phot_cycles{1}>=missingCycles(jj),:)+1;%add 1 to all next cycles
    chN_phot_cycles{2}(chN_phot_cycles{2}>=missingCycles(jj)) = chN_phot_cycles{2}(chN_phot_cycles{2}>=missingCycles(jj),:)+1;%add 1 to all next cycles
end