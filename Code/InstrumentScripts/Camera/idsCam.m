classdef idsCam<handle
    %IDSCAM : represents an ids uEYE camera
    
    properties
         cam 
         ImageData
         err
         imSizeX
         imSizeY
         sensorInfo
         bufferSize
         pixelSize=4.8;%um
    end
    
    methods
        function obj = idsCam(varargin)
            
            if nargin==0
                camName='';
            else 
                camName=varargin{1};
            end
            
            [obj.cam, obj.ImageData, obj.err]=obj.initiate(camName);
            [~,obj.sensorInfo]=obj.cam.Information.GetSensorInfo;
            obj.imSizeX=obj.sensorInfo.MaxSize.Width;
            obj.imSizeY=obj.sensorInfo.MaxSize.Height;
            
        end
        function [cam, ImageData, err]=initiate(obj,camName)
            p=mfilename('fullpath');
            currfolder=fileparts(p);
            asmfile=fullfile(currfolder,'uEyeDotNet.dll');
            NET.addAssembly(asmfile);
%             NET.addAssembly('D:\Box Sync\Lab\ExpCold\ControlSystem\Code\InstrumentScripts\Camera\uEyeDotNet.dll');
            cam=uEye.Camera();
            if strcmpi(camName,'plane')
                SN=4103034985;
            elseif strcmpi(camName,'monitor')
                SN=4103034991;
            else
                SN=0;
            end
            [~,cList]=uEye.Info.Camera.GetCameraList();
            if cList.Length~=0 && SN==0
                error('more than one IDS cam connected. you must enter a name. plane or monitor')
            end
            if cList.Length==0
                error('no IDScam connected');
            else
                
                for ind=1:cList.Length
                    if str2num(char(cList(ind).SerialNumber))==SN
                        ID=cList(ind).CameraID;
                    end
                end
            end
            
            if exist('ID')
                cam.Init(ID);
            else
                cam.Init(0);
            end
        
            
            
            
            % Ensure Direct3D mode is set
%             cam.Display.Mode.Set(uEye.Defines.DisplayMode.Direct3D);
            cam.Display.Mode.Set(uEye.Defines.DisplayMode.DiB);
            % Set camera gain
            cam.Gain.Hardware.Boost.SetEnable(false);
            cam.Gain.Hardware.ConvertScaledToFactor.Blue(0);
            cam.Gain.Hardware.ConvertScaledToFactor.Green(0);
            cam.Gain.Hardware.ConvertScaledToFactor.Master(0);
            cam.Gain.Hardware.ConvertScaledToFactor.Red(0);
            err = cam.PixelFormat.Set(uEye.Defines.ColorMode.SensorRaw8);
            
            err = cam.PixelFormat.Set(uEye.Defines.ColorMode.SensorRaw8);
            ImageData=[];
            %
            %                 % Set up camera for copying image to Matlab memory for processing
%             [err, ImageData.ID] = cam.Memory.Allocate(true);
%             [err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch]= cam.Memory.Inquire(ImageData.ID);
%             cam.DirectRenderer.SetStealFormat(uEye.Defines.ColorMode.SensorRaw8);
        end
        function setExposure(obj,exposure)
            obj.cam.Timing.Exposure.Set(exposure*1e-3);
        end
        function exp=getExposure(obj)
            %in microseconds
            [~,exp]=obj.cam.Timing.Exposure.Get;
            exp=exp*1e3;
        end
        
        function im=getImage(obj)
            obj.cam.Memory.Free(1);
            obj.cam.Memory.Allocate;
            [~,id]=obj.cam.Memory.GetActive;
            obj.cam.Trigger.Set(uEye.Defines.TriggerMode.Software);
%             obj.cam.Acquisition.Capture();
            obj.cam.Acquisition.Freeze(true);
            
%             obj.cam.DirectRenderer.StealNextFrame(uEye.Defines.DeviceParameter.Wait);  % Copy image from graphics card to RAM (wait for completion)
            %[err, ImageData.Width, ImageData.Height, ImageData.Bits, ImageData.Pitch] = cam.Memory.Inquire(ImageData.ID);
%             [obj.err, im] = obj.cam.Memory.CopyToArray(obj.ImageData.ID);                        % Copy image from RAM to Matlab array
            [obj.err, im] = obj.cam.Memory.CopyToArray(id);                        % Copy image from RAM to Matlab array
            if isempty(im)
                im = [];
                return
            end
            im = reshape(double(im), [obj.imSizeX,obj.imSizeY]).';
            obj.cam.Acquisition.Stop();
        end
        function ret=startRingBufferMode(obj,num)
            obj.bufferSize=num;
            %allocates memory and starts run
            obj.cam.Memory.Free(1:num); %free memory
            ids=zeros(1,num);
            for ind=1:num
                
                [err,ids(ind)]=obj.cam.Memory.Allocate(obj.imSizeX,obj.imSizeY, 8); %allocate an image
                if ~strcmpi(err,'success')
                    break;
                end
                err=obj.cam.Memory.Sequence.Add(int32(ids(ind))); %add image to ring buffer
                if ~strcmpi(err,'success')
                    break;
                end
            end

            fprintf('idscam: successful allocation of %d images to ring buffer\n',num);
            
            [~,seqID]=obj.cam.Memory.Sequence.GetActive;
            [~,activeMem]=obj.cam.Memory.Sequence.ToMemoryID(seqID);
            
            obj.cam.Acquisition.Capture();
            fprintf('idscam: capture into buffer running');
            ret=1;
        end
        
        function im=getImageFromMemoryLocation(obj,loc)
            [~,loc]=obj.cam.Memory.Sequence.ToMemoryID(loc);
            [obj.err, im] = obj.cam.Memory.CopyToArray(loc);                        % Copy image from RAM to Matlab array
            if isempty(im)
                im = [];
                return
            end
            im = reshape(double(im), [obj.imSizeX, obj.imSizeY]).';
        end
        function images=getBufferImages(obj)
            images=zeros(obj.imSizeY,obj.imSizeX,obj.bufferSize);
            for ind=1:obj.bufferSize
                images(:,:,ind)=getImageFromMemoryLocation(obj,ind);
            end
        end
            
%         function getImagesFromBuffer(obj,imNum)
%             obj.cam.
%         end
        
        function setHWTrig(obj)
                ret=obj.cam.Trigger.Set(uEye.Defines.TriggerMode.Lo_Hi);
                disp(ret);
        end
        function [width,hight] = getImSize(obj)
            width = obj.imSizeX;
            hight = obj.imSizeY;
        end
        function delete(obj)
            obj.cam.Exit();
            disp('ids closed');
        end
        
%         function im = sanpshot(obj)
%             %immediately trigger and return current image 
%             
%         end
    end
end

