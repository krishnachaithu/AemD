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
aem_pub_group                         = node[:aem][:aem_pub_group]
aem_pub_user                          = node[:aem][:aem_pub_user]
aem_pub_pw                            = node[:aem][:aem_pub_pw]
aem_root_user                         = node[:aem][:aem_root_user]
aem_root_group                        = node[:aem][:aem_root_group]
aem_apps_home_pub                     = node[:aem][:aem_apps_home_pub]
aem_pub_install_path                  = node[:aem][:aem_pub_install_path]
aem_apps_jdk_home                     = node[:aem][:aem_apps_jdk_home]
java_bin_path                         = node[:aem][:java_bin_path]
aem_quickstart_jar                    = node[:aem][:aem_quickstart_jar]
aem_pub_quickstart_bin_start          = node[:aem][:aem_pub_quickstart_bin_start]
ntpdate_var                           = node[:aem][:aem_auth_ntpdate_var]
oakjar                                = node[:aem][:oakjar]
old_password                          = node[:aem][:old_adminpw]
new_password                          = node[:aem][:new_adminpw]

##########################
# Config files and Scripts
##########################
sudoers_file                  = node[:aem][:aem_sudoers_file]
author_jar_name               = node['aem']['author_jar_name']
#################
# Misc. variables
#################
java_bin_path                 = node[:aem][:java_bin_path]
aem_auth_quickstart_bin       = node[:aem][:aem_auth_quickstart_bin]
aem_quickstart_jar            = node[:aem][:aem_quickstart_jar]
aem_pub_heapsize             = node[:aem][:aem_pub_heapsize]
package_file                  = node[:aem][:aem_auth_install_path] + "/#{author_jar_name}"

##########################
# Create os user/group.
##########################
log "================================================================================="
log "======= ##### Starting installation for aem-pub ##### ========================"
log "================================================================================="
log "Creating aem publisher user"
group aem_pub_group do
  not_if "grep #{aem_pub_group}/etc/group"
  action :create
  append true
end

user aem_pub_user  do
  group "#{aem_pub_group}"
  password "#{aem_pub_pw}"
  not_if "grep #{aem_pub_user} /etc/passwd"
end

##############################
# Create install directories.
##############################
log "Creating the aem directories" 
directory "#{aem_apps_home_pub}" do
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode '0755'
  action :create
  not_if "ls -la #{aem_apps_home_pub}"
end

directory "#{aem_pub_install_path}" do
  owner "#{aem_root_user}"
  group "#{aem_root_group}"
  mode '0755'
  action :create
  not_if "ls -la #{aem_pub_install_path}"
end

#####################
# Begin install steps
#####################
remote_file "#{aem_pub_install_path}/#{node['aem']['author_jar_name']}" do
    source node[:aem][:aem_quickstart_url]
    owner aem_root_user
    group aem_root_group
    mode '0777'
    action :create
  end
execute "Changing permissions ..." do
    command "chmod 0777 #{aem_pub_install_path} -R"
   end
template "#{aem_pub_install_path}/license.properties" do
    source 'license.properties.erb'
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end
directory aem_apps_jdk_home do
    owner aem_root_user
    group aem_root_group
    mode '0755'
    recursive true
    action :create
  end 
log "Unpacking aem quickstart jar for publish in :: #{aem_pub_install_path}"
execute "unpack aem quickstart" do
    cwd aem_pub_install_path
    command "#{java_bin_path} -jar #{author_jar_name} -unpack"
    action :run
    end
directory "#{aem_pub_install_path}/crx-quickstart/install" do
        owner aem_pub_user
        group aem_pub_group
        mode '755'
        action :create
    end 
node[:aem][:aem_quickstart_array].each do |package|
    remote_file "Copy service pack.. #{package}" do
          path   "#{aem_pub_install_path}/crx-quickstart/install/#{package}"
          source "file://#{aem_pub_install_path}/#{package}"
          owner aem_pub_user
          group aem_pub_user
          mode '755'
        end
    end

##########################################
###### Modify Start Script ###############
##########################################
log "Ensure ownership of install directories is correct."

execute "change ownership of auth home" do
  command "chown -R #{aem_pub_user}:#{aem_pub_group} #{aem_apps_home_pub}"
  action :run
end
execute "Replace line in quickstart bin" do
    command "sed -i -e 's/4502/4503/g' #{aem_pub_quickstart_bin_start}"
  end
execute "Replace line in quickstart bin" do
    command "sed -i -e #{aem_pub_heapsize} #{aem_pub_quickstart_bin_start}"
  end
######################################
# Begin custom "flavor" Configurations
######################################

log "Begin custom configurations"
case node[:aem][:server_main_group]
when 'aem-dev'
  execute "Replace line in quickstart bin/start" do
    command "sed -i -e 's/author/publish,dev/g' #{aem_pub_quickstart_bin_start}"
  end
when 'aem-hqa'
  execute "Replace line in quickstart bin/start" do
    command "sed -i -e 's/author/publish,qa,nosamplecontent/g' #{aem_pub_quickstart_bin_start}"
  end
when 'aem-hint'
  execute "Replace line in quickstart bin/start" do
    command "sed -i -e 's/author/publish,int,nosamplecontent/g' #{aem_pub_quickstart_bin_start}"
  end
when 'aem-sb'
  execute "Replace line in quickstart bin/start" do
    command "sed -i -e 's/author/publish,sb/g' #{aem_pub_quickstart_bin_start}"
  end
end
#############################
# Continue base configuration
#############################
execute "aem init script" do
    command "cp #{node[:aem][:aem_scripts]}/aem-pub /etc/init.d/aem-pub"
    action :run
  end
  
log "Ensure ownership/permission of init scripts is correct."
directory "/etc/init.d/aem-pub" do
    owner node[:aem][:aem_auth_pub]
    group node[:aem][:aem_auth_pub]
    mode '0755'
    recursive true
    action :create
  end
execute "aem init script chmod" do
    command 'chmod 755 /etc/init.d/aem-pub'
    action :run
  end
execute "chown init script" do
    command "chown #{node[:aem][:aem_pub_user]}:#{node[:aem][:aem_pub_group]} /etc/init.d/aem-pub"
  end
  
execute "enable aem-pub service" do
    command "chkconfig --level 3 aem-pub on"
  end
log "Starting AEM Author......."
  execute "start aem_pub" do
   # command 'source /etc/profile.d/jdk.sh; service aem-pub start'
    command ' service aem-pub start'
    action :run
   # not_if "netstat -tupln | grep '4503'"
  end
log "Starting AEM Publisher.......It will take 5-10 min...."