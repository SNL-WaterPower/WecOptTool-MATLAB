.. _optimization:

********************************
Optimizing an Existing WEC Model
********************************

Overview
========

This section explains and expands upon the |optimization.m|_ example file 
provided in the ``examples/RM3`` directory of the WecOptTool source code. This 
example considers the DOE Reference Model 3 (RM3_) device. 

.. raw:: html

   <details><summary><a>See the entire example file</a></summary></br>

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

The general concept of WecOptTool is illustrated in the diagram below organized 
into three columns. 

    * **User Inputs** (Green) - aspects of the tool that the user can interact with
    * **Data Classes** (Blue) - objects used to store and transfer information within a study
    * **Solvers** (Yellow) - physics models and optimization algorithms that process data

To run WecOptTool the user will need to define each of the six input blocks in 
the User Inputs column. For the RM3, the Geometry will be defined by a mesh and 
design variables (:math:`r_1, r_2, d_1, d_2`), which refer to the spar/float 
radius and distance between the surface water level and the distance between 
the two bodies. In the Power Take Off (PTO) input, the user will define 
constraints on the PTO such as max force, :math:`F_{max}`, and max stroke 
:math:`\Delta x_{max}` and an operational constraint, :math:`H_{s,max}`.). 
Lastly, the kinematics will define how the two bodies of the RM3 move relative 
to the resource and relative degrees of freedom. 

Next, the user will choose one of three controllers to compute the resulting 
dynamics(``ProportionalDamping``, ``ComplexConjugate``, ``PseudoSpectral``). 
The Sea States input block for the RM3 may made up of a single spectrum or 
multiple spectra. Finally, the user will need to determine some objective 
function of interest for the device being studied. 

WecOptTool will use the User inputs to build a set of Data Classes and pass the 
information to the Solvers. The Hydrodynamics Solver currently uses Nemoh_ to 
compute the linear wave-body interaction properties using the boundary element 
method (BEM). The Optimal Control Solver will take the Data Classes to return 
device results for the given controller and sea state. This output, paired with 
some cost proxy from the device, can be used to evaluate the objective function 
inside the Optimization Routine. 

.. image:: /_static/WecOptToolFlowChart.svg
   :alt: Conceptual illustration of WecOptTool functionality

In WecOptTool, this process is executed by applying the following steps:

#. Select a device design and calculate its hydrodynamic parameters
#. Examine the performance of the device design using the chosen control 
   options, for a given seastate

The remainder of this page will illustrate (using the |optimization.m|_ 
example) how this process is applied to a co-optimisation problem.

.. _seastate:

Define a seastate
=================

WecOptTool can simulate single or multiple spectra sea states, where weightings 
can be provided to indicate the relative likelihood of each spectra. The 
following lines from |optimization.m|_ provide means of using the WAFO_ MATLAB 
toolbox or a predefined spectra from WecOptTool. 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 6-13
    :linenos:
    :lineno-start: 6

Spectra are formatted following the convention of the WAFO_ MATLAB toolbox, but 
can be generated via any means (e.g., from buoy measurements) as long as the 
structure includes the ``S.S`` and ``S.w`` fields. 

.. code:: matlab

    S = 

      struct with fields:

           S: [257×1 double]
           w: [257×1 double]
          tr: []
           h: Inf
        type: 'freq'
         phi: 0
        norm: 0
        note: 'Bretschneider, Hm0 = 4, Tp = 5'
        date: '25-Mar-2020 13:08:28'

In the active code above from |optimization.m|_, there are eight spectra loaded into a |struct array|_.
These can be plotted using standard MATLAB commands.

.. code:: matlab

    figure
    hold on
    grid on
    arrayfun(@(x) plot(x.w,x.S,'DisplayName',x.note), S)
    legend()
    xlim([0,3])
    xlabel('Freq. [rad/s]')
    ylabel('Spect. density [m^2 rad/s]')

.. image:: /_static/example_spectra.svg
   :alt: Eight spectra consider in example.m

The predefined spectra are returned as :mat:class:`~+WecOptTool.SeaState` 
objects. The :mat:class:`~+WecOptTool.SeaState` class allows the user to 
manipulate the given spectra to the requirements of the experiment. 
Automatically, the weighting parameter ``mu`` will be set to unity when 
multiple sea-states are given with ``mu`` undefined. In this example, 
frequencies that have less than 1% of the maximum spectral density are also 
removed, (using the ``"trimFrequencies"`` option) to increase the speed of 
computation with minimal loss of accuracy. See the 
:mat:class:`~+WecOptTool.SeaState` documentation for all available options. 

Create file storage
===================

