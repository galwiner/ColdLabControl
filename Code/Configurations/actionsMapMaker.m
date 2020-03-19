%note: each action field must also have a type 'char' or 'numeric' or
%'logical'
actionsMap=containers.Map;

actionsMap('Load MOT')={};
actionsMap('Release MOT')={};
actionsMap('pause')={'duration','numeric'};
actionsMap('setDigitalChannel')={'channel','char','duration','numeric','value','char'};
actionsMap('setAnalogChannel')={'channel','char','duration','numeric','value','numeric'};


save('actionsMap.mat','actionsMap');
