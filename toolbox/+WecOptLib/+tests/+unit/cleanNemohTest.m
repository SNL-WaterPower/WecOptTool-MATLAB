% Setting up test function for cleanNemoh.
% -Zachary Morrell 5/22/2019
 
function tests = cleanNemohTest()
   tests = functiontests(localfunctions);
end

function testRemovesDir(testCase)
    
    % calling getNemoh to generate files
    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir,'WecOptTool_cleanNemohTest');
    WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    % running cleanNemoh to immediately remove created files
    WecOptLib.nemoh.cleanNemoh(rundir)
    
    % checking that all created files and directories are gone
    actVal = ~exist(rundir, 'dir');
    
    % evaluating testCase 
    verifyTrue(testCase, actVal);
    
end