A number of processes used by WecOptTool require temporary storage for 
intermediate files. Additionally, as part of the optimization process, it can 
be useful to store data in temporary files for recovery later (as MATLAB 
optimizers do not keep intermediate values). WecOptTool provides the 
:mat:class:`~+WecOptTool.AutoFolder` class for just this purpose, which 
provides a temporary storage space. Also, the user does not need to worry about 
deleting the files contained in the folder when finished, as these are removed 
automatically when the :mat:class:`~+WecOptTool.AutoFolder` object is deleted. 
The folder is created as follows: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 15-16
    :linenos:
    :lineno-start: 15

Create an objective function
============================

Next, we create the objective function we wish to minimise. Note, functions 
must be defined at the bottom of the script, although we will them above. The 
complete code is as follows: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 63-91
    :linenos:
    :lineno-start: 63

The following subsections will describe each stage of setting up the objective
function.

Define the inputs
-----------------

The input definition of an objective function used in WecOptTool is typically
going to take the form::

    function result = myObjFun(x, seastate, folder)

where ``x`` is the solution to be tested, ``seastate`` is a 
:mat:class:`~+WecOptTool.SeaState` object and ``folder`` is an 
:mat:class:`~+WecOptTool.AutoFolder` object. Although in most cases only ``x`` 
will vary, the other inputs will be required within the optimization function 
and can't be accessed through the global workspace. 

Define design variables
-----------------------

As shown in the diagram below, for RM3 study considered in |optimization.m|_ the design variables are the radius of the surface float, ``r1``, the radius of 
the heave plate, ``r2``, the draft of the surface float, ``d1``, and the depth of the heave plate, ``d2``, such that ``x = [r1, r2, d1, d2]``.
The optimization algorithm will attempt to find the values of ``x`` that minimize the objective function. 

.. image:: /_static/example_rm3Parametric.svg
   :width: 400pt
   :alt: RM3 device parametric dimensions

For the RM3 example, the hydrodynamic assessment of a device design is 
calculated by the ``designDevice`` function. The ``'parametric'`` option to 
``designDevice`` requires 6 arguments, a folder to store intermediate files, 
the geometry design variables, ``r1, r2, d1, d2``, and a representative set of 
angular frequencies to be calculated by NEMOH. The folder is provided by the 
``path`` attribute of the :mat:class:`~+WecOptTool.AutoFolder` object. The 
design variables will be passed by the optimisation routine, while the 
frequencies can be extracted from the given :mat:class:`~+WecOptTool.SeaState` 
object using its :mat:meth:`~+WecOptTool.SeaState.getRegularFrequencies` 
method, which provides regularly spaced frequencies covering all spectra in the 
object array. These inputs are combined and then added as arguments to the 
``designDevice`` function, after the design option name. 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 69-72
    :linenos:
    :lineno-start: 69

.. _controlledPerformance:

Calculate controlled device performance
---------------------------------------

In the RM3 example, three types of controllers are defined:

 - **Proportional Damping** (``'P'``): Resistive damping (i.e., a proportional feedback on velocity) (see, e.g., [Falnes]_). Here, the power take-off (PTO) force is set as

   .. math::
     F_u(\omega) = -B_{PTO}(\omega)u(\omega)

   where :math:`B_{PTO}` is a constant chosen to maximize absorbed power and :math:`u(\omega)` is the velocity. |br| |br|
   
 - **Complex Conjugate** (``'CC'``): Optimal power absorption through impedance matching (see, e.g., [Falnes]_). The intrinsic impedance is given by 

   .. math::
    Z_i(\omega) = B(\omega) + i \left( \omega{}(m + A(\omega)) - \frac{K_{HS}}{\omega}\right) ,

   where :math:`\omega` is the radial frequency, :math:`B(\omega)` is the 
   radiation damping, :math:`m` is the rigid body mass, :math:`A(\omega)` is the
   added mass, and :math:`K_{HS}` is the hydrostatic stiffness. Optimal power 
   transfer occurs when the PTO force, :math:`F_u` is set such
   that

   .. math::
    F_u(\omega) = -Z_i^*(\omega)u(\omega) ,

   where :math:`u(\omega)` is the velocity. |br| |br|

 - **Pseudo Spectral** (``'PS'``): Constrained optimal power absorption 
   [Bacelli]_. This is a numerical optimal control algorithm capable of dealing 
   with both constraints and nonlinear dynamics. This approach is based on 
   |pseudo spectral method|_.

For the |optimization.m|_ example we choose the Complex Conjugate option. The 
performance of the controlled device design is evaluated for a given sea-state 
by the ``simulateDevice`` function, which takes, as input, the output of the 
``designDevice`` function, the sea-state to evaluate and the controller 
selection (with additional optional parameters, if used). Here, the 
device is evaluated across the 8 different sea-states in the example spectra, 
as follows: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 74-78
    :linenos:
    :lineno-start: 74

Define the objective function value
-----------------------------------

The value of the objective function is provided by an axillary function (called 
``weightedPower``) which calculates the maximum absorbed power, weighted across 
all spectra in the given seastate: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 88-91
    :linenos:
    :lineno-start: 88

