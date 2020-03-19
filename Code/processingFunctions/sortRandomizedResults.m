function sortedDat = sortRandomizedResults(data)
%this function gets a matrix in the format of
%[innerLoopLength,outerLoopLength] and returns it after sorting to the
%un-rendomized order
global p
global r
sortedDat = zeros(size(data));
if p.randomizeLoopVals~=1
    sortedDat = data;
    warning('p.randomizeLoopVals=0, not sorting')
    return
end

if length(p.loopVals)<2%only inner loop scan
    if length(data)~=length(p.loopVals{1})
        error('only innerloop detected, but data is not the same length as p.loopVals{1}!')
    end
    if ~iscolumn(r.runValsMap{1})
        r.runValsMap{1} = r.runValsMap{1}';
    end
    sortedDat=sortrows([r.runValsMap{1},data],1);
    sortedDat(:,1) = []; 
    return
end
if ~isequal(size(data),[length(p.loopVals{1}),length(p.loopVals{2})])
    error('data must be in this format : [innerLoopLength,outerLoopLength]')
end

for jj = 1:length(p.loopVals{1})
    innerInd = find(r.runValsMap{1}==p.loopVals{1}(jj));
    sortedDat(jj,:) = data(innerInd,:);
    tmpRow = sortedDat(jj,:);
    for ii = 1:length(p.loopVals{2})
        outerInd = find(r.runValsMap{2}==p.loopVals{2}(ii));
        reconLoopVals(ii) = r.runValsMap{1}(outerInd);
        tmpRow(ii) = sortedDat(jj,outerInd);
    end
    sortedDat(jj,:) = tmpRow;
end

% sorted1,idx =sortrows([r.runValsMap{2}',data']);
% sorted1=sorted1(:,2:end);
% sorted2=sortrows([r.runValsMap{1}',sorted1']);
% sorted2=sorted1(:,2:end);
% sortedData=sorted2';
% figure;
% imagesc(sortedData)

    
