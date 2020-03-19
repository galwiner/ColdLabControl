function [xCents,yCents] = findCents(ims)
%This function gets an image array, a, and returns the center position of
%an absorption freture in the images
[~,xCents] = (min(sum(ims,1),[],2));
xCents = squeeze(xCents);
[~,yCents] = (min(sum(ims,2),[],1));
yCents = squeeze(yCents);
end