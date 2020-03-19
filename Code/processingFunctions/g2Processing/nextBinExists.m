function bool=nextBinExists(binFileName)
    [folder,name,ext]=fileparts(binFileName);
    r=regexp(name,'\_','split');
    idx=str2double(r{3});
    nextIdx=sprintf('0%d',idx+1);
    nextBinName=[r{1} '_' r{2} '_' nextIdx '__' r{5} '.bin'];
    d=dir(fullfile(folder,nextBinName));
    if isempty(d)
        bool=false;
    else 
        bool=true
    end
end
        