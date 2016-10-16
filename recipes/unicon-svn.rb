# Create a container name after the dist+release
# svn checkout and build a fresh copy of Unicon inside
# To use you have to get lxc and chef. 
# On Ubuntu apt-get chef. More details in luxify shell scrip one level up
# Apply the recipe by running: 
# chef-apply unicon-svn.rb
#
require 'chef/lxc'

dist = 'ubuntu'	# fedora	centos
rels = 'xenial'	# 24		7	
arch = 'amd64' #i386, armhf...

# create a container
lxc dist + '-' + rels  do
  
  template 'download' do
    args ['-d', dist, '-r', rels, '-a', arch]
  end
  
  recipe do
    case node['platform_family']
    when 'debian'
      execute("apt-get update")
      package 'subversion build-essential emacs-nox htop' do
        options '--no-install-recommends'
        retries 2
      end
    else # for now assume fedora/centos family
      execute("yum update")
      execute("yum install -y make gcc subversion emacs-nox htop")
      #package 'subversion make gcc emacs-nox htop' do
      #  retries 2
      #end
    end

    directory '/opt'
    directory '/opt/unicon'
    subversion 'Unicon' do
      repository 'http://svn.code.sf.net/p/unicon/code/trunk/unicon'
      revision 'HEAD'
      destination '/opt/unicon'
      action :sync
    end

    bash 'build_unicon' do
      code <<-EOH
    export PATH=$PATH:/opt/unicon/bin
    cd /opt/unicon
    make X-Configure name=x86_64_linux
    make Unicon
    EOH
    end
    
  end # recipe
  
  action [:create, :start]
end
