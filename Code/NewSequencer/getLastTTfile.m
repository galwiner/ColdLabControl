function [fname,lastFileInd,prefix]=getLastTTfile


path=getCurrentSaveFolder();
d=dir([path '\*.bin']);
files=d(~[d.isdir]);
files={files.name};
maxNum=0;
for ind=1:length(files)
    r=regexp(files{ind},'\_','split');    
    if strcmpi(r{1},'noiseAndBGFile')
        continue;
    else
        fileInd=str2double(r{3});
        if fileInd>maxNum
            maxNum=fileInd;
            maxInd = ind;
        end
    end
end
r=regexp(files{maxInd},'\_','split');    
f=regexp(r{5},'\.','split');
fname=fullfile(path,[r{1} '_' r{2} '_' num2str(maxNum) '__' f{1} '.mat']);
r=regexp(fname,'\_','split');
lastFileInd=maxNum;
% r=regexp(r{end},'\.','split');
prefix=path;
end
