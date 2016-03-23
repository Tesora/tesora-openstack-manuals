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

#. Create a database instance_.

   .. _instance: http://docs.openstack.org/user-guide/create_db.html 
