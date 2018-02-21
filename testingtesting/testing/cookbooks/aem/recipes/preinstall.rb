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

###############################
# Directories, users, and cache
###############################
aem_cache                           = node[:aem][:aem_cache]
aem_scripts                         = node[:aem][:aem_scripts]
aem_root_user                       = node[:aem][:aem_root_user]
aem_root_group                      = node[:aem][:aem_root_group]
aem_apps_dir                        = node[:aem][:aem_apps_dir]
aem_apps_jdk_home                   = node[:aem][:aem_apps_jdk_home]
#aem_apps_apache                     = node[:aem][:aem_apps_apache]

##########################
# Scripts and config files
##########################
baseline_home_sh_file               = node[:aem][:aem_baseline_home_sh_file]
baseline_home_sh_erb                = node[:aem][:aem_baseline_home_sh_erb]
sudoers_file                        = node[:aem][:aem_sudoers_file]
sudoers_erb                         = node[:aem][:aem_sudoers_erb]
ntp_conf_file                       = node[:aem][:aem_ntp_conf_file]
ntp_conf_erb                        = node[:aem][:aem_ntp_conf_erb]
nmon_init_file                      = node[:aem][:aem_nmon_init_file]
nmon_init_erb                       = node[:aem][:aem_nmon_init_erb]
nmon_logrotate_file                 = node[:aem][:aem_nmon_logrotate_file]
nmon_logrotate_erb                  = node[:aem][:aem_nmon_logrotate_erb]
splunk_install_sh_file              = node[:aem][:aem_splunk_install_sh_file]
splunk_install_sh_erb               = node[:aem][:aem_splunk_install_sh_erb]
aem_httpd_conf_file                 = node[:aem][:aem_httpd_conf_file]
aem_httpd_conf_erb                  = node[:aem][:aem_httpd_conf_erb]
aem_httpd_conf_ssl_file             = node[:aem][:aem_httpd_conf_ssl_file]
aem_httpd_conf_ssl_erb              = node[:aem][:aem_httpd_conf_ssl_erb]

##############################
# Create worldwide directories
##############################

log "Creating global directories"
directory "Ensure Chef Cache Exists" do
  path Chef::Config[:file_cache_path]
  mode 00755
  action :create
end 

log "creating aem directory"
directory "#{aem_cache}" do
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode  '0755'
  action :create
  recursive true
end

directory "#{aem_scripts}" do
    owner "#{aem_root_user}"
    group "#{aem_root_group}"
    mode '0755'
    action :create
  end

directory "#{aem_apps_dir}" do
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode '0755'
  action :create
  not_if "ls -la #{aem_apps_dir}"
end
########################Just for test kitchen
directory "/usr/java" do
    owner "#{aem_root_user}"
    group "#{aem_root_group}"
    mode '0755'
    action :create
    not_if "ls -la #{aem_apps_jdk_home}"
  end
######################## end just for test kitchen
directory "#{aem_apps_jdk_home}" do
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode '0755'
  action :create
  not_if "ls -la #{aem_apps_jdk_home}"
end

###############################
# Move templates to directories
###############################

log "Begin moving install/setup scripts to cache"
template "#{sudoers_file}" do
  source "#{sudoers_erb}"
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode '0440'
  action :create
end

template node[:aem][:aem_auth_init_script_file] do
    source node[:aem][:aem_auth_init_script_erb]
    owner "root"
    group "root"
    mode '0644'
    action :create
  end
  
  template node[:aem][:aem_apache_init_script_file] do
    source node[:aem][:aem_apache_init_script_erb]
    owner "root"
    group "root"
    mode '0644'
    action :create
  end
  
  template node[:aem][:aem_pub_init_script_file] do
    source node[:aem][:aem_pub_init_script_erb]
    owner "root"
    group "root"
    mode '0644'
    action :create
  end

