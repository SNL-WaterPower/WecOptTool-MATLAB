.. _model:

************************
Creating a New WEC Model
************************

This section explains how to create a WecOptTool model for a new WEC and will
be completed shortly.

The WecOptTool framework encapsulates the WEC design and control co-optimization process using two key classes.
The :mat:class:`~+WecOptTool.Blueprint` class is used to describe the potential forms (e.g.
shape, control type, etc.) that a WEC device might take.
The user of WecOptTool must create a `concrete subclass <https://uk.mathworks.com/help/matlab/matlab_oop/abstract-classes-and-interface s.html>`_ of the :mat:class:`~+WecOptTool.Blueprint` class that describes the potential geometry, motion and control options for their chosen WEC design.
For this example, the subclass is already prepared in the |RM3.m|_ file.

The :mat:class:`~+WecOptTool.Device` class represents a device with a chosen set of design parameters, created from a Blueprint subclass.
Once the user has created a Blueprint subclass, Device objects are created using the Blueprint, for a specified design and control system.
For more information on how Blueprint and Device classes are used see the :ref:`optimization` and :ref:`api` sections. 

.. |RM3.m| replace:: ``RM3.m``
.. _RM3.m: https://github.com/SNL-WaterPower/WecOptTool/blob/master/examples/RM3/RM3.m
