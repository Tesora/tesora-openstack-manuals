=======
Compute
=======

.. toctree::
   :maxdepth: 1

   compute/nova-conf.rst
   compute/logging.rst
   compute/authentication-authorization.rst
   compute/resize.rst
   compute/database-connections.rst
   compute/rpc.rst
   compute/api.rst
   compute/fibre-channel.rst
   compute/iscsi-offload.rst
   compute/hypervisors.rst
   compute/scheduler.rst
   compute/cells.rst
   compute/conductor.rst
   compute/nova-conf-samples.rst
   compute/logs.rst
   compute/config-samples.rst
   tables/conf-changes/nova.rst

The OpenStack Compute service is a cloud computing fabric
controller, which is the main part of an IaaS system.
You can use OpenStack Compute to host and manage cloud computing systems.
This section describes the OpenStack Compute configuration options.

To configure your Compute installation,
you must define configuration options in these files:

* ``nova.conf``. Contains most of the Compute configuration options.
  Resides in the ``/etc/nova`` directory.
* ``api-paste.ini``. Defines Compute limits.
  Resides in the ``/etc/nova`` directory.
* Related Image service and Identity service management configuration files.
