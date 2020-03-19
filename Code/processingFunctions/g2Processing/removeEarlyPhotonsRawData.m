function dataArray = removeEarlyPhotonsRawData(dataArray,timeThreshold)
%remove any early photon time tags in each gate. This assumes the runs
%input has NOT!!! been shifted.
if nargin==1
    timeThreshold=5e5; % 1 ps
end

gateTimes = double(dataArray{1}); %channel 1 is the gating channel
%
% for cInd=2:length(dataArray)
%     photonT=double(dataArray{cInd});
%     numPhotons=length(dataArray{cInd});
%     sumVect=zeros(1,numPhotons);
%     chunkSize=4;
%     for ind=1:ceil(numPhotons/chunkSize)
%         if chunkSize*ind>numPhotons
%             endInd=numPhotons;
%         else
%             endInd=chunkSize*ind;
%         end
%     startInd=(chunkSize*(ind-1)+1);
% %     disp(startInd)
% %     disp(endInd)
%     tic
%     diffMatrix=abs(bsxfun(@minus,gateTimes',photonT(startInd:endInd)))<timeThreshold;
%     toc
% %     tic
%     sumVect(startInd:endInd)=(sum(diffMatrix,1)~=0);
% %     toc
%     end
% end

%
%
% dataArray=1;

for cInd=2:length(dataArray)
    numPhotons=length(dataArray{cInd});
    photonT=double(dataArray{cInd});
    remArray=false(size(photonT));
%     for gInd=1:length(gateTimes)
        gateIdx=1;
        for pInd=1:length(photonT)
            
            gateIdx=find(abs(photonT(pInd)-gateTimes(gateIdx:end)<timeThreshold),1);
            if ~isempty(gateIdx) 
              remArray(pInd)=true;
            end

            if mod(pInd,10000)==0
                fprintf("%d of %d\n",pInd,numPhotons);
%                 disp(pInd)
            end
        end
        dataArray{cInd}(remArray)=[];
end

end