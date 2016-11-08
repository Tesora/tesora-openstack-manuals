Message queue
~~~~~~~~~~~~~

OpenStack uses a :term:`message queue` to coordinate operations and
status information among services. The message queue service typically
runs on the controller node. OpenStack supports several message queue
services including `RabbitMQ <http://www.rabbitmq.com>`__,
`Qpid <http://qpid.apache.org>`__, and `ZeroMQ <http://zeromq.org>`__.
However, most distributions that package OpenStack support a particular
message queue service. This guide implements the RabbitMQ message queue
service because most distributions support it. If you prefer to
implement a different message queue service, consult the documentation
associated with it.

The message queue runs on the controller node.

Install and configure components
--------------------------------

1. Install the package:

   .. only:: ubuntu or debian

      .. code-block:: console

         # apt install rabbitmq-server

      .. end

   .. endonly

   .. only:: rdo

      .. code-block:: console

         # yum install rabbitmq-server

      .. end

   .. endonly

   .. only:: obs

      .. code-block:: console

         # zypper install rabbitmq-server

      .. end

   .. endonly

.. only:: rdo or obs

   2. Start the message queue service and configure it to start when the
      system boots:

      .. code-block:: console

         # systemctl enable rabbitmq-server.service
         # systemctl start rabbitmq-server.service

      .. end

   3. Add the ``openstack`` user:

      .. code-block:: console

         # rabbitmqctl add_user openstack RABBIT_PASS

         Creating user "openstack" ...

      .. end

      Replace ``RABBIT_PASS`` with a suitable password.

   4. Permit configuration, write, and read access for the
      ``openstack`` user:

      .. code-block:: console

         # rabbitmqctl set_permissions openstack ".*" ".*" ".*"

         Setting permissions for user "openstack" in vhost "/" ...

      .. end

.. endonly

.. only:: ubuntu or debian

   2. Add the ``openstack`` user:

      .. code-block:: console

         # rabbitmqctl add_user openstack RABBIT_PASS

         Creating user "openstack" ...

      .. end

      Replace ``RABBIT_PASS`` with a suitable password.

   3. Permit configuration, write, and read access for the
      ``openstack`` user:

      .. code-block:: console

         # rabbitmqctl set_permissions openstack ".*" ".*" ".*"

         Setting permissions for user "openstack" in vhost "/" ...

      .. end

.. endonly
