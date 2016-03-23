.. _trove-install:

Install and configure
~~~~~~~~~~~~~~~~~~~~~

This section describes how to install and configure the
Database service, code-named trove, on the controller node.

This section assumes that you already have a working OpenStack
environment with at least the following components installed:
Compute, Image Service, Identity.

* If you want to do backup and restore, you also need Object Storage.

* If you want to provision datastores on block-storage volumes, you also
  need Block Storage.


.. only:: obs or rdo or ubuntu

   Prerequisites
   -------------

   Before you install and configure Database, you must create a
   database, service credentials, and API endpoints.

   #. To create the database, complete these steps:

      * Use the database access client to connect to the database
        server as the ``root`` user:

        .. code-block:: console

           $ mysql -u root -p

      * Create the ``trove`` database:

        .. code-block:: console

           CREATE DATABASE trove;

      * Grant proper access to the ``trove`` database:

        .. code-block:: console

           GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'localhost' \
             IDENTIFIED BY 'TROVE_DBPASS';
           GRANT ALL PRIVILEGES ON trove.* TO 'trove'@'%' \
             IDENTIFIED BY 'TROVE_DBPASS';

        Replace ``TROVE_DBPASS`` with a suitable password.

      * Exit the database access client.

   #. Source the ``admin`` credentials to gain access to
      admin-only CLI commands:

      .. code-block:: console

         $ source admin-openrc.sh

   #. To create the service credentials, complete these steps:

      * Create the ``trove`` user:

        .. code-block:: console

           $ openstack user create --domain default --password-prompt trove
           User Password:
           Repeat User Password:
           +-----------+-----------------------------------+
           | Field     | Value                             |
           +-----------+-----------------------------------+
           | domain_id | default                           |
           | enabled   | True                              |
           | id        | ca2e175b851943349be29a328cc5e360  |
           | name      | trove                             |
           +-----------+-----------------------------------+

      * Add the ``admin`` role to the ``trove`` user:

        .. code-block:: console

           $ openstack role add --project service --user trove admin

        .. note::

           This command provides no output.

      * Create the ``trove`` service entity:

        .. code-block:: console

           $ openstack service create --name trove \
             --description "Database" database
           +-------------+-----------------------------------+
           | Field       | Value                             |
           +-------------+-----------------------------------+
           | description | Database                          |
           | enabled     | True                              |
           | id          | 727841c6f5df4773baa4e8a5ae7d72eb  |
           | name        | trove                             |
           | type        | database                          |
           +-------------+-----------------------------------+


   #. Create the Database service API endpoints:

      .. code-block:: console

         $ openstack endpoint create --region regionOne \
           database public http://controller:8770/v1.0/%\(tenant_id\)s
         +--------------+----------------------------------------------+
         | Field        | Value                                        |
         +--------------+----------------------------------------------+
         | enabled      | True                                         |
         | id           | 3f4dab34624e4be7b000265f25049609             |
         | interface    | public                                       |
         | region       | regionOne                                    |
         | region_id    | regionOne                                    |
         | service_id   | 727841c6f5df4773baa4e8a5ae7d72eb             |
         | service_name | trove                                        |
         | service_type | database                                     |
         | url          | http://controller:8770/v1.0/%\(tenant_id\)s  |
         +--------------+----------------------------------------------+

         $ openstack endpoint create --region regionOne \
           database internal http://controller:8779/v1/%\(tenant_id\)s
         +--------------+----------------------------------------------+
         | Field        | Value                                        |
         +--------------+----------------------------------------------+
         | enabled      | True                                         |
         | id           | 9489f78e958e45cc85570fec7e836d98             |
         | interface    | internal                                     |
         | region       | regionOne                                    |
         | region_id    | regionOne                                    |
         | service_id   | 727841c6f5df4773baa4e8a5ae7d72eb             |
         | service_name | trove                                        |
         | service_type | database                                     |
         | url          | http://controller:8770/v1.0/%\(tenant_id\)s  |
         +--------------+----------------------------------------------+

         $ openstack endpoint create --region regionOne \
           database admin http://controller:8779/v1/%\(tenant_id\)s
         +--------------+----------------------------------------------+
         | Field        | Value                                        |
         +--------------+----------------------------------------------+
         | enabled      | True                                         |
         | id           | 76091559514b40c6b7b38dde790efe99             |
         | interface    | admin                                        |
         | region       | regionOne                                    |
         | region_id    | regionOne                                    |
         | service_id   | 727841c6f5df4773baa4e8a5ae7d72eb             |
         | service_name | trove                                        |
         | service_type | database                                     |
         | url          | http://controller:8770/v1.0/%\(tenant_id\)s  |
         +--------------+----------------------------------------------+

Install and configure components
--------------------------------

.. only:: obs or rdo or ubuntu

   .. include:: shared/note_configuration_vary_by_distribution.rst

.. only:: obs

   #. Install the packages:

      .. code-block:: console

         # zypper install openstack-trove python-troveclient

.. only:: rdo

   #. Install the packages:

      .. code-block:: console

         # yum install openstack-trove python-troveclient

