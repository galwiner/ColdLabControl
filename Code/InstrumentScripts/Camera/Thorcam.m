classdef Thorcam < handle
    %class to represent a thorcamera
    
    properties
        ImageData
        cam
        err 
        ROIX %in pixels
        ROIY %in pixels
        numTrigs=0;
        memlist
    end
    
    properties (Access=private)
        state %is the camera running?
        scale=0.0235e-3; % m / pix
        ringBuffer; %for hardware triggering
        ID; %camera ID. check DCx camera manager. 
    end
    
    properties (Dependent)
        x %image plane coordinates x
        y %image plane coordinates y
    end
    
    methods
        function obj = Thorcam(ID,exposure)
            try
            [obj.cam, obj.ImageData, obj.err]=obj.initiate();
            catch err
                err
                error('Initiating thorcam failed. Is the Thorcam native software running?');
                
            end
            
            
            obj.ROIX = [600,850];
            obj.ROIY = [1,300];
            if nargin==0
                obj.ID=100;
                obj.setExposure(10000);

            elseif nargin==1
                obj.ID=ID;
                obj.setExposure(10000);
            else 
                obj.ID=ID;
                obj.setExposure(exposure);
            end
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
                [~,numOfCams]=uc480.Info.Camera.GetNumberOfDevices;
                if numOfCams~=1
                    warning('More than 1 thorcam connected to computer. make sure you know which one you are using!');
                end
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
%                 
%                 % Set up camera for copying image to Matlab memory for processing
                [err, ImageData.ID] = cam.Memory.Allocate(true);
                [err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch]= cam.Memory.Inquire(ImageData.ID);
                cam.DirectRenderer.SetStealFormat(uc480.Defines.ColorMode.SensorRaw8);
                
            end
            
            
        end
        function setExposure(obj,exposure)
        %exposure time in uS
        if exposure<100
            warning('minimum thorcam exposure: 100 muS. Setting min exposure time');
        end
        if exposure>66000
            warning('max thorcam exposure: 66 mS. Setting max exposure time');
        end
        obj.cam.Timing.Exposure.Set(exposure*1e-3);
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
        function im=getImageFromMemoryLocation(obj,loc)
            
%             [err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch] = cam.Memory.Inquire(obj.ImageData.ID);
            [~,loc]=obj.cam.Memory.Sequence.ToMemoryID(loc);
            [obj.err, im] = obj.cam.Memory.CopyToArray(loc);                        % Copy image from RAM to Matlab array
            if isempty(im)
                im = [];
                return
            end
            im = reshape(double(im), [obj.ImageData.Width, obj.ImageData.Height]).';
        end
        
        function setHWTrig(obj)
%             obj.cam.Exit;
%             obj.cam.Init; 
%             pause(2)
            fprintf('Thorcam: setting HW trigger\n');
%             obj.cam.Acquisition.Capture;
            obj.cam.Trigger.Set(uc480.Defines.TriggerMode.Lo_Hi);
            obj.cam.Trigger.Counter.Reset;
            [~,trig]=obj.cam.Trigger.Counter.Get;
            fprintf('trigged %d times\n',trig);
            obj.clearSeqMemory;
%             obj.ringBuffer=obj.cam.Memory.Sequence;
            obj.cam.Memory.Free(1:40);

%             obj.clearSeqMemory;
             
%              [~,allocated]=obj.cam.Memory.Allocate(false);
             [~,allocated]=obj.cam.Memory.Allocate(true);

            for int=1:39
                [~,allocated]=obj.cam.Memory.Allocate(false);
%                 fprintf('Thorcam: allocated memory pos %d\n',allocated)
            end
            [~,obj.memlist]=obj.cam.Memory.GetList();
            obj.cam.Memory.Sequence.Add(obj.memlist);
            obj.cam.Memory.Sequence.InitImageQueue;
            [~,seqID]=obj.cam.Memory.Sequence.GetActive;
            [~,activeMem]=obj.cam.Memory.Sequence.ToMemoryID(seqID);
            assert(activeMem==2,'active memory: %d',activeMem);
            obj.cam.Acquisition.Capture;
        end
        
        function clearSeqMemory(obj)
            obj.cam.Memory.Sequence.Clear();
        end
        function clearTriggerCount(obj)
            obj.cam.Trigger.Counter.Reset()
        end
        function count=getTriggerCounter(obj)
            [~,count]=obj.cam.Trigger.Counter.Get();            
            count=double(count);
        end
        function val=get.x(obj)
            w=double(obj.ImageData.Width); 
            
            
            val=linspace(-w/2,w/2,w).*obj.scale;
        end
        
        function val=get.y(obj)
            h=double(obj.ImageData.Height);
            val=linspace(-h/2,h/2,h)*obj.scale;
        end
        
        function delete(obj)
            obj.cam.Exit()
            disp('Thorcam closed');
        end
    end
end

