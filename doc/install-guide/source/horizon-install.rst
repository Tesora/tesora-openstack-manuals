Install and configure
~~~~~~~~~~~~~~~~~~~~~

This section describes how to install and configure the dashboard
on the controller node.

The only core service required by the dashboard is the Identity service.
You can use the dashboard in combination with other services, such as
Image service, Compute, and Networking. You can also use the dashboard
in environments with stand-alone services such as Object Storage.

.. note::

   This section assumes proper installation, configuration, and operation
   of the Identity service using the Apache HTTP server and Memcached
   service as described in the :ref:`Install and configure the Identity
   service <keystone-install>` section.

Install and configure components
--------------------------------

.. include:: shared/note_configuration_vary_by_distribution.rst

.. only:: obs

   1. Install the packages:

      .. code-block:: console

         # zypper install openstack-dashboard

      .. end

.. endonly

.. only:: rdo

   1. Install the packages:

      .. code-block:: console

         # yum install openstack-dashboard

      .. end

.. endonly

.. only:: ubuntu

   1. Install the packages:

      .. code-block:: console

         # apt install openstack-dashboard

      .. end

.. endonly

.. only:: debian

   1. Install the packages:

      .. code-block:: console

         # apt install openstack-dashboard-apache

      .. end

   2. Respond to prompts for web server configuration.

      .. note::

         The automatic configuration process generates a self-signed
         SSL certificate. Consider obtaining an official certificate
         for production environments.

      .. note::

         There are two modes of installation. One using ``/horizon`` as the URL,
         keeping your default vhost and only adding an Alias directive: this is
         the default. The other mode will remove the default Apache vhost and install
         the dashboard on the webroot. It was the only available option
         before the Liberty release. If you prefer to set the Apache configuration
         manually,  install the ``openstack-dashboard`` package instead of
         ``openstack-dashboard-apache``.

.. endonly

.. only:: obs

   2. Configure the web server:

      .. code-block:: console

         # cp /etc/apache2/conf.d/openstack-dashboard.conf.sample \
           /etc/apache2/conf.d/openstack-dashboard.conf
         # a2enmod rewrite

      .. end

   3. Edit the
      ``/srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py``
      file and complete the following actions:

      * Configure the dashboard to use OpenStack services on the
        ``controller`` node:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_HOST = "controller"

        .. end

      * Allow all hosts to access the dashboard:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           ALLOWED_HOSTS = ['*', ]

        .. end

      * Configure the ``memcached`` session storage service:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

           CACHES = {
               'default': {
                    'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
                    'LOCATION': 'controller:11211',
               }
           }

        .. end

        .. note::

           Comment out any other session storage configuration.

      * Enable the Identity API version 3:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

        .. end

      * Enable support for domains:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

        .. end

      * Configure API versions:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_API_VERSIONS = {
               "identity": 3,
               "image": 2,
               "volume": 2,
           }

        .. end

      * Configure ``default`` as the default domain for users that you create
        via the dashboard:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"

        .. end

      * Configure ``user`` as the default role for
        users that you create via the dashboard:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

        .. end

      * If you chose networking option 1, disable support for layer-3
        networking services:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           OPENSTACK_NEUTRON_NETWORK = {
               ...
               'enable_router': False,
               'enable_quotas': False,
               'enable_distributed_router': False,
               'enable_ha_router': False,
               'enable_lb': False,
               'enable_firewall': False,
               'enable_vpn': False,
               'enable_fip_topology_check': False,
           }

        .. end

      * Optionally, configure the time zone:

        .. path /srv/www/openstack-dashboard/openstack_dashboard/local/local_settings.py
        .. code-block:: ini

           TIME_ZONE = "TIME_ZONE"

        .. end

        Replace ``TIME_ZONE`` with an appropriate time zone identifier.
        For more information, see the `list of time zones
        <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>`__.

.. endonly

