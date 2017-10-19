classdef ImageFitter
    %class to take images objects and perform common operations on them
    
    properties
        images
        
    end
    
    properties (Access = private)
        sx
        sy
        x
        y
    end
    
    
    
    methods
        function obj = ImageFitter(images,x,y)
            %IMAGEFITTER supplies fitting tools for an
            %array of captured images. x,y are the image plane coordinates
            
            if nargin<1
                error('image array required')
            end
            
            obj.images=images;
            obj.sx=size(images,1);
            obj.sy=size(images,2);
            
            if nargin==1
                obj.x=1:obj.sx;
                obj.y=1:obj.sy;
            else
                obj.x=x;
                obj.y=y;
            end
            
        end
        
        function size=getImageSize(obj)
            %image size in pixels
            size=[obj.sx,obj.sy];
        end
        
        function [p,fit_img]=gaussianFits(obj,varargin)
            N=size(obj.images,3);
            
            fit_img=zeros(obj.sx,obj.sy,N);
            args=inputParser;
            addOptional(args,'dilute_for_fit',1,@isnumeric); %sets the default dilute val to 1
            isposvect=@(x) isnumeric(x)&&length(x)==2;
            addOptional(args,'cloud_center',[0,0],isposvect); %sets the default cloud center to [0,0]
            parse(args,varargin{:});
            dilute=args.Results.dilute_for_fit;
            
            for i=1:N
                try
                if ~isempty(find(strcmpi(args.UsingDefaults, 'cloud_center'),1)) 
                    disp(['fitting image '  num2str(i) ' of ' num2str(N)]);
                    [p(:,i),fit_img(:,:,i)]=fitImageGaussian2D(obj.x,obj.y,obj.images(:,:,i),floor(dilute));
                else
                    [p(:,i),fit_img(:,:,i)]=fitImageGaussian2D(obj.x,obj.y,obj.images(:,:,i),floor(dilute),args.Results.cloud_center);
                end
                catch MException
                    disp(['Fit error in image #' num2str(i)])
                end
            end
            
        end
        
        function [p,fit_img]=marginalFits(obj)
        %integrate each image in images across each axis and then fit a 1d
        %gaussian to each axis. returns 
            for i=1:length(obj.images)
                
            end
            
            
        end
        
                
    end
end

