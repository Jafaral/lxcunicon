require 'chef/lxc'

lxc 'unicon-svn' do
  template 'download' do
    args ['-d', 'ubuntu', '-r', 'xenial', '-a', 'armhf']
  end
  
  recipe do
    package 'subversion build-essential emacs-nox htop' do
      retries 5
    end
    subversion 'Unicon' do
      repository 'http://svn.code.sf.net/p/unicon/code/trunk/unicon'
      revision 'HEAD'
      destination '/opt/unicon'
      action :sync
    end
  end # recipe
  
  action [:create, :start]
end
