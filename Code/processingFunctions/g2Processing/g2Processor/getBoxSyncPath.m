function path= getBoxSyncPath()
path='d:\box sync';
d=dir(path);
if isempty(d)
    path='e:\box sync';
    d=dir(path);
    if isempty(d)
        error("can't find box sync");
    end
end

end

