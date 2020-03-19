function functionHandle = makeListenerHandle(handleStructure)
    functionHandle = @LocalFunction;
    function LocalFunction(dataprocessed)
      handleStructure.dataprocessed = dataprocessed;
    end
end