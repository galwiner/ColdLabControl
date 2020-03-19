function photPerGate=getPhotonsPerGate(gateArray)
if isempty(gateArray)
    photPerGate = 0;
    return;
end
    
    
for ii=1:length(gateArray)
    photPerGate(ii) = length(gateArray{ii});
end
end

