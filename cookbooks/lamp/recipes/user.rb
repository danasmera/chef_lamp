#
# Cookbook Name:: lamp
# Recipe:: user
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

group node['lamp']['group']

user node['lamp']['user'] do
  group node['lamp']['group']
  system true
  shell '/bin/bash'
end
