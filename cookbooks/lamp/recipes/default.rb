#
# Cookbook Name:: lamp
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'apt::default'
include_recipe 'lamp::user'
include_recipe 'firewall::default'
include_recipe 'lamp::webserver'
include_recipe 'lamp::database'
