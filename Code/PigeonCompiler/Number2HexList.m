function out = Number2HexList(decNum,numOfBytes)
% Like Number2Byte, thoght translates the bytes to Hex basis

bytesList = Number2Byte (decNum,numOfBytes);
for index1 = 1:size(bytesList,1)
    for index2 = 1:2
        out(index1,index2) = dec2hex(BinVec2Dec(bytesList(index1,[1:4]+4*(index2-1))));
    end
end