function out = BinVec2Dec(binVec)
% Returns the decimal number of the value of the binary vector

out = bin2dec(char(binVec+48));