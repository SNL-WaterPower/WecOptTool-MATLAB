classdef (Abstract) Data < dynamicprops
    % Abstract class for creating new types.
    %
    % WecOptLib types act like structs with added required fields and
    % validation of those fields (in the input stuct). The abstract 
    % struct property ``meta`` must be implemented in concrete classes,
    % with fields "name" and "validation", for example::
    %
    %    meta = struct("name", {"Var1",    ...
    %                           "Var2"},   ...
    %                  "validation", {@isnumeric,    ...
    %                                 @isstring});
    %
    % The method validateArray can also be overloaded to provide additional
    % steps needed when creating arrays of Data subclass objects.
    %
    % --
    %
    % See also WecOptTool.types
    %
    % --
    
    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>.
    
    properties (Abstract, GetAccess=protected)
        meta
    end
    
    methods
        
        function obj = Data(input)
            
            if nargin < 1
                return
            end
            
            if length(input) > 1
                error("Only length 1 structs may be passed as input")
            end
            
            p = obj.parseParams(input);
            props = obj.buildProperties(p);
            
            % Add values to properties
            fn = fieldnames(p.Results);

            for j = 1:numel(fn)
                obj.(fn{j}) = p.Results.(fn{j});
            end

            fn = fieldnames(p.Unmatched);

            for j = 1:numel(fn)
                obj.(fn{j}) = p.Unmatched.(fn{j});
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
        
        function validateArray(obj)
            % A function to be used for tasks required following 
            % instatiation of an array
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
            
            % Validate any parameters defined in meta
            p = inputParser;
            p.KeepUnmatched = true;
            
            for mymeta = obj.meta
                addRequired(p, mymeta.name, mymeta.validation);
            end
            
            parse(p, argList{:});
            
        end
        
        function props = buildProperties(obj, p)
                            
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