.. only:: rdo

   2. Edit the
      ``/etc/openstack-dashboard/local_settings``
      file and complete the following actions:

      * Configure the dashboard to use OpenStack services on the
        ``controller`` node:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_HOST = "controller"

        .. end

      * Allow all hosts to access the dashboard:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           ALLOWED_HOSTS = ['*', ]

        .. end

      * Configure the ``memcached`` session storage service:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

           CACHES = {
               'default': {
                    'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
                    'LOCATION': 'controller:11211',
               }
           }

        .. end

        .. note::

           Comment out any other session storage configuration.

      * Enable the Identity API version 3:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

        .. end

      * Enable support for domains:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

        .. end

      * Configure API versions:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_API_VERSIONS = {
               "identity": 3,
               "image": 2,
               "volume": 2,
           }

        .. end

      * Configure ``default`` as the default domain for users that you create
        via the dashboard:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"

        .. end

      * Configure ``user`` as the default role for
        users that you create via the dashboard:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

        .. end

      * If you chose networking option 1, disable support for layer-3
        networking services:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           OPENSTACK_NEUTRON_NETWORK = {
               ...
               'enable_router': False,
               'enable_quotas': False,
               'enable_distributed_router': False,
               'enable_ha_router': False,
               'enable_lb': False,
               'enable_firewall': False,
               'enable_vpn': False,
               'enable_fip_topology_check': False,
           }

        .. end

      * Optionally, configure the time zone:

        .. path /etc/openstack-dashboard/local_settings
        .. code-block:: ini

           TIME_ZONE = "TIME_ZONE"

        .. end

        Replace ``TIME_ZONE`` with an appropriate time zone identifier.
        For more information, see the `list of time zones
        <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>`__.

.. endonly

.. only:: ubuntu or debian

   2. Edit the
      ``/etc/openstack-dashboard/local_settings.py``
      file and complete the following actions:

      * Configure the dashboard to use OpenStack services on the
        ``controller`` node:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_HOST = "controller"

        .. end

      * Allow all hosts to access the dashboard:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           ALLOWED_HOSTS = ['*', ]

        .. end

      * Configure the ``memcached`` session storage service:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

           CACHES = {
               'default': {
                    'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
                    'LOCATION': 'controller:11211',
               }
           }

        .. end

        .. note::

           Comment out any other session storage configuration.

      * Enable the Identity API version 3:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST

        .. end

      * Enable support for domains:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

        .. end

      * Configure API versions:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_API_VERSIONS = {
               "identity": 3,
               "image": 2,
               "volume": 2,
           }

        .. end

      * Configure ``default`` as the default domain for users that you create
        via the dashboard:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"

        .. end

      * Configure ``user`` as the default role for
        users that you create via the dashboard:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

        .. end

      * If you chose networking option 1, disable support for layer-3
        networking services:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           OPENSTACK_NEUTRON_NETWORK = {
               ...
               'enable_router': False,
               'enable_quotas': False,
               'enable_ipv6': False,
               'enable_distributed_router': False,
               'enable_ha_router': False,
               'enable_lb': False,
               'enable_firewall': False,
               'enable_vpn': False,
               'enable_fip_topology_check': False,
           }

        .. end

      * Optionally, configure the time zone:

        .. path /etc/openstack-dashboard/local_settings.py
        .. code-block:: ini

           TIME_ZONE = "TIME_ZONE"

        .. end

        Replace ``TIME_ZONE`` with an appropriate time zone identifier.
        For more information, see the `list of time zones
        <http://en.wikipedia.org/wiki/List_of_tz_database_time_zones>`__.

.. endonly

Finalize installation
---------------------

.. only:: ubuntu or debian

   * Reload the web server configuration:

     .. code-block:: console

        # service apache2 reload

     .. end

.. endonly

.. only:: obs

   * Restart the web server and session storage service:

     .. code-block:: console

        # systemctl restart apache2.service memcached.service

     .. end

     .. note::

        The ``systemctl restart`` command starts each service if
        not currently running.

.. endonly

.. only:: rdo

   * Restart the web server and session storage service:

     .. code-block:: console

        # systemctl restart httpd.service memcached.service

     .. end

     .. note::

        The ``systemctl restart`` command starts each service if
        not currently running.

.. endonly
