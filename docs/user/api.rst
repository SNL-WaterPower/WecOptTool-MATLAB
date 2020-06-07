***
API
***

WecOptTool
==========

The WecOptTool package provides the main interface for the toolbox.

WecOptTool.types
----------------

The types subpackage provides data type classes, that contain
parameters for recording the outputs of, and providing inputs to, the
various stages of a WecOptTool calculation.

.. mat:autoclass:: +WecOptTool.+types.Hydro(input)
    :members:

.. mat:autoclass:: +WecOptTool.+types.Mesh(input)
    :members:

.. mat:autoclass:: +WecOptTool.+types.Motion(input)
    :members:

.. mat:autoclass:: +WecOptTool.+types.Performance(input)
    :members:

.. mat:autoclass:: +WecOptTool.+types.SeaState(input)
    :members:

WecOptTool.callbacks
--------------------

The mesh callbacks provides callbacks for use with user defined
blueprints created using the :mat:class:`+WecOptTool.Blueprint` class.
This allows reuse of commonly used functionality between blueprints.

WecOptTool.callbacks.geometry
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Geometry callbacks are used with the ``geometryCallbacks`` property
of :mat:class:`+WecOptTool.Blueprint`.

.. mat:automodule:: +WecOptTool.+callbacks.+geometry
    :members:

WecOptTool.mesh
---------------

The mesh subpackage provides mesh generation classes, that provide
the standard method ``makeMesh``.

.. mat:automodule:: +WecOptTool.+mesh
    :members:

WecOptTool.solver
-----------------

The solver subpackage provides hydrodynamic solver classes, that 
provide the standard method ``getHydro``.

.. mat:automodule:: +WecOptTool.+solver
    :members:

WecOptTool.plot
---------------

The plot subpackage provides plots.

.. mat:automodule:: +WecOptTool.+plot
    :members:

WecOptTool.base
---------------

The base subpackage provides base classes.

.. mat:automodule:: +WecOptTool.+base
    :members:
