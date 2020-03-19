function grad = AHHCurrent2Grad(current,coil)
%This function gets a current, in A, and a coil identifier, 'circ' or
%'rect', and returns the magnetic field gradiant, based on a calibration
%measurment (see in onenote "cold atoms\bias and mot coils\Coils Current
%to Magnetic Field Calibration")
if nargin == 1
  coil = 'circ';
end
switch coil
    case 'circ'
       grad = 0.3767*current;
    case 'rect'
        grad = 0.2*current;
    otherwise
        error('%s is not a valid coil.',coil);
end

end