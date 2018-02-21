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
aem_auth_quickstart_bin_start = node[:aem][:aem_auth_quickstart_bin_start]
aem_quickstart_jar            = node[:aem][:aem_quickstart_jar]
aem_auth_heapsize             = node[:aem][:aem_auth_heapsize]
package_file                  = node[:aem][:aem_auth_install_path] + "/#{author_jar_name}"

##########################
# Create os user/group. 
##########################
log "=============================================================================="
log "=========##### Starting installation for aem-auth ##### ======================="
log "=============================================================================="
log "Installing HTTPD....................."
package 'httpd'

log "Starting HTTPD Service....................."
service 'httpd' do
    action [:enable, :start]
  end

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

log "===============================Artifactory======================================="
remote_file "/apps/temp/AEM_6.2_Quickstart.jar" do
  source node['aem']['aem_quickstart_url']
  action :create_if_missing
end

=begin
execute "untar" do
    cwd '/apps/temp'
    command "tar -xf AEM_6.2_Quickstart.tar"
    action :run
  end
  execute "untar" do
    cwd '/apps/temp'
    command "rm -rf AEM_6.2_Quickstart.tar"
    action :run
  end
=end
log "===============================End Artifactory======================================="

