Networking Option 1: Provider networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Configure the Networking components on a *compute* node.

Configure the Linux bridge agent
--------------------------------

The Linux bridge agent builds layer-2 (bridging and switching) virtual
networking infrastructure for instances and handles security groups.

* Edit the ``/etc/neutron/plugins/ml2/linuxbridge_agent.ini`` file and
  complete the following actions:

  * In the ``[linux_bridge]`` section, map the provider virtual network to the
    provider physical network interface:

    .. path /etc/neutron/plugins/ml2/linuxbridge_agent.ini
    .. code-block:: ini

       [linux_bridge]
       physical_interface_mappings = provider:PROVIDER_INTERFACE_NAME

    .. end

    Replace ``PROVIDER_INTERFACE_NAME`` with the name of the underlying
    provider physical network interface. See :ref:`environment-networking`
    for more information.

  * In the ``[vxlan]`` section, disable VXLAN overlay networks:

    .. path /etc/neutron/plugins/ml2/linuxbridge_agent.ini
    .. code-block:: ini

       [vxlan]
       enable_vxlan = False

    .. end

  * In the ``[securitygroup]`` section, enable security groups and
    configure the Linux bridge :term:`iptables` firewall driver:

    .. path /etc/neutron/plugins/ml2/linuxbridge_agent.ini
    .. code-block:: ini

       [securitygroup]
       ...
       enable_security_group = True
       firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

    .. end

Return to
:ref:`Networking compute node configuration <neutron-compute-compute>`.
