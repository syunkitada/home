Name:          vde2
Version:       2.3.2
Release:       1mamba
Summary:       An ethernet compliant virtual network that can be spawned over a set of physical computer over the Internet
Group:         Network/Routing
Vendor:        openmamba
Distribution:  openmamba
Packager:      Silvan Calarco <silvan.calarco@...>
URL:           http://vde.sourceforge.net/
Source:        http://downloads.sourceforge.net/project/vde/vde2/%{version}/vde2-%{version}.tar.gz
License:       GPL
## AUTOBUILDREQ-BEGIN
BuildRequires: glibc-devel
BuildRequires: openssl-devel
BuildRequires: libpcap-devel
## AUTOBUILDREQ-END
BuildRoot:     %{_tmppath}/%{name}-%{version}-root

%description
VDE is an ethernet compliant virtual network that can be spawned over a set of physical computer over the Internet. VDE is part of virtualsquare  project.

%package devel
Summary:       Devel package for %{name}
Group:         Development/Libraries
Requires:      %{name} = %{?epoch:%epoch:}%{version}-%{release}

%description devel
VDE is an ethernet compliant virtual network that can be spawned over a set of physical computer over the Internet. VDE is part of virtualsquare  project.

This package contains static libraries and header files need for development.

%prep
%setup -q

%build
%configure
make -j1 V=1

%install
[ "%{buildroot}" != / ] && rm -rf "%{buildroot}"
%makeinstall

%clean
[ "%{buildroot}" != / ] && rm -rf "%{buildroot}"

%files
%defattr(-,root,root)
%config %{_sysconfdir}/vde2/libvdemgmt/*.rc
%{_sysconfdir}/vde2/vdecmd
%{_bindir}/*
%{_sbindir}/vde_tunctl
%{_libdir}/lib*.so.*
%{_libdir}/vde2
%{_libexecdir}/vdetap
%{python_sitelib}/VdePlug.py
%{python_sitelib}/VdePlug.pyc
%{python_sitelib}/VdePlug.pyo
%{python_sitelib}/vdeplug_python.la
%{python_sitelib}/vdeplug_python.so
%{_mandir}/man1/*.1.gz
%{_mandir}/man8/vde_tunctl.8.gz
%doc COPYING

%files devel
%defattr(-,root,root)
%dir %{_includedir}
%{_includedir}/*.h
%{_libdir}/lib*.a
%{_libdir}/lib*.la
%{_libdir}/lib*.so
%{_libdir}/pkgconfig/*.pc
%doc README

%changelog
* Thu Jan 10 2013 Automatic Build System <autodist@...> 2.3.2-1mamba
- automatic version update by autodist

* Mon Jun 21 2010 Silvan Calarco <silvan.calarco@...> 2.2.3-1mamba
- package created by autospec
