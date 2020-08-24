# WecOptTool

The WEC Design Optimization MATLAB Toolbox (WecOptTool) allows users to perform 
wave energy converter (WEC) device design optimization studies with constrained 
optimal control. 

## Dependencies

Dependency                          | Website                                                         | Usage<sup>1</sup>
----------------------------------- | --------------------------------------------------------------- | -----------------
MATLAB                              | https://www.mathworks.com/products/matlab.html                  | toolbox\*
MATLAB Optimization Toolbox         | https://www.mathworks.com/products/optimization.html            | toolbox
NEMOH                               | https://github.com/LHEEA/Nemoh                                  | toolbox
WAFO                                | https://github.com/wafo-project/wafo                            | examples
MATLAB Parallel Computing Toolbox   | https://www.mathworks.com/products/parallel-computing.html      | examples
MATLAB Global Optimization Toolbox  | https://www.mathworks.com/products/global-optimization.html     | examples

<sup>1</sup> The values in the _Usage_ column have the following meanings:
  * **toolbox** indicates dependencies that must be installed to use the
    toolbox
  * **examples** indicates dependencies that are used on a case by case basis, 
    in the examples

\* The latest WecOptTool release, version 0.1.0, was tested on **MATLAB 
2020a**, whilst the oldest compatible version known is **MATLAB 2018a**. Please 
help the development team by reporting compatibility with other versions 
[HERE]( https://github.com/SNL-WaterPower/WecOptTool/issues/91). The 
development version will support the latest available version of MATLAB, but no 
guarantees are given regarding legacy MATLAB support. 

## Download

### Stable Version

The latest stable version of WecOptTool can be downloaded from the [Releases](
https://github.com/SNL-WaterPower/WecOptTool/releases/) section of this 
repository.

### Development Version

For the latest development version of WecOptTool, clone or  download this 
repository, using the [Clone or download](
https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
button.

Note that, although the developers endeavour to ensure that the development
version is not broken, bugs or unexpected behaviour may occur, so please beware.

## Getting Started

> :warning: Unexpected behaviour may occur if multiple versions of the toolbox 
  are installed. Please following the [Uninstall](#uninstall) instructions to 
  uninstall any previous versions of WecOptTool first.

1. **Download the WecOptTool software**: See the [Download](#download)
   section. If required, unzip the archive to a path of your choosing (i.e. 
   `/path/to/WecOptTool`).

1. **Add WecOptTool to your MATLAB path**: Add the WecOptTool toolbox to your 
   MATLAB path using the MATLAB command prompt:

    ```matlab
    >> addpath(genpath('/path/to/WecOptTool/toolbox'));
    >> savepath;
   ```
   
   Alternatively the “Set Path” graphical tool can be used to add the toolbox.

1. **Set up Nemoh:**

    a. ***Windows:*** Executables are provided in the 'Release' directory of 
    the NEMOH source code. These are installed into WecOptTool using the 
    `installNemoh.m` MATLAB script, run from the WecOptTool root directory, 
    as follows: 
    
    ```matlab
    >> cd /path/to/WecOptTool
    >> installNemoh('/path/to/NEMOH/Release');
    ```
    
    b. ***Linux:*** To set up NEMOH for linux, first, compile the executables 
    (you will need gfortran or the intel fortran compiler):
    
    ```
    $ cd /path/to/NEMOH
    $ make
    ```
    
    Executables will be created a new directory called 'bin', which must 
    then be installed into WecOptTool using the `installNemoh.m` MATLAB 
    script, run from the WecOptTool root directory: 
    
    ```matlab
    >> cd /path/to/WecOptTool
    >> installNemoh('/path/to/NEMOH/bin');
    ```

1. **Verify dependencies installation:** You can verify that the dependencies 
have been installed correctly by running the `dependencyCheck.m` script 
provided in the root directory of the WecOptTool source code. The script is 
called as follows: 

    ```matlab
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

1. **(optional) Run functionality tests:** A test suite is available to verify 
that the code is operational. A script is provided in the root directory of the 
WecOptTool source code and is run from the MATLAB command window, as follows: 

    ```matlab
    >> cd /path/to/WecOptTool
    >> runTests;
    ```

   There should be no *Failed* or *Incomplete* tests at the end of the run.
   For example:
   
    ```
    Totals:
          80 Passed, 0 Failed, 0 Incomplete.
          125.1625 seconds testing time.
    ```

1. **Begin use:** See the 
[`basic`](https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/RM3/basic.m) 
or
[`optimization`](https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/RM3/optimization.m)
examples for the RM3 device.

## Uninstall

Uninstall a previous version of WecOptTool using the MATLAB command prompt: 

```matlab
>> rmpath(genpath('/path/to/WecOptTool/toolbox'));
```

Alternatively the "Set Path" graphical tool can be used to remove the toolbox.

## Code Architecture

The top level folders of the WecOptTool repository are used as follows:

* **docs** contains the web documentation source code
* **examples** contains subfolders with structured examples of co-optimisation 
  problems
* **tests** contains integration and unit tests
* **toolbox** contains the supporting MATLAB toolbox used by the examples

The toolbox uses [namespaces](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html)
to subdivide it's functionality, as follows:

1. **WecOptTool** provides the main support functions and classes such as:
    * **SeaState** for working with wave spectra and
    * **AutoFolder** for creating storage space for intermediate files
1. **WecOptTool.base** contains base classes used by other classes in the
   toolbox
1. **WecOptTool.geometry** provides functions for device geometry design
1. **WecOptTool.math** provides numerical helper functions
1. **WecOptTool.mesh** contains mesh generation classes
1. **WecOptTool.plot** provides plots
1. **WecOptTool.solver** contains classes for hydrodynamic solvers
1. **WecOptTool.system** provides functions for MATLAB specific tasks
1. **WecOptTool.validation** provides functions for argument validation 
1. **WecOptTool.vendor** contains code from external sources

The code architecture for both the WecOptTool is subject to change as the code 
approaches maturity.

## Documentation

The documentation is published at [snl-waterpower.github.io/WecOptTool](
https://snl-waterpower.github.io/WecOptTool/). The documentation source code 
is found in the `docs` folder and HTML is compiled using the [Sphinx](
https://www.sphinx-doc.org/en/master/) documentation generator.

### Compile Instructions

These instructions work for both Linux and Windows. For Windows, remember to
replace slashes (`/`) in paths with backslashes (`\ `).

#### Setup Sphinx (One Time Only)

1. Install [Anaconda Python](https://www.anaconda.com/distribution/).

2. Create the Sphinx environment:
   
   ```
   > conda create -c conda-forge -n _sphinx click colorama colorclass future pip "sphinx=1.8.5" sphinx_rtd_theme 
   > activate _sphinx
   (_sphinx) > pip install https://github.com/H0R5E/sphinxcontrib-versioning/archive/v1.8.5_support.zip
   (_sphinx) > pip install git+https://github.com/H0R5E/matlabdomain.git/@function_arguments#egg=matlabdomain
   (_sphinx) > conda deactivate
   >
   ```

#### Testing the Current Branch

The documentation for the current branch can be built locally for inspection 
prior to publishing. They are built in the `docs/_build` directory. Note, 
unlike the final documentation, version tags and other branches will not be 
available. 

To test the current branch, use the following:

```
> activate _sphinx
(_sphinx) > cd path/to/WecOptTool
(_sphinx) > sphinx-build -b html docs docs/_build/html
(_sphinx) > conda deactivate
>
```

#### Building Final Version Locally

The final documentation can be built locally for inspection prior to 
publishing. They are built in the `docs/_build` directory. Note, docs are built 
from the remote, so only pushed changes will be shown. 

To build the docs as they would be published, use the following:

```
> activate _sphinx
(_sphinx) > cd path/to/WecOptTool 
(_sphinx) > sphinx-versioning build -abt docs docs/_build/html
(_sphinx) > conda deactivate
>
```

To build the docs with a current feature branch as the default docs use:

```
> activate _sphinx
(_sphinx) > cd path/to/WecOptTool 
(_sphinx) > sphinx-versioning build -ab r <feature-branch> docs docs/_build/html
(_sphinx) > conda deactivate
>
```

The front page of the docs can be accessed at 
`WecOptTool/docs/_build/html/index.html`. 

#### Publishing Final Version Remotely

The WecOptTool docs are rebuilt automatically following every merge commit made 
to the master branch of the [SNL-WaterPower/WecOptTool](
https://github.com/SNL-WaterPower/WecOptTool) repository. They can also be 
published manually, as follows:

```
> activate _sphinx
(_sphinx) > cd path/to/WecOptTool 
(_sphinx) > sphinx-versioning push -abt -e .nojekyll -e README.md -P <REMOTE> docs <BRANCH> .
(_sphinx) > conda deactivate
>
```

\<REMOTE\> refers to the git remote which will be pushed to and \<BRANCH\> 
refers to the target branch on the remote. Note, this command will add a new 
commit to the remote, so use with care.

### Docstring Formatting

Docstring formatting should be [Google style] for auto documentation with 
[sphinx.ext.napoleon]. See the docstrings in the WecOptTool package for 
examples.

[Google style]: https://www.sphinx-doc.org/en/master/usage/extensions/example_google.html#example-google)
[sphinx.ext.napoleon]: https://www.sphinx-doc.org/en/master/usage/extensions/napoleon.html

## Contributing

Please see the [Public Road Map](
https://github.com/SNL-WaterPower/WecOptTool/projects/2) to see the current
development priorities.

Contributions to the toolbox are welcome. The project follows a [trunk based 
development](https://trunkbaseddevelopment.com/) paradigm and updates to the 
code should be made through [pull requests](
https://help.github.com/en/github/collaborating-with-issues-and-pull-requests).
Contributions should be submitted against the `master` branch.

When submitting to the MATLAB source code please run the test suite first:

```matlab
>> cd /path/to/WecOptTool
>> runTests;
```

When the test suite has finished please add the generated `test_results.pdf` 
file, showing that all tests have passed, to the pull request description.

For contributions to the documentation, please please run a spell-check prior 
to submitting a pull request.

A code maintainer will review your pull request at the earliest possible
opportunity. For large pull requests, it would be advisable to open a related 
issue to discuss the purpose of your updates. The developers also would be 
grateful if *"Allow edits from maintainers"* is checked when making a pull 
request, as this will allow us to finalise your contributions more rapidly.

## Software License

Copyright 2020 National Technology & Engineering Solutions of Sandia, 
LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the U.S. 
Government retains certain rights in this software.
 
WecOptTool is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 3 of the License, or (at your option) any later 
version.

WecOptTool is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
WecOptTool.  If not, see <https://www.gnu.org/licenses/>.
