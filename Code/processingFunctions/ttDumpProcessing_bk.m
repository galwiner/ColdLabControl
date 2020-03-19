function [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,datMatFile,sortedPulses,datMat]=ttDumpProcessing(files)
global p
    [datMatFile,datMat]=binFileListToMat(files);
    load(datMatFile);
    sortedPulses=sortTimeStampsByChannels(datMat);
    fprintf('%d gates received\n',length(sortedPulses{1}))
%     profile on
    [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,0.025);
    if isfield(p,'runFixCycles')&&p.runFixCycles==1
        try
            fixCycles
        catch err
            warning('Error eccured while running fixCycles: %s',err.message)
        end
    end
%     profile viewer
    save(datMatFile,'chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle','datMat','sortedPulses','-v7.3');
end


