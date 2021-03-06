..
  Warning: Do not edit this file. It is automatically generated and your
  changes will be overwritten. The tool to do so lives in the
  openstack-doc-tools repository.

.. list-table:: Description of configuration options for ``[object-auditor]`` in ``object-server.conf``
   :header-rows: 1
   :class: config-ref-table

   * - Configuration option = Default value
     - Description
   * - ``bytes_per_second`` = ``10000000``
     - Maximum bytes audited per second. Should be tuned according to individual system specs. 0 is unlimited. mounted to prevent accidentally writing to the root device process simultaneously (it will actually accept(2) N + 1). Setting this to one (1) will only handle one request at a time, without accepting another request concurrently. By increasing the number of workers to a much higher value, one can reduce the impact of slow file system operations in one request from negatively impacting other requests. underlying filesystem does not support it. to setup custom log handlers. bytes you'd like fallocate to reserve, whether there is space for the given file size or not. This is useful for systems that behave badly when they completely run out of space; you can make the services pretend they're out of space early. container server. For most cases, this should be
   * - ``concurrency`` = ``1``
     - Number of replication workers to spawn
   * - ``disk_chunk_size`` = ``65536``
     - Size of chunks to read/write to disk
   * - ``files_per_second`` = ``20``
     - Maximum files audited per second. Should be tuned according to individual system specs. 0 is unlimited.
   * - ``log_address`` = ``/dev/log``
     - Location where syslog sends the logs to
   * - ``log_facility`` = ``LOG_LOCAL0``
     - Syslog log facility
   * - ``log_level`` = ``INFO``
     - Logging level
   * - ``log_name`` = ``object-auditor``
     - Label used when logging
   * - ``log_time`` = ``3600``
     - Frequency of status logs in seconds.
   * - ``object_size_stats`` = `` ``
     - No help text available for this option.
   * - ``recon_cache_path`` = ``/var/cache/swift``
     - Directory where stats for a few items will be stored
   * - ``zero_byte_files_per_second`` = ``50``
     - Maximum zero byte files audited per second.
