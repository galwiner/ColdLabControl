function idx=getRunNumFromFile(binFileName)
    [folder,name,ext]=fileparts(binFileName);
    r=regexp(name,'\_','split');
    idx=str2double(r{3})
    