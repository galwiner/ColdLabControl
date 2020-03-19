function [array1,array2] = extractArray(a,dim)
if size(a,dim)~=2
    error('size of a along dim must be 2!')
end
S.subs = repmat({':'},1,ndims(a));
S.subs{dim} = 2; %extract the 1st element in dimenssion dim
S.type = '()';
array1 = subsasgn(a,S,[]);
S.subs{dim} = 1; %extract the 2st element in dimenssion dim
array2 = subsasgn(a,S,[]);
end