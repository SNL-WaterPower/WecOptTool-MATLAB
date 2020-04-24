function result = isParallel()
    % Determine if the current process is being run in parallel
    result = ~isempty(getCurrentTask());
end 
