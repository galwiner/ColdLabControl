%  Copyright Keysight Technologies 2011-2017	
%
%  Keysight IVI-C Driver Example Program
%
% 
% Creates a driver object, reads a few Identity attributes
% and checks the instrument error queue.
% May include additional instrument specific functionality.
% 
% See driver help topic "Programming with the IVI-C Driver in Various Development Environments"
% for additional programming information.
%
% Runs in simulation mode without an instrument.

disp(blanks(1)');
disp('  ML_Example1');
try 
    % Wrap the driver if needed
    if (exist('AgInfiniiVision_ivic.mdd','file') == 0)
        makemid('AgInfiniiVision', 'AgInfiniiVision_ivic.mdd', 'ivi-c');
    end
    
    resourceDesc = 'USB0::0x0957::0x179A::MY55140525::0::INSTR'; 
    initOptions = 'QueryInstrStatus=true, Simulate=False, DriverSetup= Model=, Trace=false';			
    
    % Create driver instance
    driver = icdevice('AgInfiniiVision_ivic', resourceDesc, 'optionstring', initOptions);
    connect(driver);
    disp('Driver Initialized');
    
    % Print a few identifier attributes
    disp(['Prefix:      ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Prefix]);
    disp(['Revision:        ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Revision]);
    disp(['Vendor:          ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Vendor]);
    disp(['Description:     ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Description]);
    disp(['InstrumentModel: ', driver.Inherentiviattributesinstrumentidentification.Instrument_Model]);
    disp(['FirmwareRev:     ', driver.Inherentiviattributesinstrumentidentification.Instrument_Firmware_Revision]);
    disp(['Serial #:        ', driver.Instrumentspecificsystem.System_Serial_Number]);
    simulate = driver.Inherentiviattributesuseroptions.Simulate;
    if simulate == true
		disp(blanks(1));
        disp('Simulate:        True');
    else
        disp('Simulate:        False');
    end
    disp(blanks(1));

    invoke(driver.Instrumentspecificmeasurement, 'measurementsautosetup');
    invoke(driver.Instrumentspecificmeasurement, 'measurementsinitiate');

    WaveformArray = zeros(65000, 1);
    [WaveformArray, ActualPoints, InitialX, XIncrement] = invoke(driver.Instrumentspecificmeasurement, 'measurementfetchwaveform', 'Channel1', 65000, WaveformArray);

    disp('Waveform Points:');
    plot(WaveformArray);
    disp('InitialX');
    disp(InitialX);
    disp('XIncrement');
    disp(XIncrement);

				
    % Check instrument for errors
    errorNum = -1;
    errorMsg = ('');
    disp(blanks(1)');
    while (errorNum ~= 0)
    	[errorNum, errorMsg] = invoke(driver.Utility, 'errorquery');
    	disp(['ErrorQuery: ', num2str(errorNum), ', ', errorMsg]);
    end

    
catch exception
    disp(getReport(exception));
end

if (strcmp(driver.Status, 'open'))
    disconnect(driver);
    delete(driver);
    disp('Driver Closed');
end

disp('Done');
disp(blanks(1)');

