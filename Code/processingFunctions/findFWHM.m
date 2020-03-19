function [FWHM,upInd,downInd] = findFWHM(freq,data,center)
%LD 29.08.18.
%This function finds the FWHM of a data from the center.
%The function assums that center is a local minimum
if ~isvector(data)
    error('data must be a vector!');
end
upFlag = 0;
downFlag = 0;
upInd = length(data);
downInd = 1;
ii = 1;
while ii <= length(data)
    try
        if data(center+ii)<=0.5*data(center) && upFlag == 0
           upInd = center+ii;
           upFlag = 1;
        end
        if data(center-ii)<=0.5*data(center) && downFlag == 0
            downInd = center-ii;
            downFlag = 1;
        end
    catch
        
    end
  ii = ii +1;
end
FWHM = abs(freq(upInd) - freq(downInd));