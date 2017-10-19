classdef Thorcam < handle
    %class to represent a thorcamera
    
    properties
        ImageData
        cam
        err 
    end
    
    properties (Access=private)
        state %is the camera running?
        scale % m / pix
    end
    
    properties (Dependent)
        x %image plane coordinates x
        y %image plane coordinates y
    end
    
    methods
        function obj = Thorcam()
            
            [obj.cam, obj.ImageData, obj.err]=obj.initiate();
            scale=1;
        end
        
        function  [cam, ImageData, err]=initiate(obj)
            p=mfilename('fullpath');
            currfolder=fileparts(p);
            asmfile=fullfile(currfolder,'uc480DotNet.dll');
            %load the .net assembly and initialise the camera
            asm = System.AppDomain.CurrentDomain.GetAssemblies;
            if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
                    'uc480', length('uc480DotNet')), 1:asm.Length))
                NET.addAssembly(asmfile);
                cam = uc480.Camera;
                % Initialize camera, setting window handle for display
                % Change the first argument from 0 to camera ID to initialize a specific
                % camera, otherwise first camera found will be initialized
                cam.Init(0);
                
                % Ensure Direct3D mode is set
                cam.Display.Mode.Set(uc480.Defines.DisplayMode.Direct3D);
                
                % Set camera gain
                cam.Gain.Hardware.Boost.SetEnable(false);
                cam.Gain.Hardware.ConvertScaledToFactor.Blue(0);
                cam.Gain.Hardware.ConvertScaledToFactor.Green(0);
                cam.Gain.Hardware.ConvertScaledToFactor.Master(0);
                cam.Gain.Hardware.ConvertScaledToFactor.Red(0);
                err = cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);
                
                err = cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);
                
                % Set up camera for copying image to Matlab memory for processing
                [err, ImageData.ID] = cam.Memory.Allocate(true);
                [err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch]= cam.Memory.Inquire(ImageData.ID);
                cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.SensorRaw8);
                
            end
            
            
        end
        
        function startLiveMode(obj)
            obj.cam.Acquisition.Capture;
        end
        
        function im=getImage(obj)
            obj.cam.DirectRenderer.StealNextFrame(uc480.Defines.DeviceParameter.Wait);  % Copy image from graphics card to RAM (wait for completion)
            %[err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch] = cam.Memory.Inquire(ImageData.ID);
            [obj.err, im] = obj.cam.Memory.CopyToArray(obj.ImageData.ID);                        % Copy image from RAM to Matlab array
            if isempty(im)
                im = [];
                return
            end
            im = reshape(double(im), [obj.ImageData.Width, obj.ImageData.Height]).';
        end
        
        
        function setHWTrig(obj)
            obj.cam.Trigger.Set(uc480.Defines.TriggerMode.Lo_Hi);
        end
        
        function val=get.x(obj)
            w=obj.ImageData.Width;
            
            val=linspace(-w/2,w/2,w)*obj.scale;
        end
        
        function val=get.y(obj)
            h=obj.ImageData.Height;
            val=linspace(-h/2,h/2,h)*obj.scale;
        end
        
        function delete(obj)
            obj.cam.Exit()
            disp('Thorcam closed');
        end
    end
end

