global p

% noiseFileName=fullfile(getCurrentSaveFolder(),['noiseAndBGFile_' num2str(hour(now)) '.mat']);
noiseFileName=fullfile(getCurrentSaveFolder(),['noiseAndBGFile_' num2str(p.probePower) '.mat']);
% d=dir(fullfile(getCurrentSaveFolder(),'noiseAndBGFile_*.mat'));
d=dir(noiseFileName);
if isempty(d)
    warning('no noise files, running GetNoiseAndBackground');
    GetNoiseAndBackground;
    d=dir(fullfile(getCurrentSaveFolder(),'noiseAndBGFile_*.mat'));
end
%     warning('there may be more than one noise file, loading the LAST one.')
    
    names={d.name};
    noiseFileName=fullfile(getCurrentSaveFolder(),['noiseAndBGFile_' num2str(p.probePower) '.mat']);
%     load(fullfile(getCurrentSaveFolder(),names{length(names)}));
        load(fullfile(noiseFileName));
    
    p.bgRate=bgRate;
    p.noiseRate=noiseRate;
    if isfield(p,'probePower')
        if probePower~=p.probePower
            warning('trying to load noise and bg taken with a different probe power, running get noise and background');
            GetNoiseAndBackground;
        end
    else
            warning(sprintf('make sure probe power matches that used to take the background: %d mW',probePower));
    end
    fprintf('Loaded noise file\n');


