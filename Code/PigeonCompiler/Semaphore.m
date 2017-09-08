classdef Semaphore < handle
    properties(GetAccess=private)
        islocked=0;
        name='Semaphore';
    end
    
    methods(Access=private)
      % Guard the constructor against external invocation.  We only want
      % to allow a single instance of this class.
      function newObj = Semaphore
          islocked=0;
      end
    end
      
    methods(Static)
        function obj=me(iname)            
            persistent uniqueInstance
            if isempty(uniqueInstance)
               obj = Semaphore();
               uniqueInstance = obj;
            else
               obj = uniqueInstance;
            end
            if (nargin>0)
                obj.name=iname;
            end
        end
    end
    
    methods
        function l=locked(obj)
            l=obj.islocked;
        end
        function lock(obj)
            while (obj.islocked)
                disp([obj.name ' currently locked. Waiting for release...']);
                pause(10);
            end
            obj.islocked=1;
        end
        function release(obj)
            obj.islocked=0;
        end
    end
end