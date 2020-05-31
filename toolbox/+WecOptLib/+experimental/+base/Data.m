classdef (Abstract) Data < dynamicprops
    
    properties (Abstract, GetAccess=protected)
        meta
    end
    
    methods
        
        function obj = Data(input)
            
            if nargin < 1
                return
            end
            
            p = obj.parseParams(input(1));
            props = obj.buildProperties(p);
            
            % Add values to properties
            n = length(input);
            obj = repelem(obj,1,n);

            for i = 1:n
                
                fn = fieldnames(p.Results);

                for j = 1:numel(fn)
                    obj(i).(fn{j}) = p.Results.(fn{j});
                end

                fn = fieldnames(p.Unmatched);

                for j = 1:numel(fn)
                    obj(i).(fn{j}) = p.Unmatched.(fn{j});
                end
                
            end
            
            % Disallow setting access
            for Prop = props
                Prop{1}.SetAccess = "private";
            end
            
        end
        
        function out = struct(obj)
            % Return the object data as a struct
            
            props = properties(obj(1));
            argcell = {};
            
            for i = 1:length(props)
                data = {};
                for j = 1:length(obj)
                    data{end+1} = obj(j).(props{i});
                end
                argcell{end+1} = props{i};
                argcell{end+1} = data;
            end
            
            out = struct(argcell{:});
            
        end
            
    end

    methods (Access=private)
        
        function p = parseParams(obj, input)
    
            % Convert input struct to argument list
            argList = {};
            remove_vars = {};
            
            fields = fieldnames(input);
            values = struct2cell(input);
            
            for name = [obj.meta.name]
                i = obj.getRequiredIndex(name, fields);
                argList{end+1} = values{i};
                remove_vars{end+1} = fields{i};
            end
            
            for var = remove_vars
                i = find(strcmp(fields, var));
                fields(i) = [];
                values(i) = [];
            end
            
            argList = [argList reshape([fields.';values.'], 1, [])];
            
            % Check for and validate any parameters defined in meta
            p = inputParser;
            p.KeepUnmatched = true;
            
            for mymeta = obj.meta
                addRequired(p, mymeta.name, mymeta.validation);
            end
            
            parse(p, argList{:});
            
        end
        
        function props = buildProperties(obj, p)
                            
            % Build properties
            fn = fieldnames(p.Results);
            props = {};

            for i = 1:numel(fn)
                Prop = obj.addprop(fn{i});
                props{end+1} = Prop;
            end

            fn = fieldnames(p.Unmatched);

            for i = 1:numel(fn)
                Prop = obj.addprop(fn{i});
                props{end+1} = Prop;
            end
                
        end
        
        function i = getRequiredIndex(obj, name, fields)
            
            for i = 1:numel(fields)
                if strcmp(fields{i}, name)
                    return 
                end
            end
            
            errStr = "Required property '" + name + "' was not " + ...
                     "found in the input struct";
            error("WecOptTool:Data:MissingParameter", errStr)
            
        end    
            
    end
    
end

