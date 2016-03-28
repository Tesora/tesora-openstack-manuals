.. _aodh-install:

================
Alarming service
================

This section describes how to install and configure the Telemetry Alarming
service, code-named aodh.

Prerequisites
~~~~~~~~~~~~~

Before you install and configure the Alarming service, you must create a
database, service credentials, and API endpoints.

#. To create the database, complete these steps:

   * Use the database access client to connect to
     the database server as the ``root`` user:

     .. code-block:: console

        $ mysql -u root -p

   * Create the ``aodh`` database:

     .. code-block:: console

        CREATE DATABASE aodh;

   * Grant proper access to the ``aodh`` database:

     .. code-block:: console

        GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'localhost' \
          IDENTIFIED BY 'AODH_DBPASS';
        GRANT ALL PRIVILEGES ON aodh.* TO 'aodh'@'%' \
          IDENTIFIED BY 'AODH_DBPASS';

     Replace ``AODH_DBPASS`` with a suitable password.

   * Exit the database access client.

#. Source the ``admin`` credentials to gain access to admin-only
   CLI commands:

   .. code-block:: console

      $ . admin-openrc

#. To create the service credentials, complete these steps:

   * Create the ``aodh`` user:

     .. code-block:: console

        $ openstack user create --domain default \
          --password-prompt aodh
        User Password:
        Repeat User Password:
        +-----------+----------------------------------+
        | Field     | Value                            |
        +-----------+----------------------------------+
        | domain_id | e0353a670a9e496da891347c589539e9 |
        | enabled   | True                             |
        | id        | b7657c9ea07a4556aef5d34cf70713a3 |
        | name      | aodh                             |
        +-----------+----------------------------------+

   * Add the ``admin`` role to the ``aodh`` user:

     .. code-block:: console

        $ openstack role add --project service --user aodh admin

     .. note::

        This command provides no output.

   * Create the ``aodh`` service entity:

     .. code-block:: console

        $ openstack service create --name aodh \
          --description "Telemetry" alarming
        +-------------+----------------------------------+
        | Field       | Value                            |
        +-------------+----------------------------------+
        | description | Telemetry                        |
        | enabled     | True                             |
        | id          | 3405453b14da441ebb258edfeba96d83 |
        | name        | aodh                             |
        | type        | alarming                         |
        +-------------+----------------------------------+

#. Create the Alarming service API endpoints:

   .. code-block:: console

      $ openstack endpoint create --region RegionOne \
        alarming public http://controller:8042
        +--------------+----------------------------------+
        | Field        | Value                            |
        +--------------+----------------------------------+
        | enabled      | True                             |
        | id           | 340be3625e9b4239a6415d034e98aace |
        | interface    | public                           |
        | region       | RegionOne                        |
        | region_id    | RegionOne                        |
        | service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
        | service_name | aodh                             |
        | service_type | alarming                         |
        | url          | http://controller:8042           |
        +--------------+----------------------------------+

      $ openstack endpoint create --region RegionOne \
        alarming internal http://controller:8042
        +--------------+----------------------------------+
        | Field        | Value                            |
        +--------------+----------------------------------+
        | enabled      | True                             |
        | id           | 340be3625e9b4239a6415d034e98aace |
        | interface    | internal                         |
        | region       | RegionOne                        |
        | region_id    | RegionOne                        |
        | service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
        | service_name | aodh                             |
        | service_type | alarming                         |
        | url          | http://controller:8042           |
        +--------------+----------------------------------+

      $ openstack endpoint create --region RegionOne \
        alarming admin http://controller:8042
        +--------------+----------------------------------+
        | Field        | Value                            |
        +--------------+----------------------------------+
        | enabled      | True                             |
        | id           | 340be3625e9b4239a6415d034e98aace |
        | interface    | admin                            |
        | region       | RegionOne                        |
        | region_id    | RegionOne                        |
        | service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
        | service_name | aodh                             |
        | service_type | alarming                         |
        | url          | http://controller:8042           |
        +--------------+----------------------------------+

Install and configure components
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Default configuration files vary by distribution. You might need to add
   these sections and options rather than modifying existing sections and
   options. Also, an ellipsis (...) in the configuration snippets indicates
   potential default configuration options that you should retain.

