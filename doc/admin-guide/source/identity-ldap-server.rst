.. _identity_ldap_server_setup:

===========================
Identity LDAP server set up
===========================

.. important::

   For the OpenStack Identity service to access LDAP servers, you must
   enable the ``authlogin_nsswitch_use_ldap`` boolean value for SELinux
   on the server running the OpenStack Identity service. To enable and
   make the option persistent across reboots, set the following boolean
   value as the root user:

   .. code-block:: console

      # setsebool -P authlogin_nsswitch_use_ldap on

The Identity configuration is split into two separate back ends; identity
(back end for users and groups), and assignments (back end for domains,
projects, roles, role assignments). To configure Identity, set options
in the ``/etc/keystone/keystone.conf`` file. See
:ref:`integrate-identity-backend-ldap` for Identity back end configuration
examples. Modify these examples as needed.

**To define the destination LDAP server**

#. Define the destination LDAP server in the
   ``/etc/keystone/keystone.conf`` file:

   .. code-block:: ini

      [ldap]
      url = ldap://localhost
      user = dc=Manager,dc=example,dc=org
      password = samplepassword
      suffix = dc=example,dc=org

**Additional LDAP integration settings**

Set these options in the ``/etc/keystone/keystone.conf`` file for a
single LDAP server, or ``/etc/keystone/domains/keystone.DOMAIN_NAME.conf``
files for multiple back ends. Example configurations appear below each
setting summary:

**Query option**

.. hlist::
   :columns: 1

   * Use ``query_scope`` to control the scope level of data presented
     (search only the first level or search an entire sub-tree)
     through LDAP.
   * Use ``page_size`` to control the maximum results per page. A value
     of zero disables paging.
   * Use ``alias_dereferencing`` to control the LDAP dereferencing
     option for queries.
   * Use ``chase_referrals`` to override the system's default referral
     chasing behavior for queries.

.. code-block:: ini

   [ldap]
   query_scope = sub
   page_size = 0
   alias_dereferencing = default
   chase_referrals =

**Debug**

Use ``debug_level`` to set the LDAP debugging level for LDAP calls.
A value of zero means that debugging is not enabled.

.. code-block:: ini

   [ldap]
   debug_level = 0

.. warning::

   This value is a bitmask, consult your LDAP documentation for
   possible values.

**Connection pooling**

Use ``use_pool`` to enable LDAP connection pooling. Configure the
connection pool size, maximum retry, reconnect trials, timeout (-1
indicates indefinite wait) and lifetime in seconds.

.. code-block:: ini

   [ldap]
   use_pool = true
   pool_size = 10
   pool_retry_max = 3
   pool_retry_delay = 0.1
   pool_connection_timeout = -1
   pool_connection_lifetime = 600

**Connection pooling for end user authentication**

Use ``use_auth_pool`` to enable LDAP connection pooling for end user
authentication. Configure the connection pool size and lifetime in
seconds.

.. code-block:: ini

   [ldap]
   use_auth_pool = false
   auth_pool_size = 100
   auth_pool_connection_lifetime = 60

When you have finished the configuration, restart the OpenStack Identity
service.

.. warning::

   During the service restart, authentication and authorization are
   unavailable.

