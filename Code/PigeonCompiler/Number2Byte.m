function out = Number2Byte (decNum,numOfBytes)
% Translates the number to binary representation and cast it into a list of
% bytes (8 bits). The MSB is the out(1,1) cell of the matrix.


binFreq = fliplr(Dec2BinVec(decNum,8*numOfBytes)).';
out = flipud(fliplr(reshape(binFreq,[8 numOfBytes]).'));