.. only:: obs

   1. Install the packages:

      .. code-block:: console

         # zypper install openstack-aodh-api \
           openstack-aodh-evaluator openstack-aodh-notifier \
           openstack-aodh-listener openstack-aodh-expirer \
           python-aodhclient

.. only:: rdo

   1. Install the packages:

      .. code-block:: console

         # yum install openstack-aodh-api \
           openstack-aodh-evaluator openstack-aodh-notifier \
           openstack-aodh-listener openstack-aodh-expirer \
           python-ceilometerclient

.. only:: ubuntu

   1. Install the packages:

      .. code-block:: console

         # apt-get install aodh-api aodh-evaluator aodh-notifier \
           aodh-listener aodh-expirer python-ceilometerclient

2. Edit the ``/etc/aodh/aodh.conf`` file and complete the following actions:

   * In the ``[database]`` section, configure database access:

     .. code-block:: ini

        [database]
        ...
        connection = mongodb://aodh:AODH_DBPASS@controller:27017/aodh

     Replace ``AODH_DBPASS`` with the password you chose for the
     Telemetry Alarming module database. You must escape special characters
     such as ':', '/', '+', and '@' in the connection string in accordance
     with `RFC2396 <https://www.ietf.org/rfc/rfc2396.txt>`_.

   * In the ``[DEFAULT]`` and ``[oslo_messaging_rabbit]`` sections,
     configure ``RabbitMQ`` message queue access:

     .. code-block:: ini

        [DEFAULT]
        ...
        rpc_backend = rabbit

        [oslo_messaging_rabbit]
        ...
        rabbit_host = controller
        rabbit_userid = openstack
        rabbit_password = RABBIT_PASS

     Replace ``RABBIT_PASS`` with the password you chose for the
     ``openstack`` account in ``RabbitMQ``.

   * In the ``[DEFAULT]`` and ``[keystone_authtoken]`` sections,
     configure Identity service access:

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
        username = aodh
        password = AODH_PASS

     Replace ``AODH_PASS`` with the password you chose for
     the ``aodh`` user in the Identity service.

   * In the ``[service_credentials]`` section, configure service credentials:

     .. code-block:: ini

        [service_credentials]
        ...
        os_auth_url = http://controller:5000/v2.0
        os_username = aodh
        os_tenant_name = service
        os_password = AODH_PASS
        interface = internalURL
        region_name = RegionOne

     Replace ``AODH_PASS`` with the password you chose for
     the ``aodh`` user in the Identity service.

   * (Optional) To assist with troubleshooting, enable verbose
     logging in the ``[DEFAULT]`` section:

     .. code-block:: ini

        [DEFAULT]
        ...
        verbose = True

.. todo:

   Workaround for https://bugs.launchpad.net/ubuntu/+source/aodh/+bug/1513599.

.. only:: ubuntu

   3. Edit the ``/etc/aodh/api_paste.ini`` file and modify the
      ``[filter:authtoken]`` section as follows:

      .. code-block:: ini

         [filter:authtoken]
         ...
         oslo_config_project = aodh

Finalize installation
~~~~~~~~~~~~~~~~~~~~~

.. only:: obs

   #. Start the Telemetry Alarming services and configure them to start
      when the system boots:

      .. code-block:: console

         # systemctl enable openstack-aodh-api.service \
           openstack-aodh-evaluator.service \
           openstack-aodh-notifier.service \
           openstack-aodh-listener.service
         # systemctl start openstack-aodh-api.service \
           openstack-aodh-evaluator.service \
           openstack-aodh-notifier.service \
           openstack-aodh-listener.service

.. only:: rdo

   * Start the Alarming services and configure them to start when the system
     boots:

     .. code-block:: console

        # systemctl enable openstack-aodh-api.service \
          openstack-aodh-evaluator.service \
          openstack-aodh-notifier.service \
          openstack-aodh-listener.service
        # systemctl start openstack-aodh-api.service \
          openstack-aodh-evaluator.service \
          openstack-aodh-notifier.service \
          openstack-aodh-listener.service

.. only:: ubuntu

   * Restart the Alarming services:

     .. code-block:: console

        # service aodh-api restart
        # service aodh-evaluator restart
        # service aodh-notifier restart
        # service aodh-listener restart
