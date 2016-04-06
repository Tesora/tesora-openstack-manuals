.. _trove-verify:

Verify operation
~~~~~~~~~~~~~~~~

Verify operation of the Database service.

.. note::

   Perform these commands on the controller node.

#. Source the ``admin`` tenant credentials:

   .. code-block:: console

      $ source admin-openrc.sh

#. Run the ``trove list`` command. You should see output similar to this:

   .. code-block:: console

      # trove list
        +----+------+-----------+-------------------+--------+-----------+------+
        | id | name | datastore | datastore_version | status | flavor_id | size |
        +----+------+-----------+-------------------+--------+-----------+------+
        +----+------+-----------+-------------------+--------+-----------+------+

#. Prepare the Database service:

   * Populate the database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage db_sync" trove

   * Create a datastore. You need to create a separate datastore for
     each type of database you want to use, for example, MySQL, MongoDB,
     Cassandra. This example shows you how to create a datastore for a
     MySQL database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage datastore_update mysql ''" trove

#. `Create a trove image <http://docs.openstack.org/developer/trove/dev/building_guest_images.html>`_.

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

#. Update the datastore to use the new image, using
   the ``trove-manage`` command.

   This example shows you how to create a MySQL 5.5 datastore:

   .. code-block:: console

      # trove-manage --config-file /etc/trove/trove.conf \
        datastore_version_update \
        mysql mysql-5.5 mysql glance_image_ID mysql-server-5.5 1



#. Create a database instance_.

   .. _instance: http://docs.openstack.org/user-guide/create_db.html
