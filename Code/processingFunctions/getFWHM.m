function [FWHM,upInd,downInd] = getFWHM(data,varargin)
%this function returns the FWHM of the data, where data is a 2d array, where the 1st index is the one to get the FWHM from.
%varargin - input must be in a var name and value pair, such as,
%'scale',scaleVal

if nargin>1
    scaleInd = find(strcmpi(varargin,'scale'));
    if ~isempty(scaleInd)
        scale = varargin{scaleInd+1};
    else
        error('no ''scale'' found in varagin');
    end
    centerInd = find(strcmpi(varargin,'center'));
    if ~isempty(scaleInd)
        centerVal = varargin{centerInd+1};
    end
else
    scale = 1;
end
if ~ismatrix(data)
    error('data must be a 2D array')
end
if isvector(data) %if ddata is a vector, check if it is a column vector, and transpose it
    if size(data,2)>1
        data = data';
    end
end
minVals = min(data,[],1);
if exist('centerVal','var')
    maxInds = centerVal;
    maxVals = data(maxInds);
else
[maxVals,maxInds] = max(data,[],1);
end
amps = maxVals-minVals;

for ii = 1:size(data,2)
    upInd = maxInds(ii)+1;
    downInd = maxInds(ii)-1;
    upFlag = 0;
    downFlag = 0;
while upInd<size(data,1) && downInd>1
    if upFlag == 0
        if data(upInd,ii)<(maxVals(ii)-amps/2)
            upFlag = 1;
        else
            upInd = upInd + 1;
        end
    end
    if downFlag == 0
        if data(downInd,ii)<(maxVals(ii)-amps/2)
            downFlag = 1;
        else
            downInd = downInd - 1;
        end
    end
    if upFlag == 1 && downFlag == 1
        break
    end
end
FWHM(ii) = (upInd-downInd)*scale;
end
end