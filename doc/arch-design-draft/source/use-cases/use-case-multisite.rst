.. _multisite-cloud:

================
Multi-site cloud
================

Design Model
~~~~~~~~~~~~

Component block diagram
~~~~~~~~~~~~~~~~~~~~~~~

Stakeholder
~~~~~~~~~~~

User stories
~~~~~~~~~~~~

There are multiple ways to build a multi-site OpenStack installation,
based on the needs of the intended workloads. Below are example
architectures based on different requirements, which are not hard and
fast rules for deployment. Refer to previous sections to assist in
selecting specific components and implementations based on your needs.

A large content provider needs to deliver content to customers that are
geographically dispersed. The workload is very sensitive to latency and
needs a rapid response to end-users. After reviewing the user, technical
and operational considerations, it is determined beneficial to build a
number of regions local to the customer's edge. Rather than build a few
large, centralized data centers, the intent is to provide a pair of small
data centers in locations closer to the customer. In this use case,
spreading out applications allows for different horizontal scaling than
a traditional compute workload scale. The intent is to scale by creating
more copies of the application in closer proximity to the users that need
it most, in order to ensure faster response time to user requests. This
provider deploys two data centers at each of the four chosen regions. The
implications of this design are based on the method of placing copies
of resources in each of the remote regions. Swift objects, glance images,
and Block Storage need to be manually replicated into each region. This may
be beneficial for some systems, for example, a content service where
only some of the content needs to exist in some regions. A centralized
Identity service is recommended to manage authentication and access to
the API endpoints.

It is recommended that you install an automated DNS system such as
Designate. Application administrators need a way to manage the mapping
of which application copy exists in each region and how to reach it,
unless an external Dynamic DNS system is available. Designate assists by
making the process automatic and by populating the records in the each
region's zone.

Telemetry for each region is also deployed, as each region may grow
differently or be used at a different rate. Ceilometer collects each
region's meters from each of the controllers and reports them back to a
central location. This is useful both to the end user and the
administrator of the OpenStack environment. The end user will find this
method useful, as it makes possible to determine if certain locations
are experiencing higher load than others, and take appropriate action.
Administrators also benefit by possibly being able to forecast growth
per region, rather than expanding the capacity of all regions
simultaneously, therefore maximizing the cost-effectiveness of the
multi-site design.

One of the key decisions of running this infrastructure is whether or
not to provide a redundancy model. Two types of redundancy and high
availability models in this configuration can be implemented. The first
type is the availability of central OpenStack components. Keystone can
be made highly available in three central data centers that host the
centralized OpenStack components. This prevents a loss of any one of the
regions causing an outage in service. It also has the added benefit of
being able to run a central storage repository as a primary cache for
distributing content to each of the regions.

The second redundancy type is the edge data center itself. A second data
center in each of the edge regional locations stores a second region near
the first region. This ensures that the application does not suffer
degraded performance in terms of latency and availability.

The following figure depicts the solution designed to have both a
centralized set of core data centers for OpenStack services and paired edge
data centers.

**Multi-site architecture example**

.. figure:: ../figures/Multi-Site_Customer_Edge.png

Geo-redundant load balancing example
------------------------------------

A large-scale web application has been designed with cloud principles in
mind. The application is designed to provide service to the application
store on a 24/7 basis. The company has a two-tier architecture with
a web front-end servicing the customer requests, and a NoSQL database back
end storing the information.

Recently there has been several outages in a number of major public
cloud providers due to applications running out of a single geographical
location. The design, therefore, should mitigate the chance of a single
site causing an outage for their business.

The solution would consist of the following OpenStack components:

* A firewall, switches, and load balancers on the public facing network
  connections.

* OpenStack controller services running Networking service, dashboard, Block
  Storage service, and Compute service running locally in each of the three
  regions. Identity service, Orchestration service, Telemetry service, Image
  service and Object Storage service can be installed centrally, with
  nodes in each of the region providing a redundant OpenStack
  controller plane throughout the globe.

* OpenStack Compute nodes running the KVM hypervisor.

* OpenStack Object Storage for serving static objects such as images
  can be used to ensure that all images are standardized across all the
  regions, and replicated on a regular basis.

* A distributed DNS service available to all regions that allows for
  dynamic update of DNS records of deployed instances.

* A geo-redundant load balancing service can be used to service the
  requests from the customers based on their origin.

An autoscaling heat template can be used to deploy the application in
the three regions. This template includes:

* Web servers running Apache.

* Appropriate ``user_data`` to populate the central DNS servers upon
  instance launch.

* Appropriate Telemetry alarms that maintain the application state
  and allow for handling of region or instance failure.

Another autoscaling Heat template can be used to deploy a distributed
MongoDB shard over the three locations, with the option of storing
required data on a globally available swift container. According to the
usage and load on the database server, additional shards can be
provisioned according to the thresholds defined in Telemetry.

Two data centers would have been sufficient had the requirements been
met. But three regions are selected here to avoid abnormal load on a
single region in the event of a failure.

Orchestration is used because of the built-in functionality of
autoscaling and auto healing in the event of increased load. External
configuration management tools, such as Puppet or Chef could also have
been used in this scenario, but were not chosen since Orchestration had
the appropriate built-in hooks into the OpenStack cloud. In addition,
external tools were not needed since this deployment scenario was
straight forward.

OpenStack Object Storage is used here to serve as a back end for the
Image service since it is the most suitable solution for a globally
distributed storage solution with its own replication mechanism. Home
grown solutions could also have been used including the handling of
replication, but were not chosen, because Object Storage is already an
intricate part of the infrastructure and a proven solution.

An external load balancing service was used and not the LBaaS in
OpenStack because the solution in OpenStack is not redundant and does
not have any awareness of geo location.

**Multi-site geo-redundant architecture**

.. figure:: ../figures/Multi-site_Geo_Redundant_LB.png

Local location service example
------------------------------

A common use for multi-site OpenStack deployment is creating a Content
Delivery Network. An application that uses a local location architecture
requires low network latency and proximity to the user to provide an
optimal user experience and reduce the cost of bandwidth and transit.
The content resides on sites closer to the customer, instead of a
centralized content store that requires utilizing higher cost
cross-country links.

This architecture includes a geo-location component that places user
requests to the closest possible node. In this scenario, 100% redundancy
of content across every site is a goal rather than a requirement, with
the intent to maximize the amount of content available within a minimum
number of network hops for end users. Despite these differences, the
storage replication configuration has significant overlap with that of a
geo-redundant load balancing use case.

In the below architecture, the application utilizing this multi-site
OpenStack install that is location-aware would launch web server or content
serving instances on the compute cluster in each site. Requests from clients
are first sent to a global services load balancer that determines the location
of the client, then routes the request to the closest OpenStack site where the
application completes the request.

**Multi-site shared keystone architecture**

.. figure:: ../figures/Multi-Site_shared_keystone1.png
