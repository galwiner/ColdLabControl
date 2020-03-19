function [xWidth,yWidth] = getAbsImageWidth(imVec,varargin)
%this function returns the esstimation to the width of an absorption image
%vector.
%varargin - input must be in a var name and value pair, such as,
%'scale',scaleVal
if ndims(imVec)> 3
    error('data must be an image vector')
end
if nargin>1
    scaleInd = find(strcmpi(varargin,'scale'));
    if ~isempty(scaleInd)
        scale = varargin{scaleInd+1};
    else
        error('no ''scale'' found in varagin');
    end
else
    scale = 1;
end
xIms = 1./squeeze(sum(imVec,1));
yIms = 1./squeeze(sum(imVec,2));
xWidth = getFWHM(xIms,'scale',scale)/4;
yWidth = getFWHM(yIms,'scale',scale)/4;
end