function out = Dec2BinVec(decNum,numOfDigits)
% Returns a vector of 0,1's which is equivalent to the decimal input
% number. numOfDigits, if defined cuts or zero pads the vector to the
% desired length.

out = double(dec2bin(decNum)-48);

if nargin>1
    if numOfDigits < length(out)
        out = out((end-numOfDigits+1):end);
    end
    temp = zeros(1,numOfDigits);
    temp((end-length(out)+1):end) = out;
    out = temp;
end