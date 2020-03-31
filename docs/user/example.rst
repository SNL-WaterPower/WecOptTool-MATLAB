.. _user-example:

*******
Example
*******

This section explains and expands upon the |example.m|_ example file provided
in the root directory of the WecOptTool source code. This example considers the 
DOE Reference Model 3 (RM3_) device.

.. raw:: html

   <details><summary><a>See the entire example file</a></summary></br>

.. literalinclude:: /../example.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

The general concept of WecOptTool is illustrated in the diagram below. In the 
upper left-hand corner, an optimization algorithm controls the selection of a 
set of design variables. In this diagram, some geometric design variables, 
:math:`r_1, r_2, d_1, d_2`, are considered along with constraints on the power 
take-off (PTO) max force, :math:`F_{max}`, and max stroke :math:`\Delta x_{max}`
and an operational constraint, :math:`H_{s,max}`. The device defined by these 
design variables is passed to the grey *evaluation* block. Here, Nemoh_ is used 
to compute the linear wave-body interaction properties using the boundary 
element method (BEM). Next, using these properties and some set of sea states, 
one of three controllers (``ProportionalDamping``, ``ComplexConjugat``, ``PseudoSpectral``) 
are used to compute the resulting dynamics. From on these dynamics and some 
model for cost (e.g., based on the size dimensions and the capabilities of the 
PTO) can be combine to produce an objective function, which is returned to the 
optimization solver.

.. image:: /_static/WecOptTool_algorithmDiagram.svg
   :alt: Conceptual illustration of WecOptTool functionality

Create an RM3Study Object
=========================

The :mat:class:`~+WecOptTool.RM3Study` class allows the user to configure a
simulation to their specifications. Once instantiated, an RM3Study object can 
be modified using other classes (as described below), and once prepared is
passed to the main functions of the toolbox.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 22-23 
    :linenos:
    :lineno-start: 22

Define a Sea-State
==================

WecOptTool can simulate single or multiple spectra sea states, where weightings
can be provided to indicate the relative likelihood of each spectra. The 
following lines from |example.m|_ provide means of using the WAFO_ matlab 
toolbox or preset spectra from WecOptTool.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 25-32 
    :linenos:
    :lineno-start: 25

Spectra are formatted following the convention of the WAFO_ matlab toolbox, but 
can be generated in via any means (e.g., from buoy measurements) as long as the 
structure includes the ``S.S``, ``S.w``, and ``S.phi`` fields.

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

In the active code above from |example.m|_, there are eight spectra loaded into 
a |struct array|_. These can be plotted using standard MATLAB commands.

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

The desired spectrum or spectra can then be added to the study object.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 34-35
    :linenos:
    :lineno-start: 34

Add a controller to the study
=============================

WecOptTool allows for three types of controllers:

 - **ProportionalDamping:** Resistive damping (i.e., a proportional feedback on 
   velocity) (see, e.g., [Falnes]_). Here, the power take-off (PTO) force is set 
   as

   .. math::
     F_u(\omega) = -B_{PTO}(\omega)u(\omega)

   where :math:`B_{PTO}` is a constant chosen to maximize absorbed power and 
   :math:`u(\omega)` is the velocity. |br| |br|
   
 - **ComplexConjugate:** Optimal power absorption through impedance matching 
   (see, e.g., [Falnes]_). The intrinsic impedance is given by 

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

 - **PseudoSpectral:** Constrained optimal power absorption [Bacelli]_. This is 
   a numerical optimal control algorithm capable of dealing with both 
   constraints and nonlinear dynamics. This approach is based on 
   |pseudo spectral method|_.

The controllers are defined as classes in the :mat:mod:`~+WecOptTool.+control` 
sub-package.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 37-39
    :linenos:
    :lineno-start: 37

Define design variables
=======================

As shown in the diagram below, for RM3 study considered in |example.m|_ the design 
variables are the radius of the surface float, ``r1``, the radius of the heave 
plate, ``r2``, the draft of the surface float, ``d1``, and the depth of the 
heave plate, ``d2``, such that ``x = [r1, r2, d1, d2]``. The optimization 
algoritm will attempt to find the values of ``x`` that minimize the objective 
function. 

.. note::
    **Objective function:** The built-in objective function of |example.m|_ is
    set to maximize absorbed power. This function can be altered better 
    approximate a more meaningful objective (e.g., levelized cost of energy).

.. image:: /_static/example_rm3Parametric.svg
   :width: 400pt
   :alt: RM3 device parametric dimensions

The initial values,``x0``, lower bounds, ``lb``, and upper bounds, 
``ub`` of the design variables can be set as follows.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 41-47
    :linenos:
    :lineno-start: 41

Alternatively, a simpler study with a single scalar design variable can be 
employed. In this case, instead of scaling various dimensions of the device 
individually, the entire device is scaled based on a single design variable. 

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 49-55
    :linenos:
    :lineno-start: 49

The options for design variables are defined as classes in the 
:mat:mod:`~+WecOptTool.+geom` sub-package.

Set optimization solver and options
===================================

MATLAB's ``fmincon`` optimization solver is used in |example.m|_.

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 57-60
    :linenos:
    :lineno-start: 57

Run the study and view results
==============================

The study can be :mat:func:`~+WecOptTool.run` and reviewed 
(with :mat:func:`~+WecOptTool.result` and :mat:func:`~+WecOptTool.plot`) as 
follows:

.. literalinclude:: /../example.m
    :language: matlab
    :lines: 62-69
    :linenos:
    :lineno-start: 62

.. [Falnes] Falnes, Johannes. Ocean waves and oscillating systems: linear 
         interactions including wave-energy extraction. Cambridge University 
         Press, 2002.

.. [Bacelli] Bacelli, Giorgio, and John V. Ringwood. "Numerical optimal control 
       of wave energy converters." IEEE Transactions on Sustainable Energy 6.2 
       (2014): 294-302.

.. |example.m| replace:: ``example.m``
.. _example.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/example.m
.. _WAFO: http://www.maths.lth.se/matstat/wafo/
.. _RM3: https://tethys-engineering.pnnl.gov/signature-projects/rm3-wave-point-absorber
.. _Nemoh: https://github.com/LHEEA/Nemoh
.. |struct array| replace:: ``struct array``
.. _struct array: https://www.mathworks.com/help/matlab/matlab_prog/create-a-structure-array.html
.. |pseudo spectral method| replace:: pseudo spectral optimal control
.. _pseudo spectral method: https://en.wikipedia.org/wiki/Pseudospectral_optimal_control

.. |br| raw:: html

   <br />