# recipes/default.rb
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
# Installs InfluxDB

chef_gem 'toml' do
  compile_time false if respond_to?(:compile_time)
end

# This block is a workaround to allow loading a custom gem while patches await merging into the official gem.
if node['influxdb']['gem'] && node['influxdb']['gem']['http_source']
  # Install the gem from a HTTP source repo
  # This assumes node['influxdb']['gem']['http_source'] points to a gem to avoid needing build dependencies.
  # http://stackoverflow.com/questions/19367458/installing-a-ruby-gem-from-a-github-repository-using-chef
  influxdb_gem = remote_file "#{Chef::Config[:file_cache_path]}/influxdb.gem" do
    source node['influxdb']['gem']['http_source']
    action :create_if_missing
  end
end

chef_gem 'influxdb' do
  compile_time false if respond_to?(:compile_time)
  source influxdb_gem.path unless influxdb_gem.nil?
end

# Apt repo doesn't have old releases, so install directly from a .deb if a version is specified
# https://github.com/influxdata/influxdb/issues/5913
if !platform_family?('rhel') && node['influxdb']['version']
  influxdb_deb = remote_file "#{Chef::Config[:file_cache_path]}/influxdb_#{node['influxdb']['version']}_amd64.deb" do
    source "https://influxdb.s3.amazonaws.com/influxdb_#{node['influxdb']['version']}_amd64.deb"
    checksum node['influxdb']['checksum']
    action :create_if_missing
  end

  dpkg_package 'influxdb' do
    source influxdb_deb.path
    action :install
  end
else
  if platform_family? 'rhel'
    yum_repository 'influxdb' do
      description 'InfluxDB Repository - RHEL \$releasever'
      baseurl 'https://repos.influxdata.com/centos/\$releasever/\$basearch/stable'
      gpgkey 'https://repos.influxdata.com/influxdb.key'
    end
  else
    package 'apt-transport-https'

    apt_repository 'influxdb' do
      uri "https://repos.influxdata.com/#{node['platform']}"
      distribution node['lsb']['codename']
      components ['stable']
      arch 'amd64'
      key 'https://repos.influxdata.com/influxdb.key'
    end
  end

  package 'influxdb' do
    version node['influxdb']['version']
  end
end

influxdb_config node['influxdb']['config_file_path'] do
  config node['influxdb']['config']
end

service 'influxdb' do
  action [:enable, :start]
end
