% function pFileDiff(path)
path='E:\Box Sync\Lab\ExpCold\Measurements\2020\01\18';
d=dir([path '\*.mat'])
for ind=1:length(d)
    dat=load(d(ind).name)
    pstructs{ind}=dat.p;
end
tf = isequaln(pstructs{1},pstructs{2})