.. only:: ubuntu

   #. Install the packages:

      .. code-block:: console

         # apt-get install python-trove python-troveclient \
           python-glanceclient trove-common trove-api trove-taskmanager

.. only:: obs or rdo or ubuntu

2. Edit the following configuration files, taking the below actions for
   each file:

   ``trove.conf``

   ``trove-taskmanager.conf``

   ``trove-conductor.conf``

   * Edit the ``[DEFAULT]`` section of each file and set appropriate
     values for the OpenStack service URLs, logging and messaging
     configuration, and SQL connections:

     .. code-block:: ini

        [DEFAULT]
        log_dir = /var/log/trove
        trove_auth_url = http://controller:5000/v2.0
        nova_compute_url = http://controller:8774/v2
        cinder_url = http://controller:8776/v1
        swift_url = http://controller:8080/v1/AUTH_
        connection = mysql://trove:TROVE_DBPASS@controller/trove
        notifier_queue_hostname = controller

   * Configure the Database module to use the ``RabbitMQ`` message broker
     by setting the following options in the ``[DEFAULT]`` configuration
     group of each file:

     .. code-block:: ini

        [DEFAULT]
        ...
        rpc_backend = rabbit

        [oslo_messaging_rabbit]
        ...
        rabbit_host = controller
        rabbit_userid = openstack
        rabbit_password = RABBIT_PASS

3. Verify that the ``api-paste.ini``
   file is present in ``/etc/trove``.

   If the file is not present, you can get it from this location_.

      .. _location: http://git.openstack.org/cgit/openstack/trove/plain/etc/trove/api-paste.ini?h=stable/mitaka

4. Edit the ``trove.conf`` file so it includes appropriate values for the
   settings shown below:

   .. code-block:: ini

      [DEFAULT]
      default_datastore = mysql
      ...
      # Config option for showing the IP address that nova doles out
      add_addresses = True
      network_label_regex = ^NETWORK_LABEL$
      ...
      api_paste_config = /etc/trove/api-paste.ini
      ...
      [keystone_authentication]
      admin_password = dbaas
      admin_user = trove
      admin_tenant_name = service
      auth_protocol = http
      auth_port = 35357
      auth_host = controller

   .. note::

           These authentication setings will generate a warning
           telling you that this syntax will be deprecated, and
           suggesting that you use ``[auth_plugin]``
           settings instead. However ``[auth_plugin]`` settings do
           not work with trove at this time.

5. Edit the ``trove-taskmanager.conf`` file so it includes the required
   settings to connect to the OpenStack Compute service as shown below:

   .. code-block:: ini

      [DEFAULT]
      ...
      # Configuration options for talking to nova via the novaclient.
      # These options are for an admin user in your keystone config.
      # It proxy's the token received from the user to send to nova
      # via this admin users creds,
      # basically acting like the client via that proxy token.
      nova_proxy_admin_user = admin
      nova_proxy_admin_pass = ADMIN_PASS
      nova_proxy_admin_tenant_name = service
      taskmanager_manager = trove.taskmanager.manager.Manager


6. Prepare the Database service:

   * Populate the database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage db_sync" trove

   * Create a datastore. You need to create a separate datastore for
     each type of database you want to use, for example, MySQL, MongoDB,
     Cassandra. This example shows you how to create a datastore for a
     MySQL database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage datastore_update mysql ''" trove

7. Create a trove image.

   Create an image for the type of database you want to use, for example,
   MySQL, MongoDB, Cassandra.

   This image must have the trove guest agent installed, and it must have
   the ``trove-guestagent.conf`` file configured to connect to your
   OpenStack environment.

   To do this configuration, add these
   lines to the ``trove-guestagent.conf`` file that resides on the guest
   instance you are using to build your image:

   .. code-block:: ini

      rabbit_host = controller
      rabbit_password = RABBIT_PASS
      nova_proxy_admin_user = admin
      nova_proxy_admin_pass = ADMIN_PASS
      nova_proxy_admin_tenant_name = service
      trove_auth_url = http://controller:35357/v2.0

8. Update the datastore to use the new image, using
   the ``trove-manage`` command.

   This example shows you how to create a MySQL 5.5 datastore:

   .. code-block:: console

      # trove-manage --config-file /etc/trove/trove.conf \
        datastore_version_update \
        mysql mysql-5.5 mysql glance_image_ID mysql-server-5.5 1


Finalize installation
---------------------

.. only:: ubuntu

   1. Due to a bug in the Ubuntu packages, you need to change the service
      startup scripts to use the correct configuration files.

       **Need info on how to do this**

   2. Restart the Database services:

      .. code-block:: console

         # service trove-api restart
         # service trove-taskmanager restart
         # service trove-conductor restart

.. only:: rdo or obs

   1. Start the Database services and configure them to start when
      the system boots:

      .. code-block:: console

         # systemctl enable openstack-trove-api.service \
           openstack-trove-taskmanager.service \
           openstack-trove-conductor.service

         # systemctl start openstack-trove-api.service \
           openstack-trove-taskmanager.service \
           openstack-trove-conductor.service

