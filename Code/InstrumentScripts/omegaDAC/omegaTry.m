library = NET.addAssembly('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\InstrumentScripts\omegaDAC\MccDaq.dll');
board=MccDaq.MccBoard(0);
range=MccDaq.Range.Bip10Volts;
chan=0;
Options=MccDaq.VOutOptions.Default;
board.VOut(2, range, -7, Options)

