%define name keystone
%define version 12.0.0.0b2
%define release 0
%define debug_package 0

Name:           %{name}
Url:            http://www.qemu.org/
Summary:        Keystone
License:        Apache-2.0
Group:          System/Emulators/PC
Version:        %{version}
Release:        %{release}
Source0:        keystone.tar.gz
BuildRequires:  gcc
Requires:       gcc
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}
AutoReq: no

# %global __os_install_post %(echo '%{__os_install_post}' | sed -e 's!/usr/lib[^[:space:]]*/brp-python-bytecompile[[:space:]].*$!!g')
# 
# %define _binaries_in_noarch_packages_terminate_build 0
# %define _unpackaged_files_terminate_build 0
# %define __jar_repack 0


#%global __os_install_post    \
#%{nil}


%description
Keystone

%prep
rm -rf %{buildroot}
tar -xf /tmp/keystone/master/rpmbuild/SOURCES/keystone.tar.gz
wget https://github.com/openstack/keystone/archive/12.0.0.0b2.tar.gz
tar -xf 12.0.0.0b2.tar.gz

%build
virtualenv opt/keystone --system-site-packages
opt/keystone/bin/pip install -r keystone/requirements.txt

cd keystone-12.0.0.0b2
git config --global user.name "nobody"
git config --global user.email "nobody@example.com"
git init
git add .
git commit -m '12.0.0.0b2'
git tag -a 12.0.0.0b2 -m '12.0.0.0b2'
../opt/keystone/bin/python setup.py install
cd ../

find opt/keystone -name '*.pyc' | xargs rm -f || echo 'no *.pyc'
sed -i 's/\/tmp\/keystone\/master\/rpmbuild\/BUILD//g' opt/keystone/bin/* 
ls -al

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
mkdir -p %{buildroot}/etc
mkdir -p %{buildroot}/usr/lib/systemd/
cp -r opt %{buildroot}
cp -r keystone-12.0.0.0b2/etc %{buildroot}/etc/keystone
cp -r keystone/system %{buildroot}/usr/lib/systemd/system

%clean
rm -rf %{buildroot}

%files
/opt/keystone
%attr(-, root, root) /usr/lib/systemd/system/*
%dir %attr(0755, root, root) /etc/keystone
%config(noreplace) %attr(-, root, root) /etc/keystone/*

%changelog
