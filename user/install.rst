************
Installation
************

Source Code
===========

The WecOptTool source code is downloaded from the `WecOptTool Github repository 
<https://github.com/SNL-WaterPower/WecOptTool>`_. Stable or development versions
are available.

Stable Version
--------------

The latest stable version of WecOptTool can be downloaded from the `Releases 
<https://github.com/SNL-WaterPower/WecOptTool/releases/>`_  section of the 
Github repository.

Development Version
-------------------

To get the latest development version of WecOptTool, clone or download directly 
from the WecOptTool Github repository using the '`Clone or download 
<https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository>`_'
button.

Note that, although the developers endeavour to ensure that the development
version is not broken, bugs or unexpected behaviour may occur, so please beware.

Dependencies
============

The following table displays the required and optional dependencies for
WecOptTool.

.. table::
    :widths: 40, 50, 10

    +----------------------+------------------------------------------------------------+-----------+
    | Dependency           | Website                                                    | Required? |
    +======================+============================================================+===========+
    | MATLAB Optimization  | https://www.mathworks.com/products/optimization.html       | yes       |
    | Toolbox              |                                                            |           |
    +----------------------+------------------------------------------------------------+-----------+
    | Nemoh                | https://github.com/LHEEA/Nemoh                             | yes       |
    +----------------------+------------------------------------------------------------+-----------+
    | WAFO [#f1]_          | https://github.com/wafo-project/wafo                       | no        |
    +----------------------+------------------------------------------------------------+-----------+
    | MATLAB Parallel      | https://www.mathworks.com/products/parallel-computing.html | no        |
    | Computing            |                                                            |           |
    | Toolbox [#f2]_       |                                                            |           |
    +----------------------+------------------------------------------------------------+-----------+

Setup
=====

1. **Add WecOptTool to your MATLAB path**: After downloading the
   WecOptTool source code to a path of your choosing
   (``/path/to/WecOptTool``), add the WecOptTool toolbox to your MATLAB
   path using the MATLAB command prompt (alternatively the “Set Path”
   tool can be used to add the toolbox):

   .. code:: matlab

      >> addpath(genpath('/path/to/WecOptTool/toolbox'));
      >> savepath;

2. **Prepare Nemoh:**

   a. **Windows:** Executables are provided in the ‘Release’ directory
      of the NEMOH source code. These are installed into WecOptTool
      using the ``installNemoh.m`` MATLAB script, run from the
      WecOptTool root directory, as follows:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/Release');

   b. **Linux:** To set up NEMOH for linux, first, compile the
      executables (you will need gfortran or the intel fortran
      compiler):

   ::

      $ cd /path/to/NEMOH
      $ make

   Executables will be created a new directory called ‘bin’, which must
   then be installed into WecOptTool using the ``installNemoh.m`` MATLAB
   script, run from the WecOptTool root directory:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/bin');

3. **Verify dependencies installation:** You can verify that the
   dependencies have been installed correctly by running the
   ``dependencyCheck.m`` script provided in the root directory of the
   WecOptTool source code. The script is called as follows:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> dependencyCheck

   and successful output may look like this:

   .. code::

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

4. **(optional) Run functionality tests:** A test suite is available to
   verify that the code is operational. A script is provided in the root 
   directory of the WecOptTool source code and is run from the MATLAB command 
   window, as follows:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> runTests;

.. rubric:: Footnotes

.. [#f1] WecOptTool requires an input wave spectra which is formatted to
         match the output of the WAFO toolbox. These spectra can also be 
         produced 'by hand' and an example spectra is stored in the 
         ``example_data`` folder, to use if WAFO is not installed.

.. [#f2] Optimizations can be conducted significantly more efficiently by
         utilising parallel computation.
