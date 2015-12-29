#
# Cookbook Name:: lamp
# Recipe:: database
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

# Configure the mysql2 Ruby gem

mysql2_chef_gem 'default' do
  action :install
end

# Configure the MySQL client
mysql_client 'default' do
  action :create
end

# Load the secrets file and the encrypted data bag item that holds the 
password_secret = Chef::EncryptedDataBagItem.load_secret(node['lamp']['passwords']['secret_path'])
root_password_data_bag_item = Chef::EncryptedDataBagItem.load('passwords', 'sql_server_root_password',password_secret)

# Configure the MySQL service.
mysql_service 'default' do
  initial_root_password root_password_data_bag_item['password']
  action [:create, :start]
end

# Create the database instance
mysql_database node['lamp']['database']['dbname'] do
  connection(
    :host => node['lamp']['database']['host'],
    :username => node['lamp']['database']['username'],
    :password => root_password_data_bag_item['password']
  )
  action :create
end

#Load the encrypted data base that holds the database user's password
user_password_data_bag_item = Chef::EncryptedDataBagItem.load('passwords', 'db_admin_password', password_secret)
# Add a database user
mysql_database_user node['lamp']['database']['app']['username'] do
  connection(
    :host => node['lamp']['database']['host'],
    :username => node['lamp']['database']['username'],
    :password => root_password_data_bag_item['password']
  )
  password user_password_data_bag_item['password']
  database_name node['lamp']['database']['dbname']
  host node['lamp']['database']['host']
  action [:create, :grant]
end

# Write Schema seed file to filesystem
cookbook_file node['lamp']['database']['seed_file'] do
  source 'create-tables.sql'
  owner 'root'
  group 'root'
  mode '0600'
end

# Seed the database with a table and test data.
execute 'initialize database' do
  command "mysql -h #{node['lamp']['database']['host']} -u #{node['lamp']['database']['app']['username']} -p#{user_password_data_bag_item['password']} -D #{node['lamp']['database']['dbname']} < #{node['lamp']['database']['seed_file']}"
  not_if  "mysql -h #{node['lamp']['database']['host']} -u #{node['lamp']['database']['app']['username']} -p#{user_password_data_bag_item['password']} -D #{node['lamp']['database']['dbname']} -e 'describe customers;'"
end
