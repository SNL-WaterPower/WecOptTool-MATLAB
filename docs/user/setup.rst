*****
Setup
*****

Dependencies
============

The following table displays the required and optional dependencies for
WecOptTool.

.. table::
    :widths: 35, 55, 10

    +----------------------+-------------------------------------------------------------+--------------+
    | Dependency           | Website                                                     | Required?\*  |
    +======================+=============================================================+==============+
    | MATLAB               | https://www.mathworks.com/products/matlab.html              | yes [#f1]_   |
    +----------------------+-------------------------------------------------------------+--------------+
    | MATLAB Optimization  | https://www.mathworks.com/products/optimization.html        | yes          |
    | Toolbox              |                                                             |              |
    +----------------------+-------------------------------------------------------------+--------------+
    | NEMOH                | https://github.com/LHEEA/Nemoh                              | yes          |
    +----------------------+-------------------------------------------------------------+--------------+
    | WAFO                 | https://github.com/wafo-project/wafo                        | optional     |
    +----------------------+-------------------------------------------------------------+--------------+
    | MATLAB Parallel      | https://www.mathworks.com/products/parallel-computing.html  | optional     |
    | Computing Toolbox    |                                                             |              |
    +----------------------+-------------------------------------------------------------+--------------+
    | MATLAB Global        | https://www.mathworks.com/products/global-optimization.html | optional     |
    | Optimization Toolbox |                                                             |              |
    +----------------------+-------------------------------------------------------------+--------------+

\* The values in the Required column have the following meanings:
    * **yes** indicates dependencies that must be installed to use the
      WecOptTool toolbox
    * **optional** indicates dependencies that are used on a case by case basis, 
      in the examples

.. _user-setup-download:

Download
========

.. raw:: html

   <details><summary><a>Get the stable version</a></summary></br>

The latest stable version of WecOptTool can be downloaded by clicking `HERE <https://github.com/SNL-WaterPower/WecOptTool/archive/v1.0.0.zip>`__.

Details of this and previous stable releases can be found in the `Releases <https://github.com/SNL-WaterPower/WecOptTool/releases/>`__  section of the GitHub repository.

.. raw:: html

   </details></br>

.. raw:: html

   <details><summary><a>Get the development version</a></summary></br>

To get the latest development version of WecOptTool, clone or download the WecOptTool GitHub repository using the '`Clone or download <https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository>`__' button.

Note that, although the developers endeavor to ensure that the development version is not broken, bugs or unexpected behavior may occur, so please beware.

Please see the "Contributing" section of the source code's `README.md`_ file for details on how to contribute to the code development.

.. raw:: html

   </details></br>

Install
=======

.. note::
    Unexpected behavior may occur if multiple versions of the toolbox are installed. Please following the :ref:`user-setup-uninstall` instructions to uninstall any previous versions of WecOptTool first.

#. **Download the WecOptTool software**: See the :ref:`user-setup-download` section. If required, unzip the archive to a path of your choosing (i.e. ``/path/to/WecOptTool``). |br| |br|

#. **Add WecOptTool to your MATLAB path**: Add the WecOptTool toolbox to your MATLAB path using the MATLAB command prompt:

   .. code:: matlab

      >> addpath(genpath('/path/to/WecOptTool/toolbox'));
      >> savepath;
   
   Alternatively the "Set Path" graphical tool can be used to add the toolbox.
   |br| |br|

#. **Prepare Nemoh**: Follow the OS dependent instructions for setting up
   NEMOH:

   .. raw:: html

       <details><summary><a>Windows</a></summary></br>

   Executables are provided in the ‘Release’ directory of the NEMOH source code.
   These are installed into WecOptTool using the ``installNemoh.m`` MATLAB script, run from the WecOptTool root directory, using the MATLAB command prompt as follows:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/Release');

   .. raw:: html

       </details></br>

   .. raw:: html

       <details><summary><a>Linux</a></summary></br>

   To set up NEMOH for Linux, first, use a command window to compile the executables (you will need gfortran or the Intel FORTRAN compiler):

   ::

      $ cd /path/to/NEMOH
      $ make

   Executables will be created a new directory called ‘bin’, which must then be installed into WecOptTool using the ``installNemoh.m`` MATLAB script, run from the WecOptTool root directory using the MATLAB command prompt:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/bin');

   .. raw:: html

       </details></br>

#. **Verify dependencies installation:** You can verify that the dependencies have been installed correctly by running the
   ``dependencyCheck.m`` script provided in the root directory of the WecOptTool source code.
   The script is called as follows using the MATLAB command prompt:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> dependencyCheck

   and successful output may look like this:

   .. code::

      WecOptTool Dependency Checker
      -------------------------------
      
      Required
      --------
      Optimization Toolbox:                   Found
      NEMOH:                                  Found
      
      Optional
      --------
      Parallel Toolbox:                       Found
      Global Optimization Toolbox:    Not Installed
      WAFO:                                   Found


#. **(optional) Run functionality tests:** A test suite is available to verify that the code is operational.
    A script is provided in the root directory of the WecOptTool source code and is run from the MATLAB command window, as follows:
   
   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> runTests;
   
   There should be no *Failed* or *Incomplete* tests at the end of the run.
   For example:
   
   .. code::
   
       Totals:
          91 Passed, 0 Failed, 0 Incomplete.
          195.0643 seconds testing time.

.. _user-setup-uninstall:

Uninstall
=========

Uninstall a previous version of WecOptTool using the MATLAB command prompt: 

   .. code:: matlab

    >> rmpath(genpath('/path/to/WecOptTool/toolbox'));

Alternatively the "Set Path" graphical tool can be used to remove the toolbox.

.. _README.md: https://github.com/SNL-WaterPower/WecOptTool/blob/master/README.md

.. rubric:: Footnotes

.. [#f1] The WecOptTool developers are endeavoring to ensure that this 
         software is compatible with the latest version of MATLAB (and the 
         toolbox dependencies). Unfortunately, this may mean that backwards 
         compatibility with older versions of MATLAB is not possible. See the 
         `MATLAB Version Support Policy 
         <https://github.com/SNL-WaterPower/WecOptTool/wiki/MATLAB-Version-Support-Policy>`__ 
         page for further details. 

.. |br| raw:: html

   <br />
