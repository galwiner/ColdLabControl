myInstrument = icdevice('AgInfiniiVision.mdd', 'USB0::0x0957::0x179A::MY55140525::0::INSTR');
connect(myInstrument);
% Get information about the driver
Utility = get(myInstrument, 'Utility');
Revision = invoke(Utility, 'revisionquery');
DriverIdentification = get(myInstrument,'Inherentiviattributesdriveridentification');
InstrumentIdentification = get(myInstrument,'Inherentiviattributesinstrumentidentification');
Vendor = get(DriverIdentification, 'Specific_Driver_Vendor');
Description = get(DriverIdentification, 'Specific_Driver_Description');
InstrumentModel = get(InstrumentIdentification, 'Instrument_Model');
FirmwareRev = get(InstrumentIdentification, 'Instrument_Firmware_Revision');

% Print the queried driver properties
fprintf('Revision:        %s\n', Revision);
fprintf('Vendor:          %s\n', Vendor);
fprintf('Description:     %s\n', Description);
fprintf('InstrumentModel: %s\n', InstrumentModel);
fprintf('FirmwareRev:     %s\n', FirmwareRev);
fprintf(' \n');
Measurement = get(myInstrument, 'Instrumentspecificmeasurement');
invoke(Measurement, 'measurementsautosetup');
WaveformArray = zeros(1,10000);
[WaveformArray,ActualPoints,InitialX,Xincreament] = invoke(Measurement, 'measurementfetchwaveform', 'Channel1', size(WaveformArray,2), WaveformArray);
% Display the fetched data
plot(WaveformArray(1:ActualPoints));

% If there are any errors, query the driver to retrieve and display them.
ErrorNum = 1;
while (ErrorNum ~= 0)
    [ErrorNum, ErrorMsg] = invoke(Utility, 'errorquery');
    fprintf('ErrorQuery: %d, %s\n', ErrorNum, ErrorMsg);
end

disconnect(myInstrument);
% Remove instrument objects from memory
delete(myInstrument);