# attributes/default.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2013 Simple Finance Technology Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Attributes for InfluxDB

# By default, always installs the latest by specifying nil
default['influxdb']['version'] = nil
default['influxdb']['checksum'] = nil

# Grab clients -- right now only supports Ruby and CLI
default['influxdb']['client']['cli']['enable'] = false
default['influxdb']['client']['ruby']['enable'] = false
default['influxdb']['client']['ruby']['version'] = nil
default['influxdb']['handler']['version'] = '0.1.4'

# For influxdb versions >= 0.9.x
default['influxdb']['config_file_path'] = '/etc/opt/influxdb/influxdb.conf'

# For influxdb versions >= 0.9.x
default['influxdb']['config'] = {
  'reporting-disabled' => false,
  'meta' => {
    'dir' => '/var/opt/influxdb/meta',
    'hostname' => 'localhost',
    'bind-address' => ':8088',
    'retention-autocreate' => true,
    'election-timeout' => '1s',
    'heartbeat-timeout' => '1s',
    'leader-lease-timeout' => '500ms',
    'commit-timeout' => '50ms'
  },
  'data' => {
    'dir' => '/var/opt/influxdb/data',
    'max-wal-size' => 104_857_600,
    'wal-flush-interval' => '10m',
    'wal-partition-flush-delay' => '2s',
    'wal-dir' => '/var/opt/influxdb/wal',
    'wal-enable-logging' => true
  },
  'cluster' => {
    'shard-writer-timeout' => '5s',
    'write-timeout' => '5s'
  },
  'retention' => {
    'enabled' => true,
    'check-interval' => '30m'
  },
  'monitor' => {
    'store-enabled' => true,
    'store-database' => '_internal',
    'store-interval' => '10s'
  },
  'admin' => {
    'enabled' => true,
    'bind-address' => ':8083',
    'https-enabled' => false,
    'https-certificate' => '/etc/ssl/influxdb.pem'
  },
  'http' => {
    'enabled' => true,
    'bind-address' => ':8086',
    'auth-enabled' => false,
    'log-enabled' => true,
    'write-tracing' => false,
    'pprof-enabled' => false,
    'https-enabled' => false,
    'https-certificate' => '/etc/ssl/influxdb.pem'
  },
  'graphite' => [
    {
      'enabled' => false
    }
  ],
  'collectd' => {
    'enabled' => false
  },
  'opentsdb' => {
    'enabled' => false
  },
  'udp' => [
    {
      'enabled' => false
    }
  ],
  'continuous_queries' => {
    'log-enabled' => true,
    'enabled' => true,
    'recompute-previous-n' => 2,
    'recompute-no-older-than' => '10m',
    'compute-runs-per-interval' => 10,
    'compute-no-more-than' => '2m'
  },
  'hinted-handoff' => {
    'enabled' => true,
    'dir' => '/var/opt/influxdb/hh',
    'max-size' => 1_073_741_824,
    'max-age' => '168h',
    'retry-rate-limit' => 0,
    'retry-interval' => '1s'
  }
}

# Gem settings for the LWRPs
# Load a custom gem containing:
#  Fix show policies syntax: d929e386d4aa6203489eae47ad3e96b9b7c064cc - https://github.com/influxdb/influxdb-ruby/pull/109
#  Add alter_retention_policy(): 14595de93f1433f342ef4d03a09597df48f11feb - https://github.com/influxdb/influxdb-ruby/pull/114
# Built off https://github.com/CVTJNII/influxdb-ruby
default['influxdb']['gem']['http_source'] = 'https://github.com/CVTJNII/gemshare/raw/master/influxdb-0.2.3.gem'
