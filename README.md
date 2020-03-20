# WecOptTool

The WEC Design Optimization Toolbox (WecOptTool) allows users to perform wave energy converter (WEC) device design optimization studies with constrained optimal control.

Dependency | Website | Required?
---------- | ------- | ---------
MATLAB Optimization Toolbox | https://www.mathworks.com/products/optimization.html | yes
Nemoh | https://github.com/LHEEA/Nemoh | yes
WAFO<sup>1</sup> | https://github.com/wafo-project/wafo | no
MATLAB Parallel Computing Toolbox | https://www.mathworks.com/products/parallel-computing.html | no

<sup>1</sup>_WecOptTool requires an input wave spectra which is formatted to match the output
of the WAFO toolbox. These spectra can also be produced 'by hand' and an example spectra is stored
in the `example_data` folder, to use if WAFO is not installed._

## Getting started

<!-- ## Installing WecOptTool and NEMOH -->

1. **Add WecOptTool to your MATLAB path**: After downloading the WecOptTool source code to a path of your choosing (`/path/to/WecOptTool`), add the WecOptTool toolbox to your MATLAB path using 
the MATLAB command prompt (alternatively the "Set Path" tool can be used to add the toolbox):

	```matlab
	>> addpath(genpath('/path/to/WecOptTool/toolbox'));
	```

2. **Set up Nemoh:**         

    a.  ***Windows:*** Executables are provided in the 'Release' directory of the NEMOH source code. These are installed into WecOptTool using the `installNemoh.m` MATLAB script, run from the WecOptTool root directory, as follows:

	```matlab
	>> cd /path/to/WecOptTool
	>> installNemoh('/path/to/NEMOH/Release');
	```

    b. ***Linux:*** To set up NEMOH for linux, first, compile the executables (you will need
gfortran or the intel fortran compiler):

	```
	$ cd /path/to/NEMOH
	$ make
	```

	Executables will be created a new directory called 'bin', which must then be installed into WecOptTool using the `installNemoh.m` MATLAB script, run from the WecOptTool root directory:

	```matlab
	>> cd /path/to/WecOptTool
	>> installNemoh('/path/to/NEMOH/bin');
	```


3. **Verify dependencies installation:** You can verify that the dependencies have been installed correctly by running the `dependencyCheck.m` script provided in the root directory of the WecOptTool source code. The script is called as follows:

	```
	>> cd /path/to/WecOptTool
	>> dependencyCheck
	```

	and successful output may look like this:

	```
	WecOptTool dependency checker
	-------------------------------

	Required
	--------
	Optimization Toolbox:       Found
	NEMOH:                      Found

	Optional
	--------
	Parallel Computing Toolbox: Not found
	WAFO:                       Found
	```


4. **Run functionality tests:** A test suite is available to verify that the code is operational. A script is provided in in the root directory of the WecOptTool source code and is run from the MATLAB command window, as follows:

	```matlab
	>> cd /path/to/WecOptTool
	>> runTests;
	```

5. **Begin use:** See the [`example.m`](https://github.com/ryancoe/WecOptTool/blob/master/example.m) file.


## NEMOH Files

A number of files are generated to handle inputs and outputs for the NEMOH
hydrodynamic solver. These files are stored within the users home directory. 
The exact path where the files are located can be found using the dataTool 
script, found in the root directory of the WecOptTool source code, from the 
MATLAB command window, as follows:

```matlab
>> cd /path/to/WecOptTool
>> dataTool path
```

For convenience, the script can also remove all files generated for NEMOH:

```matlab
>> cd /path/to/WecOptTool
>> dataTool clean
```

## RoadMap

### Introduction

This roadmap is for organising and prioritising the development and deployment
of this code and for improving the development team's working practices.

It is organised into 6 main sections, explained as follows:

1. Organisation <- relating to the development team
2. Features <- planning or code related to the business logic
3. Implementation <- planning or code not related to the business logic
4. Testing <- for both integration and unit tests
5. Documentation <- located within the repository or otherwise
6. Deployment <- considering the needs of users and developers

Within each section is a list of tasks. Each task should have the following
format:

#### Title

* Description:
    Just the right amount of detail in here
* Status: proposed, active, complete or wontfix
* Link: https://cat-bounce.com/
* Last updated: 1979-09-25

Contributions to the roadmap should be submitted via a pull request, with an
associated issue created in the issue tracker if the addition is complex or
controversial. 

### Organisation

#### Add a change log

* Description:
    All good code has a change log and developers who update it. See 
    https://keepachangelog.com/
* Status: proposed
* Link:
* Last updated: 2020-02-24

### Features

### Implementation

#### Updating code architecture

* Description:
    The source code was organised into packages and a user interface was added 
    as a top level package under the name WecOptTool. Implementation was moved 
    to a top level package called WecOptLib. It is likely that the contents 
    of these packages will evolve as the project reaches maturity.
* Status: active
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/5
* Last updated: 2020-03-11

#### Reducing external dependencies

* Description:
    The required dependencies has been reduced to NEMOH only. WAFO is now an
    optional, if highly useful, dependency.
* Status: complete
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/33
* Last updated: 2020-03-11

#### NEMOH files to User folder

* Description:
    NEHOH files are now placed into a user-centric folder
    (AppData\Roaming\WecOptTool on Windows and .wecopttool on linux). A tool
    named dataTool is available to recover the path to the NEMOH files or
    to delete all files generated bt NEMOH.
* Status: complete
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/5
* Last updated: 2020-03-11

#### Control parallel pool size

* Description:
    Currently the fmincon optimiser will use whatever resources are available
    on the host machine. This should be made configurable by the user so that
    they can control how much processing power is given to MATLAB.
* Status: proposed
* Link:
* Last updated: 2020-02-27

### Testing

#### Expand unit test coverage

* Description:
    A function to run all tests currently available has been added called 
    runTests.m. Tests are stored in the WecOptLib.tests package. Coverage of
    the unit tests should be measured and the aim should be to cover the
    entire source base.
* Status: active
* Link:
* Last updated: 2020-03-11

### Documentation

#### Create a single unified README

* Description:
    The repository now contains a single README that contains this RoadMap
    and is being updated alongside other changes in preparation for the 
    first public release of the code.
* Status: active
* Link:
* Last updated: 2020-03-11

#### Docs for MATLAB documentation system

* Description:
    Documentation can be prepared in such a way that it can be integrated into 
    the MATLAB documentation system. This process is explained in 
    https://uk.mathworks.com/help/matlab/matlab_prog/display-custom-documentation.html 
    and could be the primary documentation or used in conjunction with another 
    documentation system.
* Status: proposed
* Link:
* Last updated: 2020-02-25

### Deployment

#### Reducing the repository size

* Description: The original repository was reset to focus on hosting of the
    source code.
* Status: complete
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/43
* Last updated: 2020-03-11

#### Add installation / uninstallation scripts

* Description:
    It is convenient for the user to have installation and uninstallation 
    scripts, that can be run from MATLAB, that will copy and remove the toolbox 
    into their path automatically. It is also useful from the developers 
    perspective, as documentation can be injected into the MATLAB documentation 
    system and links can be added to GUI components (should they be added in 
    the future). 
* Status: proposed
* Link:
* Last updated: 2020-02-24
