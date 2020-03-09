# WecOptTool

This is a (currently) private repository for the WEC optimization toolbox 
project which is being modified for the release of the Reference Model 3 case
study example on 31 March 2020.

## Purpose

Describe the purpose here.

## Dependencies

The following MATLAB toolboxes must be installed and licensed:

  * Optimization Toolbox

The following MATLAB toolboxes can optionally be utilised:

  * Parallel Computing Toolbox

The following software dependencies must be added to your system path:

  * Nemoh: https://github.com/LHEEA/Nemoh

WecOptTool requires an input wave spectra which is formatted to match the output
of the WAFO toolbox:

  * Wafo: https://github.com/wafo-project/wafo

These spectra can also be produced 'by hand' and an example spectra is stored
in the `example_data` folder, to use if WAFO is not installed.

## Installing WecOptTool and NEMOH

To add WecOptTool to your startup.m file using the MATLAB command prompt:

```
>> addpath(genpath('/path/to/WecOptTool/toolbox'));
```

Alternatively the "Set Path" tool can be used to add the toolbox.

To set up NEMOH for linux, first compile the executables (you will need
gfortran or the intel fortran compiler):

```
$ cd /path/to/NEMOH
$ make
```

Executables will be created a new directory called 'bin', which must then be 
added to the system PATH using MATLAB:

```
>> path1 = getenv('PATH');
>> path1 = [path1 ':/path/to/NEMOH/bin'];
>> setenv('PATH', path1); 
>> !echo $PATH
```

For Windows, executables are already provided in the 'Release' directory of
the NEMOH source code. These are added to the system PATH using MATLAB as
follows:

```
>> path1 = getenv('PATH');
>> path1 = [path1 ';/path/to/NEMOH/Release'];
>> setenv('PATH', path1); 
>> !echo %PATH%
```

Note the use of a colon to separate directories in the linux path, while a
semicolon is used for the Windows path.

You can verify that the dependencies have been installed correctly by
running the dependencyCheck.m script provided in this repository. Successful
output may look like this:

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

## Using WecOptTool

See the example.m file.

## NEMOH Files

A number of files are generated to handle inputs and outputs for the NEMOH
hydrodynamic solver. These files are stored within the users home directory. 
The exact path where the files are located can be found using the dataTool 
script, from the MATLAB command window, as follows:

```
>>> dataTool path
```

For convenience, the script can also remove all files generated for NEMOH:

```
>>> dataTool clean
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

#### General refactor of source code

* Description:
    The source code is currently poorly organised. Generally, examples should 
    be split from source and embedded functions should be separated to allow 
    for unit testing and reuse. The directory structure should have 'src', 
    'examples', and 'vendor' directories once finished. 
* Status: proposed
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/37
* Last updated: 2020-02-24

#### Removing external dependencies

* Description:
    The code currently has 4 external dependencies, which should be packaged
    inside the repository as "vendor" code to lessen the burden on the user. 
    This should also remove risk of version conflicts occurring. 
* Status: proposed
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/38
* Last updated: 2020-02-27

#### Package based architecture

* Description:
    To allow configurable cases that can be built in scripts the toolbox should 
    adopt a package style architecture. Function are then accessed via 
    "package.function" syntax which provides a nice way of organising functions 
    by purpose. See 
    https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html 
    for more details. 
* Status: proposed
* Link:
* Last updated: 2020-02-27

#### NEMOH files to temporary folder

* Description:
    NEMOH files should not be stored within the source code, as it adds 
    unnecessary clutter. These files should be stored in a temporary folder
    instead. See: https://uk.mathworks.com/help/matlab/ref/tempdir.html
* Status: proposed
* Link:
* Last updated: 2020-02-27

#### Control Parallel Pool Size

* Description:
    Currently the fmincon optimiser will use whatever resources are available
    on the host machine. This should be made configurable by the user so that
    they can control how much processing power is given to MATLAB.
* Status: proposed
* Link:
* Last updated: 2020-02-27

### Testing

#### Add unit tests

* Description:
    A unit testing framework is a great way of verifying the logic within the 
    code and of aiding change management. MATLAB has an inbuilt unit testing
    framework that we should utilise. Building tests and refactoring code so
    it can be tested has a positive impact on the quality and accessibility
    of the code.
* Status: proposed
* Link:
* Last updated: 2020-02-24

### Documentation

#### Create a single unified README

* Description:
    There are READMEs in the subdirectories of the WEC tool, which should be
    either deleted or incorporated into the README in the root directory. If 
    the information is useful then it should be easily accessible, if it's 
    not then it should be deleted.
* Status: proposed
* Link:
* Last updated: 2020-02-24

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

* Description:
    The repository currently requires 900MB of storage, which makes cloning
    very slow. Most of this data are PDF documents found in the refs directory.
    The repository should be deleted and then recreated using only the source
    code, to remove these files and their history.
* Status: active
* Link: https://github.com/SNL-WaterPower/WecOptTool/issues/36
* Last updated: 2020-02-24

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
