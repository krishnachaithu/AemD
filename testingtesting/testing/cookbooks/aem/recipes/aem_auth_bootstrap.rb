# Author: Amrit Raj ( <amrit.raj@kp.org> )
# Date  : 11-Jan-2016
#
# Description : Attributes for AEM
#
# Version: 1.0.0
#******************************************************************************
# Change Log :
#
# Developer       Date     Description
# ------------   -------   -------------------------------------------------
# Amrit Raj      01/25/18  Creation
# 
#
#******************************************************************************

############
# attributes
############

#######################
# Directories and users
#######################
aem_auth_user                 = node[:aem][:aem_auth_user]
aem_auth_group                = node[:aem][:aem_auth_group]
aem_auth_pw                   = node[:aem][:aem_auth_userpw]
aem_root_user                 = node[:aem][:aem_root_user]
aem_root_group                = node[:aem][:aem_root_group]
aem_apps_home_auth            = node[:aem][:aem_apps_home_auth]
aem_auth_install_path         = node[:aem][:aem_auth_install_path]
aem_apps_jdk_home             = node[:aem][:aem_apps_jdk_home]

##########################
# Config files and Scripts
##########################
sudoers_file                  = node[:aem][:aem_sudoers_file]
author_jar_name               = node['aem']['author_jar_name']


#################
# Misc. variables
#################
java_bin_path                 = node[:aem][:java_bin_path]
aem_auth_quickstart_bin_start       = node[:aem][:aem_auth_quickstart_bin_start]
aem_quickstart_jar            = node[:aem][:aem_quickstart_jar]
aem_auth_heapsize             = node[:aem][:aem_auth_heapsize]
package_file                  = node[:aem][:aem_auth_install_path] + "/#{author_jar_name}"

##########################
# Create os user/group. 
##########################
log "=============================================================================="
log "=========##### Starting installation for aem-auth ##### ======================="
log "=============================================================================="
log "Begin creating auth user/group"
group aem_auth_group do
  not_if "grep #{aem_auth_group} /etc/group"
  action :create
  append true
end
  
user aem_auth_user  do
  group aem_auth_group
  password aem_auth_pw
  not_if "grep #{aem_auth_user} /etc/passwd"
end
###########################################################################################
##### for test kitchen only AEM DEMO
###########################################################################################
#                ##### 1. Install Java ########
################################################
log "Current Platform :: #{node['platform_family']}"
case node['platform_family']
  when 'debian', 'rhel', 'centos-7', 'amazon'
    remote_file "/tmp/#{node['java']['jdk_rpm_name']}.rpm" do
    source node['java']['jdk_rpm_url']
    action :create_if_missing
  end
    rpm_package "/tmp/#{node['java']['jdk_rpm_name']}.rpm"
  else
    raise "#{node['platform_family']} is not supported!"
end
#                ##### End Install Java #######
=begin
remote_file "/tmp/#{node['aem']['author_jar_name']}" do
  source node['aem']['author_jar_url']
  action :create_if_missing
end
=end
###########################################################################################
##### End for test kitchen only
###########################################################################################
#############################
# Create install directories.
#############################
log "Begin creating install directories"
directory aem_apps_home_auth do
  owner aem_root_user
  group aem_root_group
  mode '0755'
  action :create
  not_if "ls -la #{aem_apps_home_auth}"
end

directory aem_auth_install_path do 
  owner aem_root_user
  group aem_root_group
  mode '0755'
  action :create
  not_if "ls -la #{aem_auth_install_path}"
end

##############################################
# Download archive files for Author quickstart
##############################################
  
remote_file "#{aem_auth_install_path}/#{node['aem']['author_jar_name']}" do
  source node[:aem][:aem_quickstart_url]
  owner aem_root_user
  group aem_root_group
  mode '0755'
  action :create
end
template "#{aem_auth_install_path}/license.properties" do
  source 'license.properties.erb'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end
 

log "Unpacking aem quickstart jar for author in:: #{aem_auth_install_path}"
execute "unpack aem quickstart" do
  cwd aem_auth_install_path
  command "#{java_bin_path} -jar #{author_jar_name} -unpack"
  action :run
  end

#log "Starting instance to create quickstart.properties"
#execute "unpack aem quickstart" do
#  cwd aem_auth_install_path
#  command "#{java_bin_path} -jar #{author_jar_name} -r publish"
# action :run
#end

directory "#{aem_auth_install_path}/crx-quickstart/install" do
  owner aem_auth_user
  group aem_auth_group
  mode '755'
  action :create
end

node[:aem][:aem_quickstart_array].each do |package|
  remote_file "Copy service pack.. #{package}" do
    path   "#{aem_auth_install_path}/crx-quickstart/install/#{package}"
    source "file://#{aem_auth_install_path}/#{package}"
    owner aem_auth_user
    group aem_auth_group
    mode '755'
  end
end

log "Ensure ownership of install directories is correct."

execute "change ownership of auth home" do
  command "chown -R #{aem_auth_user}:#{aem_auth_group} #{aem_apps_home_auth}"
  action :run
end

###################################################
# Case statement for "flavor" configuration changes
###################################################
case node[:aem][:server_main_group]
when 'aem-dev'
 execute "change group name" do
   command "sed -i -e 's/author/author,dev/g' #{aem_auth_quickstart_bin_start}"
  end
when 'aem-hqa'
  execute "Change group name" do
    command "sed -i -e 's/author/author,qa,nosamplecontent/g' #{aem_auth_quickstart_bin_start}"
  end
when 'aem-hint'
  execute "Change group name" do
    command "sed -i -e 's/author/author,int,nosamplecontent/g' #{aem_auth_quickstart_bin_start}"
  end
when 'aem-sb'
  execute "Change group name" do
    command "sed -i -e 's/author/author,sb/g' #{aem_auth_quickstart_bin_start}"
  end
end

#################################
# Continue base AEM configuration
#################################

execute "increase heapsize" do
  command "sed -i -e #{aem_auth_heapsize} #{aem_auth_quickstart_bin_start}"
  action :run
end
file '/etc/init.d/aem-auth' do
  action :delete
  only_if {File.exist? '/etc/init.d/aem-auth'}
 end
execute "aem init script" do
  command "cp #{node[:aem][:aem_scripts]}/aem-auth /etc/init.d/aem-auth"
  action :run
end

log "Ensure ownership/permission of init scripts is correct."
directory "/etc/init.d/aem-auth" do
  owner node[:aem][:aem_auth_user]
  group node[:aem][:aem_auth_group]
  mode '0755'
  recursive true
  action :create
end

execute "aem auth init script chmod" do
  command 'chmod 755 /etc/init.d/aem-auth'
  action :run
end

execute "chown init script" do
  command "chown #{node[:aem][:aem_auth_user]}:#{node[:aem][:aem_auth_group]} /etc/init.d/aem-auth"
end

execute "enable aem-auth service" do
  command "chkconfig --level 3 aem-auth on"
end

log "Starting AEM Author......."
execute "start aem_auth" do
 # command 'source /etc/profile.d/jdk.sh; service aem-auth start'
  command ' service aem-auth start'
  action :run
 # not_if "netstat -tupln | grep '4502'"
end

execute "copy sudoers to etc" do
  command "cp #{sudoers_file} /etc"
  action :run
end