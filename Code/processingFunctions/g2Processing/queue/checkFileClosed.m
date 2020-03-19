function bool=checkFileClosed(fileName)
    d=dir(fileName);
    if isempty(d)