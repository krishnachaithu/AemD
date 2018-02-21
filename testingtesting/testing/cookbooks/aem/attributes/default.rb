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

default[:aem][:version]                               = "6.2"

#######################
# AEM server attributes
#######################
default[:aem][:aem_cache]                             = Chef::Config[:file_cache_path] + "/aem_install"
default[:aem][:aem_home_dir]                          = "/home/aemadm"
#default[:aem][:aem_ssh_key_path]                      = "#{node[:aem][:aem_home_dir]}/.ssh/authorized_keys"
default[:aem][:aem_root_user]                         = "root"
default[:aem][:aem_root_group]                        = "root"
default[:aem][:aem_quickstart_jar_dir]                = "/baseline/software/aem/#{node[:aem][:version]}/"
default[:aem][:aem_apps_dir]                          = "/apps"
default[:aem][:aem_quickstart_jar]                    = "#{node[:aem][:aem_apps_dir]}/aem-auth/#{node[:aem][:version]}/AEM_6.1_Quickstart.jar"
#default[:aem][:aem_apps_jdk_home]                     = "#{node[:aem][:aem_apps_dir]}/jdk"
default[:aem][:aem_apps_jdk_home]                     = "/usr/java/jdk1.8.0_161"
default[:aem][:aem_jdk_file]                          = "jdk-8u60-linux-x64.gz"
#default[:aem][:java_bin_path]                        = "#{node[:aem][:aem_apps_dir]}/jdk/jdk1.8.0_60/bin/java"
default[:aem][:java_bin_path]                         = "#{node[:aem][:java_bin_path]}/bin/java"
default[:aem][:aem_apps_apache]                       = "#{node[:aem][:aem_apps_dir]}/apache-2.4"

#default[:aem][:aem_quickstart_array_url]   = ["/install/CHEF_FILES/AEM/6.1/service_packs/AEM_6.1_Quickstart.jar",
#                                              "/install/CHEF_FILES/AEM/6.1/service_packs/license.properties",
#                                             "/install/CHEF_FILES/AEM/6.1/service_packs/AEM_6.1_Quickstart.zip"]
#default[:aem][:aem_quickstart_url]              = "file:///tmp/AEM_6.2_Quickstart.jar"
default[:aem][:aem_quickstart_url]               ="https://artifactory-bluemix.kp.org/artifactory/aem-local/org/kp/cto/aem/6.0.1-SNAPSHOT/aem-6.0.1-20180208.052002-5.jar"
# java attributes
default['java']['version'] = '8u161'
default['java']['jdk_rpm_url'] = "https://s3.amazonaws.com/java-jdk-aem/jdk-#{node['java']['version']}-linux-x64.rpm"
default['java']['jdk_rpm_name'] = "jdk-#{node['java']['version']}-linux-x64"



# aem attributes
default['aem']['author_port'] = '4502'
default['aem']['author_jar_url'] = "https://s3.amazonaws.com/java-jdk-aem/cq-author-p#{node['aem']['author_port']}.jar"
default['aem']['author_zip_name'] = "cq-author-p#{node['aem']['author_port']}.zip"
#default['aem']['author_jar_name'] = "cq-author-p#{node['aem']['author_port']}.jar"
default['aem']['author_jar_name'] = "AEM_6.2_Quickstart.jar"



default['aem']['publish_port'] = '4503'
#default['aem']['quickstart_artifactory_url'] = "https://artifactory-bluemix.kp.org/artifactory/aem-local/org/kp/cto/aem/6.0.1-SNAPSHOT/aem-6.0.1-20180208.010750-2.tar"
#default['aem']['quickstart_artifactory_url']  = "https://artifactory-bluemix.kp.org/artifactory/aem-local/org/kp/cto/aem/6.0.1-SNAPSHOT/aem-6.0.1-20180208.052002-5.jar"
default['aem']['publish_jar_name'] = "cq-publish-p#{node['aem']['publish_port']}.jar"

 


default[:aem][:server_main_group]                     = 'aem-dev'

default[:aem][:aem_quickstart_array]   = ["AEM_6.2_Quickstart.jar",
                                          "license.properties",
                                          #"acs-aem-commons-content-2.3.0.zip",
                                          #"==>AEM-6.2-Service-Pack-1-6.1.SP1.zip",
                                          #"Sun-Misc-Fragment-Bundle-1.0.0.zip",
                                          #"Grabbit-4.1.1.zip",
                                          #==>"ldap_integration-1.0.zip",
                                          #==>"cq-6.2.0-hotfix-9336-1.0.zip",
                                          #"add_developers_to_console-1.0.zip"  
                                          ]


default[:aem][:aem_scripts]                           = "#{node[:aem][:aem_cache]}/scripts"
default[:aem][:aem_baseline_home_sh_file]             = "#{node[:aem][:aem_scripts]}/0.2-baseline-home.sh"
default[:aem][:aem_baseline_home_sh_erb]              = "0_2_baseline_home_sh.erb"
default[:aem][:aem_sudoers_file]                      = "#{node[:aem][:aem_scripts]}/sudoers"
default[:aem][:aem_sudoers_erb]                       = "sudoers.erb"

# AEM Auth Variables
default[:aem][:aem_auth_user]                         = "root"
default[:aem][:aem_auth_group]                        = "root"
default[:aem][:aem_auth_userpw]                       = "VMware1!"
default[:aem][:aem_apps_home_auth]                    = "#{node[:aem][:aem_apps_dir]}/aem-auth"
default[:aem][:aem_auth_install_path]                 = "#{node[:aem][:aem_apps_home_auth]}/#{node[:aem][:version]}"
default[:aem][:aem_auth_heapsize]                     = '"s/Xmx1024m/Xmx1024m/g"'
default[:aem][:aem_auth_quickstart_bin_start]         = "#{node[:aem][:aem_auth_install_path]}/crx-quickstart/bin/start"
default[:aem][:aem_auth_ntpdate_var]                  = "172.20.204.22"
default[:aem][:aem_auth_init_script_file]             = "#{node[:aem][:aem_scripts]}/aem-auth"
default[:aem][:aem_auth_init_script_erb]              = "aem_auth.erb"

# AEM Disp Variables
default[:aem][:aem_disp_user]                         = "dispadm"
default[:aem][:aem_disp_group]                        = "dispadm"
default[:aem][:aem_disp_pw]                           = "dispadm"
default[:aem][:aem_apache_init_script_file]           = "#{node[:aem][:aem_scripts]}/aem-apache"
default[:aem][:aem_apache_init_script_erb]            = "aem_apache_init_script.erb"

# AEM Pub Variables
default[:aem][:aem_pub_group]                         = "root"
default[:aem][:aem_pub_user]                          = "root"
default[:aem][:aem_pub_pw]                            = "VMware1!"
default[:aem][:aem_apps_home_pub]                     = "#{node[:aem][:aem_apps_dir]}/aem-pub"
default[:aem][:aem_pub_install_path]                  = "#{node[:aem][:aem_apps_home_pub]}/#{node[:aem][:version]}"
default[:aem][:aem_pub_heapsize]                     = '"s/Xmx1024m/Xmx1024m/g"'
default[:aem][:aem_pub_quickstart_bin_start]          = "#{node[:aem][:aem_pub_install_path]}/crx-quickstart/bin/start"
default[:aem][:aem_pub_init_script_file]              = "#{node[:aem][:aem_scripts]}/aem-pub"
default[:aem][:aem_pub_init_script_erb]               = "aem_pub.erb"