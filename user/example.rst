*******
Example
*******

This section explains and expands upon the |example.m|_ example file provided
in the root directory of the WecOptTool source code. 

.. raw:: html

   <details><summary><a>See the entire example file</a></summary></br>

.. literalinclude:: /git_src/example.m
    :language: matlab
    :linenos:

.. raw:: html

   </details></br>

Create an RM3Study Object
=========================

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 4-5 
    :linenos:
    :lineno-start: 4

The :mat:class:`~+WecOptTool.RM3Study` class allows the user to configure a
simulation to their specifications. Once instantiated, an RM3Study object can 
be modified using other classes (as described below), and once prepared is
passed to the main functions of the toolbox.

Define a Sea-State
==================

.. literalinclude:: /git_src/example.m
    :language: matlab
    :lines: 7-17 
    :linenos:
    :lineno-start: 7

WecOptTool can simulate single or multiple spectra sea states, where weightings
can be provided to indicate the relative likelihood of each spectra. Spectra
are formatted following the convention of the WAFO_ matlab toolbox:

.. code:: matlab

    S = 

      1×11 struct array with fields:

        S
        w
        tr
        h
        type
        phi
        norm
        note
        date


.. |example.m| replace:: ``example.m``
.. _example.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/example.m
.. _WAFO: http://www.maths.lth.se/matstat/wafo/
