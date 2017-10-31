deviceObj = icdevice('AgInfiniiVision.mdd', 'USB0::0x0957::0x1799::MY55462017::0::INSTR');
connect(deviceObj);
get1 = get(deviceObj, 'InstrumentModel');
