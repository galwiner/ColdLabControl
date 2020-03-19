function expandedVec = ExpandVecForFit(origVec,size)
if ~isvector(origVec)
    error('origVec must be a vector!')
end
if rem(size,1)~=0
    error('zize must be an integer!');
end
expandedVec = linspace(min(origVec),max(origVec),size);

end