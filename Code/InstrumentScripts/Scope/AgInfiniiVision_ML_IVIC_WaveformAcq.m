% Copyright Keysight Technologies 2011-2017
%
% Keysight IVI-C Driver Example Program
%
% Creates a driver object, reads a few Identity 
% attributes, and checks the instrument error queue.
% May include additional instrument specific functionality.
%
% See driver help topic "Programming with the IVI-C Driver in Various Development Environments"
% for additional programming information.
%
% Runs in simulation mode without an instrument.

disp(blanks(1)');
disp('  ML_WaveformAcq');

% Wrap the driver if needed
if (exist('AgInfiniiVision_ivic.mdd','file') == 0)
    makemid('AgInfiniiVision', 'AgInfiniiVision_ivic.mdd', 'ivi-c');
end

resourceDesc = 'USB0::0x0957::0x179A::MY55140525::0::INSTR'; 
initOptions = 'QueryInstrStatus=true, Simulate=False, DriverSetup= Model=, Trace=false';			

% Create driver instance
driver = icdevice('AgInfiniiVision_ivic', resourceDesc, 'optionstring', initOptions);
connect(driver);
% disp('Driver Initialized');
% 
% % Print a few identifier attributes
% disp(['Prefix:      ',     driver.Inherentiviattributesdriveridentification.Specific_Driver_Prefix]);
% disp(['Revision:        ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Revision]);
% disp(['Vendor:          ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Vendor]);
% disp(['Description:     ', driver.Inherentiviattributesdriveridentification.Specific_Driver_Description]);
% disp(['InstrumentModel: ', driver.Inherentiviattributesinstrumentidentification.Instrument_Model]);
% disp(['FirmwareRev:     ', driver.Inherentiviattributesinstrumentidentification.Instrument_Firmware_Revision]);
% disp(['Serial #:        ', driver.Instrumentspecificsystem.System_Serial_Number]);
% simulate = driver.Inherentiviattributesuseroptions.Simulate;
% if simulate == true
%     disp(blanks(1));
%     disp('Simulate:        True');
% else
%     disp('Simulate:        False');
% end
% disp(blanks(1));

% Reset instrument and load the default setup
invoke(driver.Utility, 'reset');

% Set Trigger Mode (EDGE, PULSe, PATTern, etc....)
driver.Trigger.Trigger_Type = 1;

% Set Edge trigger parameters
driver.Trigger.Trigger_Source = 'Channel1';
driver.Trigger.Trigger_Level = 0.1;
driver.Triggeredgetriggering.Trigger_Slope = 1;

% Set vertical scale and offset
driver.RepCapIdentifier = 'Channel1';
driver.Instrumentspecificchannel.Scale = 0.05;
driver.Channel.Vertical_Offset = 0;

% Set horizontal scale and offset
driver.RepCapIdentifier = '';
driver.Instrumentspecifictimebase.Horizontal_Scale = 0.0002;
driver.Acquisition.Acquisition_Start_Time = 0;

% Set the acquisition type (Normal, Peak, Average, or HResolution)
driver.Acquisition.Acquisition_Type = 0;

% Capture an acquisition
invoke(driver.Instrumentspecificmeasurement, 'measurementsautosetup');
invoke(driver.Instrumentspecificmeasurement, 'measurementsinitiate');

% Analyze the captured waveform, making a couple of measurements
driver.RepCapIdentifier = 'Channel1';
driver.Instrumentspecificmeasurementconfiguration.Source2 = 'Channel1';
[frequency] = invoke(driver.Instrumentspecificmeasurement, 'measurementreadwaveformmeasurement', 'Channel1', 2, 1000); %AGINFINIIVISION_VAL_FREQUENCY = 2
[amplitude] = invoke(driver.Instrumentspecificmeasurement, 'measurementreadwaveformmeasurement', 'Channel1', 15, 1000); %AGINFINIIVISION_VAL_AMPLITUDE = 15

% Read screen image.

try % Read screen image
    screenshot = zeros(1000, 1);
    [screenshot, size] = invoke(driver.Instrumentspecificdisplay, 'displaygetscreenbitmap', 2, 0, 100000, screenshot); %AGINFINIIVISION_VAL_DISPLAY_IMAGE_FORMATPNG2 = 2, AGINFINIIVISION_VAL_DISPLAY_PALETTE_COLOR2 = 0
    % Save screen image to disk
    fileId = fopen('screenshot.png','w');
    fwrite(fileId,screenshot);
    fclose(fileId);
    
    % Read the image from disk and display it
    img = imread('screenshot.png');
    image(img);
    
catch ME, 
    %disp(ME.message);
    if size == 0
        % Note that for PXI-based models (e.g. M924x), the Soft Front Panel
        % needs to be active for Display::GetScreenBitmap to work.
        disp(' GetScreenBitmap: Failed to obtain screenshot.');
    end
    end

disp('Screen Image byte:');
disp(size);

% Download waveform data
% Set the waveform points mode
driver.RepCapIdentifier = '';
driver.Instrumentspecificwaveform.Point_Mode = 2;

% Get the number of waveform points available
Point_Count = driver.Instrumentspecificwaveform.Point_Count;

% Set the waveform source
driver.Instrumentspecificwaveform.Source = 'Channel1';

% Choose the format fo the data returned (Word, Byte, Ascii)
driver.Instrumentspecificwaveform.Data_Format = 1;

% Display the waveform settings
Val = zeros(100, 1);
[Val, ValActualSize1] = invoke(driver.Instrumentspecificwaveform, 'waveformpreamble', 100, Val);

wavFormat = Val(1);
if wavFormat == 0.0
    fprintf('Waveform format:           BYTE\n');
elseif (wavFormat == 1.0)
    fprintf('Waveform Format:           WORD\n');
elseif (wavFormat == 2.0)
    fprintf('Waveform Format:           ASCii\n');
end

aType = Val(2);
if aType == 0.0
    fprintf('Acquire Type:              NORMal\n');
elseif aType == 1.0
    fprintf('Acquire Type:              PEAK\n');
elseif aType == 2.0
    fprintf('Acquire Type:              AVERage\n');
else  aType == 3.0;
    fprintf('Acquire Type:              HRESolution\n');
end

wavPoints = Val(3);
disp('Waveform Points:           ');
disp(wavPoints);

avgCount = Val(4);
disp('Waveform Average Count:    ');
disp(avgCount);

xIncrement = Val(5);
disp('Waveform X Increment:       ');
disp(xIncrement);

xOrigin = Val(6);
disp('Waveform X Origin:         ');
disp(xOrigin);

xReference = Val(7);
disp('Waveform X Reference:      ');
disp(xReference);

yIncrement = Val(8);
disp('Waveform Y Increment:      ');
disp(yIncrement)

yOrigin = Val(9);
disp('Waveform Y Origin:         ');
disp(yOrigin);

yReference = Val(10);
disp('Waveform Y Reference:      ');
disp(yReference);

% Read waveform data
WaveformArray = zeros(2000000, 1);
[WaveformArray, ActualPoints, InitialX, XIncrement] = invoke(driver.Instrumentspecificmeasurement, 'measurementreadwaveform', 'Channel1', 2000000, 10000, WaveformArray);

% Plot the waveform
plot(WaveformArray);

% Check instrument for errors
errorNum = -1;
errorMsg = ('');
disp(blanks(1)');

while (errorNum ~= 0)
    [errorNum, errorMsg] = invoke(driver.Utility, 'errorquery');
    disp(['ErrorQuery: ', num2str(errorNum), ', ', errorMsg]);
end

if (strcmp(driver.Status, 'open'))
    disconnect(driver);
    delete(driver);
    disp('Driver Closed');
end

disp('Done');
disp(blanks(1)');

