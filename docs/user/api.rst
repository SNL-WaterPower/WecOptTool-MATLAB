.. _api:

***
API
***

WecOptTool
----------

The top-level WecOptTool package provides the main interface for 
the toolbox.

.. mat:autoclass:: +WecOptTool.Blueprint(baseFolder)
    :members:
    
    .. mat:automethod:: +WecOptTool.+base.AutoFolder.saveFolder

.. mat:autoclass:: +WecOptTool.Device()
    :members:
    
    .. mat:automethod:: +WecOptTool.+base.AutoFolder.saveFolder

.. mat:autofunction:: +WecOptTool.types

.. mat:autofunction:: +WecOptTool.mesh

.. mat:autofunction:: +WecOptTool.solver

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

WecOptTool.plot
---------------

The plot subpackage provides plots.

.. mat:automodule:: +WecOptTool.+plot
    :members:

WecOptTool.types
----------------

The types subpackage provides data type classes, that contain
parameters for recording the outputs of, and providing inputs to, the
various stages of a WecOptTool calculation.

.. mat:automodule:: +WecOptTool.+types


.. mat:autoclass:: +WecOptTool.+types.Hydro
    :members:

.. mat:autoclass:: +WecOptTool.+types.Mesh
    :members:

.. mat:autoclass:: +WecOptTool.+types.Motion
    :members:

.. mat:autoclass:: +WecOptTool.+types.Performance
    :members:

.. mat:autoclass:: +WecOptTool.+types.SeaState
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

WecOptTool.base
---------------

The base subpackage provides base classes.

.. mat:automodule:: +WecOptTool.+base


.. mat:autoclass:: +WecOptTool.+base.AutoFolder
    :members:

.. mat:autoclass:: +WecOptTool.+base.Data
    :members:

.. mat:autoclass:: +WecOptTool.+base.Mesher
    :members:

.. mat:autoclass:: +WecOptTool.+base.NEMOH
    :members:

.. mat:autoclass:: +WecOptTool.+base.Solver
    :members:
