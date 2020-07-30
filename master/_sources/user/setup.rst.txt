*****
Setup
*****

Requirements
============

The following table displays the required and optional dependencies for
WecOptTool.

.. table::
    :widths: 35, 55, 10

    +----------------------+------------------------------------------------------------+-----------+
    | Dependency           | Website                                                    | Required? |
    +======================+============================================================+===========+
    | MATLAB               | https://www.mathworks.com/products/matlab.html             | yes\*     |
    +----------------------+------------------------------------------------------------+-----------+
    | MATLAB Optimization  | https://www.mathworks.com/products/optimization.html       | yes       |
    | Toolbox              |                                                            |           |
    +----------------------+------------------------------------------------------------+-----------+
    | NEMOH                | https://github.com/LHEEA/Nemoh                             | yes       |
    +----------------------+------------------------------------------------------------+-----------+
    | WAFO [#f1]_          | https://github.com/wafo-project/wafo                       | no        |
    +----------------------+------------------------------------------------------------+-----------+
    | MATLAB Parallel      | https://www.mathworks.com/products/parallel-computing.html | no        |
    | Computing            |                                                            |           |
    | Toolbox [#f2]_       |                                                            |           |
    +----------------------+------------------------------------------------------------+-----------+

\* The latest WecOptTool release, version 0.1.0, was tested on **MATLAB 2020a**, whilst the oldest compatible version known is **MATLAB 2018a**.
Please help the development team by reporting compatibility with other versions `HERE <https://github.com/SNL-WaterPower/WecOptTool/issues/91>`__.
The development version will support the latest available version of MATLAB, but no guarantees are given regarding legacy MATLAB support. 

.. _user-setup-download:

Download
========

.. raw:: html

   <details><summary><a>Get the stable version</a></summary></br>

The latest stable version of WecOptTool can be downloaded by clicking `HERE <https://github.com/SNL-WaterPower/WecOptTool/archive/v0.1.0.zip>`__.

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
   These are installed into WecOptTool using the ``installNemoh.m`` MATLAB script, run from the WecOptTool root directory, as follows:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/Release');

   .. raw:: html

       </details></br>

   .. raw:: html

       <details><summary><a>Linux</a></summary></br>

   To set up NEMOH for Linux, first, compile the executables (you will need gfortran or the Intel FORTRAN compiler):

   ::

      $ cd /path/to/NEMOH
      $ make

   Executables will be created a new directory called ‘bin’, which must then be installed into WecOptTool using the ``installNemoh.m`` MATLAB script, run from the WecOptTool root directory:

   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> installNemoh('/path/to/NEMOH/bin');

   .. raw:: html

       </details></br>

#. **Verify dependencies installation:** You can verify that the dependencies have been installed correctly by running the
   ``dependencyCheck.m`` script provided in the root directory of the WecOptTool source code.
   The script is called as follows:

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

#. **(optional) Run functionality tests:** A test suite is available to verify that the code is operational.
#. A script is provided in the root directory of the WecOptTool source code and is run from the MATLAB command window, as follows:
   
   .. code:: matlab

      >> cd /path/to/WecOptTool
      >> runTests;
   
   There should be no *Failed* or *Incomplete* tests at the end of the run.
   For example:
   
   .. code::
   
       Totals:
          27 Passed, 0 Failed, 0 Incomplete.
          209.4266 seconds testing time.

.. _user-setup-uninstall:

Uninstall
=========

Uninstall a previous version of WecOptTool using the MATLAB command prompt: 

   .. code:: matlab

    >> rmpath(genpath('/path/to/WecOptTool/toolbox'));

Alternatively the "Set Path" graphical tool can be used to remove the toolbox.

.. _README.md: https://github.com/SNL-WaterPower/WecOptTool/blob/master/README.md

.. rubric:: Footnotes

.. [#f1] WecOptTool requires an input wave spectra which is formatted to
         match the output of the WAFO toolbox. These spectra can also be 
         produced 'by hand' and an example spectra is stored in the 
         ``example_data`` folder, to use if WAFO is not installed.

.. [#f2] Optimizations can be conducted significantly more efficiently by
         utilizing parallel computation.

.. |br| raw:: html

   <br />