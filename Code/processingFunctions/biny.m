function benedIm  = biny(im,binSize)
binEdges = 1:binSize:size(im,1);
benedIm(1,:) = sum(im(1:binSize,:),1);
for ii = 2:length(binEdges)
    benedIm(ii,:) = sum(im(binEdges(ii-1)+1:binEdges(ii),:),1);
end
end
