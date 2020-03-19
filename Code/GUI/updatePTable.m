function updatePTable(app)
    global p
    names=fieldnames(p);
    for ind=1:length(names)
        thisDat=p.(names{ind});
        singleton=all(size(thisDat)==[1 1]);
        if (isnumeric(thisDat) || islogical(thisDat) || ischar(thisDat)) && singleton
            dat{ind}=p.(names{ind});
        else
            dat{ind}='edit in command window';
        end
    end
    app.pTable.Data=horzcat(fieldnames(p),dat');
end
