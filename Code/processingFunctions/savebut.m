function savebut(varargin)
%SAVEBUT FILE.MAT VAR saves in FILE.MAT file all the workspace's variables
%except for those undesired.
%The jolly character (*) is available.
%
%Ex: savebut file.mat Y X* save in file.mat all the workspace's variable
%except Y and those starting with "X" (X1,X2,XX,Xn...)

SAVE_str = ['save ' varargin{1}];

%Read the workspce's variables
WSv = evalin('base','whos;');

Save_WSv(1:length(WSv)) = 0;

for y = 1:length(WSv)
    %y-th wrkspace variable
    VAR_w = WSv(y).name;

    for x = 2:nargin
        %x-th string
        VAR_s = varargin{x};

        %Compare the y-th variable and the x-th string
        WSvx = evalin('base',['whos(''' VAR_s ''');']);
        for z = 1:length(WSvx)
            if strcmp(VAR_w,WSvx(z).name)
                Save_WSv(y) = 1;
            end
        end
    end

    %Build the command for saving the desired variables
    if Save_WSv(y) == 0
        SAVE_str = [SAVE_str ' ' VAR_w];
    end

end

evalin('base',SAVE_str)