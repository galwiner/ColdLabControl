function sortedParts=sortRandomizedParts(parts,r)
for ind=1:length(parts)
        sortedParts{ind}=sortrows([r.runValsMap{1}',parts{ind}]);
        sortedParts{ind}=sortedParts{ind}(:,2:end);
        if length(r.runValsMap)>1
            sortedParts{ind}=sortrows([r.runValsMap{2}',sortedParts{ind}']);
            sortedParts{ind}=sortedParts{ind}(:,2:end);
        end
        sortedParts{ind}=sortedParts{ind}';
end
end
