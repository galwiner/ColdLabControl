function resonanceIndex = findResonanceLocation(x,y)
[maxExpY,maxX]=findpeaks(smooth(exp(-y),500),x,'MinPeakProminence',0.01,'SortStr','descend');


resonanceIndex=find(maxExpY(1)==smooth(exp(-y),500),1);
end
