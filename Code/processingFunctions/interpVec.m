function intV = interpVec(origV)
ii = 1;
intV = origV;
while ii <length(origV)
    jj = ii+1;
    while jj<=length(origV)
        if origV(jj)~=origV(ii)
            intV(ii:jj) = linspace(origV(ii),origV(jj),jj-ii+1);
            break;
        else
           jj = jj+1; 
        end
    end
    ii = jj;
end
end