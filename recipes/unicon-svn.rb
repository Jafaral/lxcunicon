# Create a container called unicon-svn
# svn checkout and build a fresh copy of Unicon inside
# To use you have to get lxc and chef. 
# On Ubuntu apt-get chef. More details in luxify shell scrip one level up
# Apply the recipe by running: 
# chef-apply unicon-svn.rb
#
require 'chef/lxc'

lxc 'unicon-svn' do
  template 'download' do
    args ['-d', 'ubuntu', '-r', 'xenial', '-a', 'amd64']
  end
  
  recipe do
    execute("apt-get update")
    package 'subversion build-essential emacs-nox htop' do
      retries 5
    end
    
    directory '/opt/unicon'
    subversion 'Unicon' do
      repository 'http://svn.code.sf.net/p/unicon/code/trunk/unicon'
      revision 'HEAD'
      destination '/opt/unicon'
      action :sync
    end

    bash 'build_unicon' do
      code <<-EOH
    cd /opt/unicon
    make X-Configure name=x86_64_linux
    make Unicon
    EOH
    end
    
  end # recipe
  
  action [:create, :start]
end
