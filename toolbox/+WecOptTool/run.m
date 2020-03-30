function run(study, optimOptions)
    
    disp("Running study...")
    disp("")

    %% Create the objective function
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    
    function pow = obj(x)
        warning('off', 'WaveSpectra:NoWeighting')
        pow = -1 * RM3Device.getPower(study.spectra,          ...
                                      study.controlType,      ...
                                      study.geomMode,         ...
                                      x,                      ...
                                      study.controlParams);
    end
    
    if strcmp(study.geomMode, 'existing')
        study.out.sol = study.geomX0;
        study.out.fval = obj(study.geomX0);
        return
    end
    
    %define these parameters as null to allow passing non-default options
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    
    %% Set the optimization options
    if nargin == 2
        options = optimOptions;
    else
        options = optimoptions('fmincon');
    end
    
    %% Call the optimization
    tic
    [sol,fval,exitflag,output] = fmincon(@obj,                  ...
                                         study.geomX0,          ...
                                         A,                     ...
                                         b,                     ...
                                         Aeq,                   ...
                                         beq,                   ...
                                         study.geomLowerBound,  ...
                                         study.geomUpperBound,  ...
                                         [],                    ...
                                         options);
    toc
    
    study.out = struct;
    study.out.sol = sol;
    study.out.fval = fval;
    study.out.exitflag = exitflag;
    study.out.output = output;
    
end
