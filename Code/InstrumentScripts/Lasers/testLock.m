%check the lasers are locked before the sequqence begins
function testLock(freqList)
dat=round(getWLMFreq(),4);
assert(dat(1)==384.2270,'master lock failed!');
assert(dat(2)==384.2283,'cooling lock failed!');
assert(dat(3)==384.2347,'repump lock failed!');
assert(dat(8)==384.2277,'probe lock failed!');
fprintf('laser lock verified by WLM (pre-sequece) reading at %s\n',datestr(now))
end


