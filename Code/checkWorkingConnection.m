function state=checkWorkingConnection(object)
if isempty(object)
    state=0;
    return
else
    state=class(object);
end
    
    
end
