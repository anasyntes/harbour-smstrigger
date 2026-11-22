Name:       harbour-smstrigger

Summary:    Send predefined SMS codes with a delay, even after closing the app
Version:    1.0
Release:    1
Group:      Qt/Qt
License:    LICENSE
URL:        https://example.com
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   nemo-qml-plugin-dbus-qt5
Requires:   dbus
Requires:   systemd
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils

%description
Send a predefined SMS code immediately, then automatically send a second
predefined code to the same number after a configurable delay. The delay
and second send run in a background systemd user service, so they
complete even if the app has been closed. Phone number, both codes, the
delay and the modem D-Bus path are editable in Settings.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5
make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original \
  --dir %{buildroot}%{_datadir}/applications \
   %{buildroot}%{_datadir}/applications/*.desktop

install -D -m 0755 scripts/harbour-smstrigger-sender \
  %{buildroot}%{_bindir}/harbour-smstrigger-sender

install -D -m 0644 systemd/harbour-smstrigger-sender.service \
  %{buildroot}/usr/lib/systemd/user/harbour-smstrigger-sender.service

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
%attr(0755,root,root) %{_bindir}/harbour-smstrigger-sender
/usr/lib/systemd/user/harbour-smstrigger-sender.service
