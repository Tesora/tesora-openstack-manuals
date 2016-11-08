.. _cinder-storage:

Install and configure a storage node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section describes how to install and configure storage nodes
for the Block Storage service. For simplicity, this configuration
references one storage node with an empty local block storage device.
The instructions use ``/dev/sdb``, but you can substitute a different
value for your particular node.

The service provisions logical volumes on this device using the
:term:`LVM <Logical Volume Manager (LVM)>` driver and provides them
to instances via :term:`iSCSI <iSCSI Qualified Name (IQN)>` transport.
You can follow these instructions with minor modifications to horizontally
scale your environment with additional storage nodes.

Prerequisites
-------------

Before you install and configure the Block Storage service on the
storage node, you must prepare the storage device.

.. note::

   Perform these steps on the storage node.

#. Create the LVM physical volume ``/dev/sdb``:

   .. code-block:: console

      # pvcreate /dev/sdb

      Physical volume "/dev/sdb" successfully created

   .. end

#. Create the LVM volume group ``cinder-volumes``:

   .. code-block:: console

      # vgcreate cinder-volumes /dev/sdb

      Volume group "cinder-volumes" successfully created

   .. end

   The Block Storage service creates logical volumes in this volume group.

#. Only instances can access Block Storage volumes. However, the
   underlying operating system manages the devices associated with
   the volumes. By default, the LVM volume scanning tool scans the
   ``/dev`` directory for block storage devices that
   contain volumes. If projects use LVM on their volumes, the scanning
   tool detects these volumes and attempts to cache them which can cause
   a variety of problems with both the underlying operating system
   and project volumes. You must reconfigure LVM to scan only the devices
   that contain the ``cinder-volume`` volume group. Edit the
   ``/etc/lvm/lvm.conf`` file and complete the following actions:

   * In the ``devices`` section, add a filter that accepts the
     ``/dev/sdb`` device and rejects all other devices:

     .. path /etc/lvm/lvm.conf
     .. code-block:: ini

        devices {
        ...
        filter = [ "a/sdb/", "r/.*/"]

     .. end

     Each item in the filter array begins with ``a`` for **accept** or
     ``r`` for **reject** and includes a regular expression for the
     device name. The array must end with ``r/.*/`` to reject any
     remaining devices. You can use the :command:`vgs -vvvv` command
     to test filters.

     .. warning::

        If your storage nodes use LVM on the operating system disk, you
        must also add the associated device to the filter. For example,
        if the ``/dev/sda`` device contains the operating system:

        .. ignore_path /etc/lvm/lvm.conf
        .. code-block:: ini

           filter = [ "a/sda/", "a/sdb/", "r/.*/"]

        .. end

        Similarly, if your compute nodes use LVM on the operating
        system disk, you must also modify the filter in the
        ``/etc/lvm/lvm.conf`` file on those nodes to include only
        the operating system disk. For example, if the ``/dev/sda``
        device contains the operating system:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           filter = [ "a/sda/", "r/.*/"]

        .. end

Install and configure components
--------------------------------

#. Install the packages:

   .. code-block:: console

     # apt-get install cinder-volume

   .. end

   Respond to prompts for
   :doc:`database management <debconf/debconf-dbconfig-common>`,
   :doc:`Identity service credentials <debconf/debconf-keystone-authtoken>`,
   :doc:`service endpoint registration <debconf/debconf-api-endpoints>`,
   and :doc:`message broker credentials <debconf/debconf-rabbitmq>`.

2. Edit the ``/etc/cinder/cinder.conf`` file
   and complete the following actions:

   * In the ``[DEFAULT]`` section, configure the ``my_ip`` option:

     .. path /etc/cinder/cinder.conf
     .. code-block:: ini

        [DEFAULT]
        ...
        my_ip = MANAGEMENT_INTERFACE_IP_ADDRESS

     .. end

     Replace ``MANAGEMENT_INTERFACE_IP_ADDRESS`` with the IP address
     of the management network interface on your storage node,
     typically 10.0.0.41 for the first node in the
     :ref:`example architecture <overview-example-architectures>`.

   * In the ``[DEFAULT]`` section, configure the location of the
     Image service API:

     .. path /etc/cinder/cinder.conf
     .. code-block:: ini

        [DEFAULT]
        ...
        glance_api_servers = http://controller:9292

     .. end

Finalize installation
---------------------

#. Restart the Block Storage volume service including its dependencies:

   .. code-block:: console

      # service tgt restart
      # service cinder-volume restart

   .. end
