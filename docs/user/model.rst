.. _model:

**********************
WEC Model Architecture
**********************

This section provides an overview of how a typical WecOptTool model is programmed.
WecOptTool is currently structured as a set of examples, all of which follow a similar format and can thus rely on common utilities.
It is envisioned that the structure of WecOptTool may some day be consolidated based on experience in developing these examples.

Introduction
============

The WaveBot example :cite:`Coe2020` will be used to illustrate these concepts in more detail.
The process for performing a study in WecOptTool can be broken into three distinct steps, which correlate to three files in the WaveBot example:

	* **Designing the device** - |designDevice.m|_ creates the device based on a set of design variables
	* **Simulating device response** - |simulateDevice.m|_ simulates device performance
	* **Reporting results** - |Performance.m|_ a class for storing and plotting performance data

The diagram below shows the responsibilities that each of these steps take within the context of the overall work-flow.
The **Designing the device** step takes user inputs regarding the configuration of the device and calculates the hydrodynamic parameters of that design.
In the diagram below, the processes bounded by **rectangle 1** are encapsulated by this step. 
**Simulating device response** takes information about the sea state and controller type, and finds the optimal power output for the given hydrodynamic parameters, encapsulating the processes in **rectangle 2**.
Finally, the processes in **rectangle 3** will use metrics that are calculated in the **Reporting results** step, e.g., to find the average power.

.. image:: /_static/WecOptToolFlowChartCode.svg
   :alt: Steps for implementing the WecOptTool functionality

Designing the device
====================

.. raw:: html

   <details><summary><a>See the entire file</a></summary></br>

.. literalinclude:: /../examples/WaveBot/designDevice.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

The **Designing the device** step codifies the user inputs for the **Geometry**, **Power take off**, and **Kinematics** of the WEC.
With some important caveats, this step can be seen as analogous to building the physical device.
This step can include [#f1]_ generating a panelized representation of the WEC's hull and calling a BEM code (e.g., NEMOH) to estimate the hydrodynamic coefficients.
We can see from the signature of |designDevice.m|_ that it will return a :mat:class:`~+WecOptTool.Hydrodynamics` object.

.. code:: matlab

		hydro = designDevice(type, varargin)

Simulating device response
==========================

.. raw:: html

   <details><summary><a>See the entire file</a></summary></br>

.. literalinclude:: /../examples/WaveBot/simulateDevice.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

To find the performance of a device, a separate step (**Simulating device response**) is used.
For WaveBot, this is codified in the |simulateDevice.m|_, function, which has the following signature:

.. code:: matlab

		performance = simulateDevice(hydro, seastate, controlType, options)

The arguments for |simulateDevice.m|_ are:

* ``hydro`` - a :mat:class:`~+WecOptTool.Hydrodynamics` object containing hydrodynamic coefficients produced by |designDevice.m|_
* ``seastate`` - a :mat:class:`~+WecOptTool.SeaState` object (see :ref:`seastate`)
* ``controlType`` - string specifying the control type (see :ref:`controlledPerformance`)
* ``options`` - name-value pair arguments for additional settings

The ``options`` argument can be used to define device properties that are not directly related to the hydrodynamics.
For example, in the WaveBot example the user can set the maximum displacement (``Zmax``) and maximum PTO force (``Fmax``) at this point.
Additionally, solver settings such as the linear interpolation method (``interMethod``) can be defined.

Reporting results
=================

.. raw:: html

   <details><summary><a>See the entire file</a></summary></br>

.. literalinclude:: /../examples/WaveBot/Performance.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

The WaveBot example includes the |Performance.m|_ class for storing and reporting results.
As a final step after simulations are completed, |simulateDevice.m|_ populates the fields of this object for return to the user.
In addition to storing the results in a systematic structure, this class also provides some basic plotting functionality.

.. rubric:: Footnotes

.. [#f1] Note that since the hydrodynamics are linear, global scalings of the device can be analyzed without rerunning a BEM calculation.

.. |designDevice.m| replace:: ``designDevice.m``
.. _designDevice.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/WaveBot/designDevice.m
.. |simulateDevice.m| replace:: ``simulateDevice.m``
.. _simulateDevice.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/WaveBot/simulateDevice.m
.. |Performance.m| replace:: ``Performance.m``
.. _Performance.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/WaveBot/Performance.m
