function [chN_phot_cycles,chN_phot_gc,chN_phot_time]=parseDetectorData(fileNames)
%fileNames is cell array of strings containing the full path of all the
%mat files we want to pre-process. The output of this function can be run
%on the MIT post-processor.

%LOAD IN THE FIRST FILE TO HAVE A BASELINE P FILE%

[folder,name,ext]=fileparts(fileNames{1});
r=regexp(name,'\_','split');
load(fullfile(folder,['p_' r{2} '_' r{3} '__' r{5} '.mat']));
firstP=p;

%ITERATE THE FILE LIST
for ind=1:length(fileNames)
    [folder,name,ext]=fileparts(fileNames{ind});
    r=regexp(name,'\_','split');
    pfile=fullfile(folder,['p_' r{2} '_' r{3} '__' r{5} '.mat']);
    load(pfile);
    
    if ~isequaln(p,firstP)
        warning("the p file for file number %d is different to the first p file. ignoring this file",r{2})
        continue
    end %verify the p file has not changed
    
    load(fileNames{ind},'datMat'); %loads the raw data: first row is time tags, second row is channel numbers
    
    for k=1:1
        if ~isfield(p,'gateTime')
            p.gateTime=20;
            warning("no gateTime in p, using %d uS default",p.gateTime);
        end
        
        if ~isfield(p,'cycleTime')
            p.cycleTime=2e4;
            warning("no cycleTime in p, using %d uS default",p.cycleTime);
        end
        
        if ~isfield(p,'earlyTthreshold')
            p.earlyTthreshold=1;
            warning("no earlyTthreshold in p, using %d uS default",p.earlyTthreshold);
        end
        
        if ~isfield(p,'lateTthreshold')
            p.lateTthreshold=p.gateTime/2;
            warning("no lateTthreshold in p, using %d uS default (0.5*p.gateTime)",p.lateTthreshold);
        end
    end %added this just to fold the p file field tests
    try
        sortedPulses=sortTimeStampsByChannels(datMat);%take raw data and sort time tags by channel
%         sortedPulses=removeAfterPulses(sortedPulses); %remove after pulses appearing up to 25nS after main pulse (dead time)
% %         shiftedPulses=shiftTimeStampsToGateStart(sortedPulses);%shift timestamps so it is referenced to pulse start time
%         chN_phot_time=make_chN_phot_time(sortedPulses); 
%         shiftedPulses=removeEarlyPhotons(shiftedPulses,p.earlyTthreshold); %removes any time tags in the first 1 us (this is the default theshold parameter)
%         shiftedPulses=removeLatePhotons(shiftedPulses,p.lateTthreshold);
    [chN_phot_cycles,chN_phot_gc,chN_phot_time]=make_chN_cell(sortedPulses);
    catch err
        warning('error during parseDetectorData. %s\n error in function %s, line %d',err.message,err.stack(1).name,err.stack(1).line)
        shiftedPulses = zeros(size(datMat));
        return
    end
end

try
    
    
    % parsedData=sortedPulses;
end

