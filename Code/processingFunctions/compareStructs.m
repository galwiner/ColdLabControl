function [diffFieldNames,diffTable]=compareStructs(A,B)
namesA=fieldnames(A);
namesB=fieldnames(B);
diffFieldNames=setdiff(namesA,namesB);
for ind=1:length(namesA)
    
    if isstruct(A.(namesA{ind}))
        compareStructs(A.(namesA{ind}),B.(namesA{ind}));
    else
        if ~isequaln(A.(namesA{ind}),B.(namesA{ind}))
            diffFieldNames{end+1}=namesA{ind}
        end
    end
end
diffTable=table();
for ind=1:length(diffFieldNames)
    if ischar(A.(diffFieldNames{ind}))
        A.(diffFieldNames{ind})=string(A.(diffFieldNames{ind}));
    end
     
    diffTable=addvars(diffTable,A.(diffFieldNames{ind}));
end

diffTable2=table();
for ind=1:length(diffFieldNames)
    if ischar(B.(diffFieldNames{ind}))
        B.(diffFieldNames{ind})=string(B.(diffFieldNames{ind}));
    end
        
    diffTable2=addvars(diffTable2,B.(diffFieldNames{ind}));
end

diffTable=[diffTable;diffTable2];

diffTable.Properties.VariableNames=diffFieldNames;

end
