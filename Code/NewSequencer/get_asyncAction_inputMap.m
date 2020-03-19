function inputList = get_asyncAction_inputMap(actionName)
b = Block;
actionMap = b.asyncActionInputMap;
for ii = 1:length(actionMap)
   if  strcmp(actionMap{ii}{1},actionName)
       for jj = 2:length(actionMap{ii})
       inputList(jj-1) = string(actionMap{ii}{jj});
       end
       if ~exist('inputList','var')
           warning('no input listed in %s',actionName)
       end
       return
   end
end
error('%s not found in asyncActionInputMap!',actionName);
end