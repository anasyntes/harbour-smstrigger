TARGET = harbour-smstrigger

CONFIG += sailfishapp

SOURCES += src/harbour-smstrigger.cpp

OTHER_FILES += qml/harbour-smstrigger.qml \
    qml/cover/CoverPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/SettingsPage.qml \
    rpm/harbour-smstrigger.spec \
    harbour-smstrigger.desktop \
    scripts/harbour-smstrigger-sender \
    systemd/harbour-smstrigger-sender.service

# Install the app icon into the hicolor theme so it matches the
# %{_datadir}/icons/hicolor/*/apps/%{name}.png line in the .spec file.
# Replace icons/86x86/harbour-smstrigger.png with real artwork later;
# add more sizes (108x108, 128x128, 172x172) the same way if you want them.
icon86.files = icons/86x86/harbour-smstrigger.png
icon86.path = /usr/share/icons/hicolor/86x86/apps
INSTALLS += icon86
