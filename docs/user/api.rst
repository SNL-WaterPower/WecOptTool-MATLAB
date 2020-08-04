.. _api:

***
API
***

WecOptTool
----------

.. mat:autofunction:: +WecOptTool.types

.. mat:autofunction:: +WecOptTool.mesh

.. mat:autofunction:: +WecOptTool.solver

WecOptTool.geometry
-------------------

.. mat:automodule:: +WecOptTool.+geometry
    :members:

WecOptTool.math
---------------

.. mat:automodule:: +WecOptTool.+math
    :members:

WecOptTool.plot
---------------

The plot subpackage provides plots.

.. mat:automodule:: +WecOptTool.+plot
    :members:

WecOptTool.types
----------------

The types subpackage provides data type classes, that contain parameters for recording the outputs of, and providing inputs to, the various stages of a WecOptTool calculation.

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

The mesh subpackage provides mesh generation classes, that provide the standard method ``makeMesh``.

.. mat:automodule:: +WecOptTool.+mesh
    :members:

WecOptTool.solver
-----------------

The solver subpackage provides hydrodynamic solver classes, that provide the standard method ``getHydro``.

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
