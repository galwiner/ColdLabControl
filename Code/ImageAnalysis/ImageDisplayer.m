classdef ImageDisplayer
    %pretty show images
    
    properties
        images
        
    end
    
    properties (Access=private)
        N
    end
    
    
    methods
        function obj = ImageDisplayer(images)
            %show images nicely
            obj.images=images;
            obj.N=size(images,3);
        
            
        end
        
        function h=showImageGrid(obj,gridX,gridY)
            
            if nargin==1
                gridX=4;
                gridY=ceil(obj.N/gridX);
            end
            
            if gridX * gridY < obj.N
                error('not enough places in image grid')
            end
            
            h=figure;
                for ind=1:obj.N
                    subplot(gridX,gridY,ind);
                        imagesc(obj.images(:,:,ind));
                        title(num2str(ind))
                end
            end
            
        end
end

