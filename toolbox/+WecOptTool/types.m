function result = types(typeName, input)

    fullQName = "WecOptTool.types." + typeName;
    typeHandle = str2func(fullQName);
    
    for i = 1:length(input)
        result(i) = typeHandle(input(i));
    end

end
