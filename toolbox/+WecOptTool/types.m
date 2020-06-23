function result = types(typeName, input)
    % Create an array of a given type using shortcuts to defined Data 
    % concrete classes in the :mat:mod:`+WecOptTool.+types` package.
    %
    % Arguments:
    %     typeName (string):
    %         Data type to create. Current options are:
    %              
    %              * Hydro (:mat:class:`+WecOptTool.+types.Hydro`)
    %              * Mesh (:mat:class:`+WecOptTool.+types.Mesh`)
    %              * Motion (:mat:class:`+WecOptTool.+types.Motion`)
    %              * Peformance (:mat:class:`+WecOptTool.+types.Peformance`)
    %              * SeaState (:mat:class:`+WecOptTool.+types.SeaState`)
    %
    %     input (struct array):
    %         Struct array containing the required fields for the desired 
    %         data type
    %       
    %
    % Returns:
    %    array of :mat:class:`+WecOptTool.+base.Data`:
    %        An array of populated concrete Data subclass objects.
    %
    % Note:
    %     This routine always calls the ``validateArray`` method of the 
    %     data type.
    %
    % --
    %
    % See also WecOptTool.types.Hydro, WecOptTool.types.Mesh,
    %     WecOptTool.types.Motion, WecOptTool.types.Peformance,
    %     WecOptTool.types.SeaState
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
    
    fullQName = "WecOptTool.types." + typeName;
    typeHandle = str2func(fullQName);
    
    for i = 1:length(input)
        result(i) = typeHandle(input(i));
    end
    
    result.validateArray()

end
