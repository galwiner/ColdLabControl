function dataArray = removeParasiticPhotons(dataArray)
%remove any photons 25nS apart

gateTimes = double(dataArray{1}); %channel 1 is the gating channel

for cInd=2:length(dataArray)
    numPhotons=length(dataArray{cInd});
    photonT=double(dataArray{cInd});
%     remArray=false(size(photonT));
    remArray=[false diff(photonT)<25e3];
    dataArray{cInd}(remArray)=[];
end
end
