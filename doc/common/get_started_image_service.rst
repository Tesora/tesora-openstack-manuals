=======================
OpenStack Image service
=======================

The OpenStack Image service is central to Infrastructure-as-a-Service
(IaaS) as shown in :ref:`get_started_conceptual_architecture`. It accepts API
requests for disk or server images, and metadata definitions from end users or
OpenStack Compute components. It also supports the storage of disk or server
images on various repository types, including OpenStack Object Storage.

A number of periodic processes run on the OpenStack Image service to
support caching. Replication services ensure consistency and
availability through the cluster. Other periodic processes include
auditors, updaters, and reapers.

The OpenStack Image service includes the following components:

glance-api
  Accepts Image API calls for image discovery, retrieval, and storage.

glance-registry
  Stores, processes, and retrieves metadata about images. Metadata
  includes items such as size and type.

  .. warning::

     The registry is a private internal service meant for use by
     OpenStack Image service. Do not expose this service to users.

Database
  Stores image metadata and you can choose your database depending on
  your preference. Most deployments use MySQL or SQLite.

Storage repository for image files
  Various repository types are supported including normal file
  systems, Object Storage, RADOS block devices, HTTP, and Amazon S3.
  Note that some repositories will only support read-only usage.

Metadata definition service
  A common API for vendors, admins, services, and users to meaningfully
  define their own custom metadata. This metadata can be used on
  different types of resources like images, artifacts, volumes,
  flavors, and aggregates. A definition includes the new property's key,
  description, constraints, and the resource types which it can be
  associated with.
