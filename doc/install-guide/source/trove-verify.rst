.. _trove-verify:

Verify operation
~~~~~~~~~~~~~~~~

Verify operation of the Database service.

.. note::

   Perform these commands on the node where you installed trove.

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

#. Add a datastore to trove:

   * `Create a trove image <http://docs.openstack.org/developer/trove/dev/building_guest_images.html>`_.
      Create an image for the type of database you want to use, for example,
      MySQL, MongoDB, Cassandra.

      This image must have the trove guest agent installed.

   * Create a datastore. You need to create a separate datastore for
     each type of database you want to use, for example, MySQL, MongoDB,
     Cassandra. This example shows you how to create a datastore for a
     MySQL database:

     .. code-block:: console

        # su -s /bin/sh -c "trove-manage datastore_update mysql ''" trove

#. Update the datastore to use the new image, using
   the ``trove-manage`` command.

   This example shows you how to create a MySQL 5.6 datastore:

   .. code-block:: console

      # trove-manage --config-file /etc/trove/trove.conf \
        datastore_version_update \
        mysql mysql-5.6 mysql glance_image_ID "" 1


#. Create a database instance_.

   .. _instance: http://docs.openstack.org/user-guide/create_db.html
