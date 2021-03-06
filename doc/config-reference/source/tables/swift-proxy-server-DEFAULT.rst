..
  Warning: Do not edit this file. It is automatically generated and your
  changes will be overwritten. The tool to do so lives in the
  openstack-doc-tools repository.

.. list-table:: Description of configuration options for ``[DEFAULT]`` in ``proxy-server.conf``
   :header-rows: 1
   :class: config-ref-table

   * - Configuration option = Default value
     - Description
   * - ``admin_key`` = ``secret_admin_key``
     - to use for admin calls that are HMAC signed. Default is empty, which will disable admin calls to /info. the proxy server. For most cases, this should be
   * - ``backlog`` = ``4096``
     - Maximum number of allowed pending TCP connections
   * - ``bind_ip`` = ``0.0.0.0``
     - IP Address for server to bind to
   * - ``bind_port`` = ``8080``
     - Port for server to bind to
   * - ``bind_timeout`` = ``30``
     - Seconds to attempt bind before giving up
   * - ``cert_file`` = ``/etc/swift/proxy.crt``
     - to the ssl .crt. This should be enabled for testing purposes only.
   * - ``client_timeout`` = ``60``
     - Timeout to read one chunk from a client external services
   * - ``cors_allow_origin`` = `` ``
     - is a list of hosts that are included with any CORS request by default and returned with the Access-Control-Allow-Origin header in addition to what the container has set. to call to setup custom log handlers. for eventlet the proxy server. For most cases, this should be
   * - ``disallowed_sections`` = ``swift.valid_api_versions, container_quotas, tempurl``
     - No help text available for this option.
   * - ``eventlet_debug`` = ``false``
     - If true, turn on debug logging for eventlet
   * - ``expiring_objects_account_name`` = ``expiring_objects``
     - No help text available for this option.
   * - ``expiring_objects_container_divisor`` = ``86400``
     - No help text available for this option.
   * - ``expose_info`` = ``true``
     - Enables exposing configuration settings via HTTP GET /info.
   * - ``key_file`` = ``/etc/swift/proxy.key``
     - to the ssl .key. This should be enabled for testing purposes only.
   * - ``log_address`` = ``/dev/log``
     - Location where syslog sends the logs to
   * - ``log_custom_handlers`` = `` ``
     - Comma-separated list of functions to call to setup custom log handlers.
   * - ``log_facility`` = ``LOG_LOCAL0``
     - Syslog log facility
   * - ``log_headers`` = ``false``
     - No help text available for this option.
   * - ``log_level`` = ``INFO``
     - Logging level
   * - ``log_max_line_length`` = ``0``
     - Caps the length of log lines to the value given; no limit if set to 0, the default.
   * - ``log_name`` = ``swift``
     - Label used when logging
   * - ``log_statsd_default_sample_rate`` = ``1.0``
     - Defines the probability of sending a sample for any given event or timing measurement.
   * - ``log_statsd_host`` = ``localhost``
     - If not set, the StatsD feature is disabled.
   * - ``log_statsd_metric_prefix`` = `` ``
     - Value will be prepended to every metric sent to the StatsD server.
   * - ``log_statsd_port`` = ``8125``
     - Port value for the StatsD server.
   * - ``log_statsd_sample_rate_factor`` = ``1.0``
     - Not recommended to set this to a value less than 1.0, if frequency of logging is too high, tune the log_statsd_default_sample_rate instead.
   * - ``log_udp_host`` = `` ``
     - If not set, the UDP receiver for syslog is disabled.
   * - ``log_udp_port`` = ``514``
     - Port value for UDP receiver, if enabled.
   * - ``max_clients`` = ``1024``
     - Maximum number of clients one worker can process simultaneously Lowering the number of clients handled per worker, and raising the number of workers can lessen the impact that a CPU intensive, or blocking, request can have on other requests served by the same worker. If the maximum number of clients is set to one, then a given worker will not perform another call while processing, allowing other workers a chance to process it.
   * - ``strict_cors_mode`` = ``True``
     - No help text available for this option.
   * - ``swift_dir`` = ``/etc/swift``
     - Swift configuration directory
   * - ``trans_id_suffix`` = `` ``
     - No help text available for this option.
   * - ``user`` = ``swift``
     - User to run as
   * - ``workers`` = ``auto``
     - a much higher value, one can reduce the impact of slow file system operations in one request from negatively impacting other requests.
