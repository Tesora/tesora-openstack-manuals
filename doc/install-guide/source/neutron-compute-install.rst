Install and configure compute node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The compute node handles connectivity and :term:`security groups <security
group>` for instances.

.. only:: ubuntu or debian

   Install the components
   ----------------------

   .. code-block:: console

      # apt install neutron-linuxbridge-agent

   .. end

.. endonly

.. only:: rdo

   Install the components
   ----------------------

   .. todo:

      https://bugzilla.redhat.com/show_bug.cgi?id=1334626

   .. code-block:: console

      # yum install openstack-neutron-linuxbridge ebtables ipset

   .. end

.. endonly

.. only:: obs

   Install the components
   ----------------------

   .. code-block:: console

      # zypper install --no-recommends \
        openstack-neutron-linuxbridge-agent bridge-utils

   .. end

.. endonly

Configure the common component
------------------------------

The Networking common component configuration includes the
authentication mechanism, message queue, and plug-in.

.. include:: shared/note_configuration_vary_by_distribution.rst

* Edit the ``/etc/neutron/neutron.conf`` file and complete the following
  actions:

  * In the ``[database]`` section, comment out any ``connection`` options
    because compute nodes do not directly access the database.

  * In the ``[DEFAULT]`` section, configure ``RabbitMQ``
    message queue access:

    .. path /etc/neutron/neutron.conf
    .. code-block:: ini

       [DEFAULT]
       ...
       transport_url = rabbit://openstack:RABBIT_PASS@controller

    .. end

    Replace ``RABBIT_PASS`` with the password you chose for the ``openstack``
    account in RabbitMQ.

  * In the ``[DEFAULT]`` and ``[keystone_authtoken]`` sections, configure
    Identity service access:

    .. path /etc/neutron/neutron.conf
    .. code-block:: ini

       [DEFAULT]
       ...
       auth_strategy = keystone

       [keystone_authtoken]
       ...
       auth_uri = http://controller:5000
       auth_url = http://controller:35357
       memcached_servers = controller:11211
       auth_type = password
       project_domain_name = default
       user_domain_name = default
       project_name = service
       username = neutron
       password = NEUTRON_PASS

    .. end

    Replace ``NEUTRON_PASS`` with the password you chose for the ``neutron``
    user in the Identity service.

    .. note::

       Comment out or remove any other options in the
       ``[keystone_authtoken]`` section.

  .. only:: rdo

     * In the ``[oslo_concurrency]`` section, configure the lock path:

       .. path /etc/neutron/neutron.conf
       .. code-block:: ini

          [oslo_concurrency]
          ...
          lock_path = /var/lib/neutron/tmp

       .. end

  .. endonly


Configure networking options
----------------------------

Choose the same networking option that you chose for the controller node to
configure services specific to it. Afterwards, return here and proceed to
:ref:`neutron-compute-compute`.

.. toctree::
   :maxdepth: 1

   neutron-compute-install-option1.rst
   neutron-compute-install-option2.rst

.. _neutron-compute-compute:

Configure Compute to use Networking
-----------------------------------

* Edit the ``/etc/nova/nova.conf`` file and complete the following actions:

  * In the ``[neutron]`` section, configure access parameters:

    .. path /etc/nova/nova.conf
    .. code-block:: ini

       [neutron]
       ...
       url = http://controller:9696
       auth_url = http://controller:35357
       auth_type = password
       project_domain_name = default
       user_domain_name = default
       region_name = RegionOne
       project_name = service
       username = neutron
       password = NEUTRON_PASS

    .. end

    Replace ``NEUTRON_PASS`` with the password you chose for the ``neutron``
    user in the Identity service.

Finalize installation
---------------------

.. only:: rdo

   #. Restart the Compute service:

      .. code-block:: console

         # systemctl restart openstack-nova-compute.service

      .. end

   #. Start the Linux bridge agent and configure it to start when the
      system boots:

      .. code-block:: console

         # systemctl enable neutron-linuxbridge-agent.service
         # systemctl start neutron-linuxbridge-agent.service

      .. end

.. endonly

.. only:: obs

   #. The Networking service initialization scripts expect the variable
      ``NEUTRON_PLUGIN_CONF`` in the ``/etc/sysconfig/neutron`` file to
      reference the ML2 plug-in configuration file. Ensure that the
      ``/etc/sysconfig/neutron`` file contains the following:

      .. path /etc/sysconfig/neutron
      .. code-block:: ini

         NEUTRON_PLUGIN_CONF="/etc/neutron/plugins/ml2/ml2_conf.ini"

      .. end

   #. Restart the Compute service:

      .. code-block:: console

         # systemctl restart openstack-nova-compute.service

      .. end

   #. Start the Linux Bridge agent and configure it to start when the
      system boots:

      .. code-block:: console

         # systemctl enable openstack-neutron-linuxbridge-agent.service
         # systemctl start openstack-neutron-linuxbridge-agent.service

      .. end

.. endonly

.. only:: ubuntu or debian

   #. Restart the Compute service:

      .. code-block:: console

         # service nova-compute restart

      .. end

   #. Restart the Linux bridge agent:

      .. code-block:: console

         # service neutron-linuxbridge-agent restart

      .. end

.. endonly
