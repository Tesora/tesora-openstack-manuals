.. _identity_management:

===================
Identity management
===================

OpenStack Identity, code-named keystone, is the default Identity
management system for OpenStack. After you install Identity, you
configure it through the ``/etc/keystone/keystone.conf``
configuration file and, possibly, a separate logging configuration
file. You initialize data into Identity by using the ``keystone``
command-line client.

.. toctree::
   :maxdepth: 1

   identity-concepts.rst
   identity-certificates-for-pki.rst
   identity-domain-specific-config.rst
   identity-external-authentication.rst
   identity-integrate-with-ldap.rst
   identity-tokens.rst
   identity-token-binding.rst
   identity-fernet-token-faq.rst
   identity-use-trusts.rst
   identity-caching-layer.rst
   identity-keystone-usage-and-features.rst
   identity-auth-token-middleware.rst
   identity-service-api-protection.rst
   identity-troubleshoot.rst
