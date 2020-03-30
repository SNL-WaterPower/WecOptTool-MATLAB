##########
WecOptTool
##########

The WEC Design Optimization Toolbox (WecOptTool) allows users to perform wave 
energy converter (WEC) device design optimization studies with constrained 
optimal control.

In particular, this toolbox offers **simultaneous optimization of WEC geometry 
and power take-off (PTO) control**, using the `RM3 point absorber`_ as a case 
study. The ultimate goal of this project is to offer a **generalised framework 
for combined geometry and power take-off control co-optimization**.

Various configuration options are currently available for RM3:

* **Geometric design**

    * Scalar multiplier optimization
    * 4-parameter (radius and depth of float and reaction plate) optimization
    * Existing geometry

* **PTO control**

    * Proportional damping
    * Complex conjugate
    * Constrained pseudo spectral control optimization

See the :ref:`user-example` section for further details.

Delevopers
==========
WecOptTool is developed by `Sandia National Laboratories`_, with support from 
`Data Only Greater`_. The developers would also like to acknowledge benefit from
past collaborations with the `Oregon State University Design Engineering Lab`_.

.. include:: contents.rst

Sandia National Laboratories is a multi-mission laboratory managed and 
operated by National Technology and Engineering Solutions of Sandia, 
LLC., a wholly owned subsidiary of Honeywell International, Inc., for 
the U.S. Department of Energy's National Nuclear Security Administration 
under contract DE-NA0003525.

.. _Oregon State University Design Engineering Lab: https://design.engr.oregonstate.edu
.. _Sandia National Laboratories: https://www.sandia.gov
.. _Data Only Greater: https://www.dataonlygreater.com
.. _RM3 point absorber: https://tethys-engineering.pnnl.gov/signature-projects/rm3-wave-point-absorber
