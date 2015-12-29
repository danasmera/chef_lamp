#
# Cookbook Name:: lamp
# Recipe:: webserver
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# Install apache and start service
httpd_service 'customers' do
  mpm 'prefork'
  action [:create, :start]
end

# Add the stie configuration

httpd_config 'customers' do
  instance 'customers'
  source 'customers.conf.erb'
  notifies :restart, 'httpd_service[customers]'
end

#Create the document root directory
directory node['lamp']['document_root'] do
  recursive true
end

# Load the secrets file and the encrypted data bag item that holds the database password.
password_secret = Chef::EncryptedDataBagItem.load_secret(node['lamp']['passwords']['secret_path'])
user_password_data_bag_item = Chef::EncryptedDataBagItem.load('passwords', 'db_admin_password', password_secret)

# Write a default home page
template "#{node['lamp']['document_root']}/index.php" do
  source 'index.php.erb'
  mode '0644'
  owner node['lamp']['user']
  group node['lamp']['group']
  variables({
    :database_password => user_password_data_bag_item['password']
  })
end

#Open port 80 to incoming traffic
firewall_rule 'http' do
  port 80
  protocol :tcp
  action :allow
end

# Install the mod_php5 Apache module.
httpd_module 'php5' do
  instance 'customers'
end

# Install php5-mysql
package 'php5-mysql' do
  action :install
  notifies :restart, 'httpd_service[customers]'
end