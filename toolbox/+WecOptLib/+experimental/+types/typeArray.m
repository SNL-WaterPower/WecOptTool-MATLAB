function result = typeArray(typeName, input)

    fullQName = "WecOptLib.experimental.types." + typeName;
    typeHandle = str2func(fullQName);
    
    for i = 1:length(input)
        result(i) = typeHandle(input(i));
    end

end
