%define name qemu
%define version 2.9.0
%define release 0

Name:           %{name}
Url:            http://www.qemu.org/
Summary:        Universal CPU emulator
License:        BSD-3-Clause and GPL-2.0 and GPL-2.0+ and LGPL-2.1+ and MIT
Group:          System/Emulators/PC
Version:        %{version}
Release:        %{release}

Source0:        https://github.com/openstack/keystone/archive/12.0.0.0b2.tar.gz

BuildRequires:  gcc
Requires:       gcc
BuildRoot:     %{_tmppath}/%{name}-%{version}-%{release}

%description
QEMU is an extremely well-performing CPU emulator that allows you to
choose between simulating an entire system and running userspace
binaries for different architectures under your native operating
system. It currently emulates x86, ARM, PowerPC and SPARC CPUs as well
as PC and PowerMac systems.

%prep
%setup -q
rm -rf %{buildroot}

%build
./configure --enable-pie --enable-vnc --enable-kvm --enable-rdma --enable-vde --enable-linux-aio --enable-cap-ng --enable-vhost-net --enable-libiscsi --enable-coroutine-pool --enable-tpm --enable-numa --enable-jemalloc --prefix=/usr
make -j16


%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/lib/debug
make install DESTDIR=%{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(644,root,root,755)
%attr(0755, root, root) %{_bindir}/*
%attr(0755, root, root) /usr/libexec/*
%{_datadir}/*

%changelog
