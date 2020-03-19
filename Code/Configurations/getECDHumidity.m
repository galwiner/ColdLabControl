function humidity = getECDHumidity(sensV)
%this function gets the sensore voltage and returns the humidity in %.
%the calibration is based on a linear fit to the sensor data, saved as a
%mat file :'D:\Box Sync\Lab\ExpCold\ControlSystem\Code\Configurations\ECDHumidityCalibration.mat'
humidity = 32.73*sensV-25.28;
end