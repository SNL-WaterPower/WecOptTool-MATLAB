function mesh = mesh(meshName, folder, varargin)

    fullQName = "WecOptLib.experimental.mesh." + meshName;
    meshHandle = str2func(fullQName);
    mesher = meshHandle(folder);
    mesh = mesher.makeMesh(varargin{:});

end
