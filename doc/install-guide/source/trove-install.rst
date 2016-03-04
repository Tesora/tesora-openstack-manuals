.. _trove-install:

Install and configure
~~~~~~~~~~~~~~~~~~~~~

This section describes how to install the Database module on the controller node.

**Prerequisites**
   
This chapter assumes that you already have a working OpenStack
environment with at least the following components installed:
Compute, Image Service, Identity.

* If you want to do backup and restore, you also need Object Storage.

* If you want to provision datastores on block-storage volumes, you also
  need Block Storage.
   
**To install the Database module on the controller:**

.. only:: ubuntu

   1. Install required packages:
      
      .. code-block:: console

         # apt-get install python-trove python-troveclient \
           python-glanceclient trove-common trove-api trove-taskmanager

.. only:: rdo

   1. Install required packages:
      
      .. code-block:: console
      
         # yum install openstack-trove python-troveclient
               
.. only:: obs

   1. Install required packages:
      
      .. code-block:: console

         # zypper install openstack-trove python-troveclient

2. Prepare OpenStack:

   * Source the ``admin-openrc.sh`` file:

     .. code-block:: console
  
        $ source ~/admin-openrc.sh         

   * Create a trove user that Compute uses to authenticate with the Identity
     service. Use the service tenant and give the user the admin role:

     .. code-block:: console

        $ keystone user-create --name trove --pass TROVE_PASS
        
        $ keystone user-role-add --user trove --tenant service --role admin

     Replace ``TROVE_PASS`` with a suitable password.

3. Edit the following configuration files, taking the below actions for
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
        sql_connection = mysql://trove:TROVE_DBPASS@controller/trove
        notifier_queue_hostname = controller

   * Configure the Database module to use the ``RabbitMQ`` message broker
     by setting the following options in the ``[DEFAULT]`` configuration
     group of each file:

     .. code-block:: ini

        [DEFAULT]
        rpc_backend = rabbit
        rabbit_host = controller
        rabbit_password = RABBIT_PASS

.. only:: rdo

   4. Get the ``api-paste.ini`` file and save it to ``/etc/trove``.
      You can get the file from this location_.

      .. _location: http://git.openstack.org/cgit/openstack/trove/plain/etc/trove/api-paste.ini?h=stable/juno

      Edit the ``[filter:authtoken]`` section of the ``api-paste.ini``
      file so it matches the listing shown below:

      .. code-block:: ini

         [filter:authtoken]
         auth_uri = http://controller:5000/v2.0
         identity_uri = http://controller:35357
         admin_user = trove
         admin_password = ADMIN_PASS
         admin_tenant_name = service
         signing_dir = /var/cache/trove

.. only:: ubuntu or obs

   4. Edit the ``[filter:authtoken]`` section of the ``api-paste.ini``
      file so it matches the listing shown below:

      .. code-block:: ini

         [filter:authtoken]
         auth_uri = http://controller:5000/v2.0
         identity_uri = http://controller:35357
         admin_user = trove
         admin_password = ADMIN_PASS
         admin_tenant_name = service
         signing_dir = /var/cache/trove

5. Edit the ``trove.conf`` file so it includes appropriate values for the
   default datastore, network label regex, and API information as shown
   below:

   .. code-block:: ini

      [DEFAULT]
      default_datastore = mysql
      ...
      # Config option for showing the IP address that nova doles out
      add_addresses = True
      network_label_regex = ^NETWORK_LABEL$
      ...
      api_paste_config = /etc/trove/api-paste.ini

6. Edit the ``trove-taskmanager.conf`` file so it includes the required
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

7. Prepare the trove admin database:

   .. code-block:: console

      $ mysql -u root -p

      mysql> CREATE DATABASE trove;

      mysql> GRANT ALL PRIVILEGES ON trove.* TO trove@'localhost' \
      IDENTIFIED BY 'TROVE_DBPASS';

      mysql> GRANT ALL PRIVILEGES ON trove.* TO trove@'%' \
      IDENTIFIED BY 'TROVE_DBPASS';

8. Prepare the Database service:

   * Initialize the database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage db_sync" trove

   * Create a datastore. You need to create a separate datastore for
     each type of database you want to use, for example, MySQL, MongoDB,
     Cassandra. This example shows you how to create a datastore for a
     MySQL database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage datastore_update mysql ''" trove

9. Create a trove image.

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

10. Update the datastore to use the new image, using
    the ``trove-manage`` command.

    This example shows you how to create a MySQL 5.5 datastore:

    .. code-block:: console

       # trove-manage --config-file /etc/trove/trove.conf \
         datastore_version_update \
         mysql mysql-5.5 mysql glance_image_ID mysql-server-5.5 1

11. You must register the Database module with the Identity service so
    that other OpenStack services can locate it. Register the service and
    specify the endpoint:

    .. code-block:: console

       $ keystone service-create --name trove --type database \
         --description "OpenStack Database Service"

       $ keystone endpoint-create \
         --service-id $(keystone service-list | awk '/ trove / {print $2}') \
         --publicurl http://controller:8779/v1.0/%\(tenant_id\)s \
         --internalurl http://controller:8779/v1.0/%\(tenant_id\)s \
         --adminurl http://controller:8779/v1.0/%\(tenant_id\)s \
         --region regionOne

.. only:: ubuntu

   12. Due to a bug in the Ubuntu packages, you need to change the service
       startup scripts to use the correct configuration files.

       **Need info on how to do this**

   13. Restart the Database services:

       .. code-block:: console

          # service trove-api restart
          # service trove-taskmanager restart
          # service trove-conductor restart

.. only:: rdo or obs

   12. Start the Database services and configure them to start when
       the system boots:

       .. code-block:: console

          # systemctl enable openstack-trove-api.service \
            openstack-trove-taskmanager.service \
            openstack-trove-conductor.service

          # systemctl start openstack-trove-api.service \
            openstack-trove-taskmanager.service \
            openstack-trove-conductor.service


