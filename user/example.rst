*******
Example
*******

This section explains and expands upon the |example.m|_ example file provided
in the root directory of the WecOptTool source code. This example considers the 
DOE Reference Model 3 (RM3_) device.

.. raw:: html

   <details><summary><a>See the entire example file</a></summary></br>

.. literalinclude:: /git_src/example.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

Create an RM3Study Object
=========================

The :mat:class:`~+WecOptTool.RM3Study` class allows the user to configure a
simulation to their specifications. Once instantiated, an RM3Study object can 
be modified using other classes (as described below), and once prepared is
passed to the main functions of the toolbox.

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 4-5 
    :linenos:
    :lineno-start: 4

Define a Sea-State
==================

WecOptTool can simulate single or multiple spectra sea states, where weightings
can be provided to indicate the relative likelihood of each spectra. The 
following lines from |example.m|_ provide means of using the WAFO_ matlab 
toolbox or preset spectra from WecOptTool.

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 7-17 
    :linenos:
    :lineno-start: 7

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

The desired spectrum or spectra can then be added to the study object

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 19-21
    :linenos:
    :lineno-start: 19

Add a controller to the study
=============================

WecOptTool allows for three types of controllers:

 - **ProportionalDamping:** Resistive damping (i.e., a proportional feedback on 
   velocity) (see, e.g., [1]_)
 - **ComplexConjugate:** Optimal power absorption (see, e.g., [1]_)
 - **PseudoSpectral:** Constrained optimal power absorption [2]_

The controllers are defined as classes in the :mat:mod:`~+WecOptTool.+control` 
sub-package.

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 22-25
    :linenos:
    :lineno-start: 22

Define design variables
=======================

The initial values, lower bounds ``lb``, and upper bounds ``ub`` of the design 
variables can be set as follows. For the RM3 study shown in |example.m|_, the 
design variables are the radius of the surface float, ``r1``, the radius of the 
heave plate, ``r2``, the draft of the surface float, ``d1``, and the depth of 
the heave plate, ``d2``, such that ``x = [r1, r2, d1, d2]``. In addition to 
bounding the design variables, we must provide an initial guess, ``x0``.

.. image:: /_static/example_rm3Parametric.svg
   :width: 400pt
   :alt: RM3 device parametric dimensions

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 26-33
    :linenos:
    :lineno-start: 26

Alternatively, a simpler study with a single scalar design variable can be 
employed. In this case, instead of scaling various dimensions of the device 
individually, the entire device is scaled based on a single design variable. 

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 34-41
    :linenos:
    :lineno-start: 34

The options for design variables are defined as classes in the 
:mat:mod:`~+WecOptTool.+geom` sub-package.

Set optimization solver and options
===================================

MATLAB's ``fmincon`` optimization solver is used in |example.m|_.

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 42-46
    :linenos:
    :lineno-start: 42

Run the study and view results
==============================

The study can be :mat:func:`~+WecOptTool.run` and reviewed 
(with :mat:func:`~+WecOptTool.result` and :mat:func:`~+WecOptTool.plot`) as 
follows:

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 47-55
    :linenos:
    :lineno-start: 47

.. [1] Falnes, Johannes. Ocean waves and oscillating systems: linear 
         interactions including wave-energy extraction. Cambridge University 
         Press, 2002.

.. [2] Bacelli, Giorgio, and John V. Ringwood. "Numerical optimal control of 
       wave energy converters." IEEE Transactions on Sustainable Energy 6.2 
       (2014): 294-302.

.. |example.m| replace:: ``example.m``
.. _example.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/example.m
.. _WAFO: http://www.maths.lth.se/matstat/wafo/
.. _RM3: https://energy.sandia.gov/programs/renewable-energy/water-power/technology-development/reference-model-project-rmp/
