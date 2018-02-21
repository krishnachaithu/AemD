#
# Cookbook Name:: learn_chef_httpd
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package 'httpd'

#package 'jdk'

service 'httpd' do
  action [:enable, :start]
end

group 'root'

user 'root' do
  group 'root'
  system true
  shell '/bin/bash'
end


template '/var/www/html/index.html' do # ~FC033
  source 'index.html.erb'
  mode '0644'
  owner 'root'
  group 'root'
end
=begin
directory '/home/amritFromSkytap' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/home/www' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/home/www/html' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


template '/home/www/html/index.html' do # ~FC033
  source 'index.html.erb'
end

if node['java_se']['skip']
  Chef::Log.warn('Skipping install of Java SE!')
else
  case node['platform_family']
  when 'mac_os_x'
  	puts "Installing java on not Linux machine node['platform_family'] ==> "+node['platform_family']
   # include_recipe 'java_se::_macosx_install'
  when 'windows'
  	puts "Installing java on not 2 Linux machine node['platform_family'] ==> "+node['platform_family']
   # include_recipe 'java_se::_windows_install'
  else
  	Chef::Log.warn('Skipping install of Java SE!')
  	puts "Installing java on Linux machine node['platform_family'] ==> "+node['platform_family']
   # include_recipe 'java_se::_linux_install'
  end
end
=end