Then, to make a minimisation problem, the negation of this value returned: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 80
    :linenos:
    :lineno-start: 80

.. note::
    **Objective function:** The chosen objective function in |optimization.m|_ 
    can be altered to better approximate a more meaningful objective (e.g., 
    levelized cost of energy).

Record intermediate values
--------------------------

MATLAB's optimization routines only store the sample and cost function values 
of the designs tested. WecOptTool provides a means to store intermediate 
values, used in the objection function, using the 
:mat:meth:`~+WecOptTool.AutoFolder.stashVar` method of the 
:mat:class:`~+WecOptTool.AutoFolder` class. In this example we add the sample 
value and the sea state frequencies to the ``simulateDevice`` function output 
and then stash it for recovery later: 

 .. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 82-84
    :linenos:
    :lineno-start: 82

Set optimization solver
=======================

MATLAB's `fmincon <https://uk.mathworks.com/help/optim/ug/fmincon.html>`_ optimization solver is used in |optimization.m|_.

The initial values, ``x0``, lower bounds, ``lb``, and upper bounds, ``ub`` of the design variables can be set as follows.

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 20-23
    :linenos:
    :lineno-start: 20

Options can also be supplied for fmincon:

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 25-33
    :linenos:
    :lineno-start: 25

.. note::
    The ``MaxFunctionEvaluations`` is set to 5 in |optimization.m|_ to permit relatively quick runs, but can be increased to allow for a potentially better solution (with the other options left as-is, this should require 150 function evaluations).

.. image:: /_static/example_optimplotfval.svg
   :alt: Progression of objective function value for RM3 example

In order to pass the above options, some dummy values must also be supplied for other arguments required by fmincon:

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 35-40
    :linenos:
    :lineno-start: 35

Run optimiser and view results
==============================

Before using the objective function, the inputs must be simplified to allow 
fmincon to just pass the design variables. To do this an `anonymous function 
<https://uk.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html>`_ 
is defined, which requires the design variables as input and fixes the value of 
the SeaState and AutoFolder object inputs: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 44-45
    :linenos:
    :lineno-start: 44

The study can then be executed by calling fmincon:

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 47-48
    :linenos:
    :lineno-start: 47

Once the calculation is complete, the ``x`` and ``fval`` variables show that the study has produced the following design: 

* :math:`r_1`: 5 [m]
* :math:`r_2`: 7.5 [m]
* :math:`d_1`: 1.125 [m]
* :math:`d_2`: 42 [m]
* Maximum absorbed power: 2357934.25081 [W]

Examine optimum design
======================

To recover the detailed performance of all the device designs tested in the 
optimisation, the :mat:meth:`~+WecOptTool.AutoFolder.recoverVar` method of the 
:mat:class:`~+WecOptTool.AutoFolder` class is used: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 50-51
    :linenos:
    :lineno-start: 50

Next, the device that matches the best solution returned by fmincon must be 
found. To do this, compare the ``x`` field of the recovered structs, until a 
match is found, as follows: 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 53-59
    :linenos:
    :lineno-start: 53

Finally, by using the :mat:func:`+WecOptTool.+plot.powerPerFreq` function, the 
spectral distribution of energy absorbed by the resulting design for each of 
the eight sea states can be shown. 

.. literalinclude:: /../examples/RM3/optimization.m
    :language: matlab
    :lines: 61
    :linenos:
    :lineno-start: 61

.. image:: /_static/example_spectralPowerPlot.svg
   :width: 400pt
   :alt: Absorbed Spectral power distribution for each sea state

.. [Falnes] Falnes, Johannes. Ocean waves and oscillating systems: linear 
         interactions including wave-energy extraction. Cambridge University 
         Press, 2002.

.. [Bacelli] Bacelli, Giorgio, and John V. Ringwood. "Numerical optimal control 
       of wave energy converters." IEEE Transactions on Sustainable Energy 6.2 
       (2014): 294-302.

.. |optimization.m| replace:: ``optimization.m``
.. _optimization.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/RM3/optimization.m
.. |RM3.m| replace:: ``RM3.m``
.. _RM3.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/RM3/RM3.m
.. _WAFO: http://www.maths.lth.se/matstat/wafo/
.. _RM3: https://tethys-engineering.pnnl.gov/signature-projects/rm3-wave-point-absorber
.. _Nemoh: https://github.com/LHEEA/Nemoh
.. |struct array| replace:: struct array
.. _struct array: https://www.mathworks.com/help/matlab/matlab_prog/create-a-structure-array.html
.. |pseudo spectral method| replace:: pseudo spectral optimal control
.. _pseudo spectral method: https://en.wikipedia.org/wiki/Pseudospectral_optimal_control

.. |br| raw:: html

   <br />
