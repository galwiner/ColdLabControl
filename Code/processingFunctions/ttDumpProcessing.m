function [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle,datMatFile,sortedPulses,datMat]=ttDumpProcessing_temp(files)
    global r
    global p
    [datMatFile,datMat]=binFileListToMat(files);
    load(datMatFile);
    sortedPulses=sortTimeStampsByChannels(datMat);
    fprintf('%d gates received\n',length(sortedPulses{1}))
%     profile on
    [chN_phot_cycles,chN_phot_gc,chN_phot_time,phot_per_cycle,chN_gates_each_cycle]=make_chN_cell2(sortedPulses,0.1e6,0.025);
    if isfield(p,'runFixCycles')&&p.runFixCycles==1&&~p.loopingRun
        try
            fixCycles
        catch err
            warning('Error eccured while running fixCycles: %s',err.message)
        end
    end
    
    r.ttRes.chN_phot_cycles=chN_phot_cycles;
    r.ttRes.chN_phot_gc=chN_phot_gc;
    r.ttRes.chN_phot_time=chN_phot_time;
    r.ttRes.phot_per_cycle=phot_per_cycle;
    r.ttRes.chN_gates_each_cycle=chN_gates_each_cycle;
    r.ttRes.datMat=datMat;
    r.ttRes.sortedPulses=sortedPulses;
    if ~p.loopingRun
        if isfield(p,'fname')
            save(p.fname,'r','-append');
        else
            warning('p file name is not saved in p. saving processing results in tt folder!');
            save(datMatFile,'r','-append');
        end
    else
        warning('p.loopingRun==1, not saving tt processed data!')
    end
%     save(datMatFile,'chN_phot_cycles','chN_phot_gc','chN_phot_time','phot_per_cycle','chN_gates_each_cycle','datMat','sortedPulses','-v7.3');
end


