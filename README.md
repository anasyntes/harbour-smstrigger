# SMS Trigger (SailfishOS)

A Sailfish Silica app that:

1. Sends a pre-programmed SMS code to a pre-set phone number the moment
   you press **Send codes** — no confirmation step.
2. Automatically sends a second pre-programmed code to the same number
   after a configurable delay — no app open, no interaction of any kind.

Phone number, both codes, the delay, and the modem D-Bus path are all
editable from the Settings page (pull down on the main page → Settings).

## Building the installable RPM on GitHub (no SDK needed)

1. Create a new GitHub repository and push the contents of this folder
   to it (the `.github/workflows/build.yml` file must be included).
2. Open the repository's **Actions** tab. The "Build RPM" workflow runs
   on every push (or start it manually with "Run workflow").
3. When it finishes (first run can take 10+ minutes — it pulls a large
   Docker image), open the run and download the artifact:
   - `rpm-aarch64` for newer devices (Xperia 10 III/IV/V, …)
   - `rpm-armv7hl` for older devices (Xperia X, XA2, 10 I/II, …)
4. Optional: push a tag like `v1.0` and the RPMs are attached to a
   GitHub Release automatically.

The workflow uses the community `coderus/github-sfos-build` action. The
`RELEASE` value at the top of `build.yml` must be an existing tag of the
`coderus/sailfishos-platform-sdk` Docker image and should be close to
your phone's Sailfish version. If the build fails with "image not
found", change it to a tag listed at
https://hub.docker.com/r/coderus/sailfishos-platform-sdk/tags

I have not been able to run this workflow myself, so the first run may
need a tweak. If it fails, paste the log and the files can be fixed.

## Installing on the phone

Copy the RPM to the device, then:
```
devel-su pkcon install-local harbour-smstrigger-1.0-1.<arch>.rpm
systemctl --user daemon-reload
```
The `daemon-reload` (as the normal device user) is needed once so
systemd notices the newly installed background service.

## Architecture: why a background service

A QML `Timer` only runs while the app's process is alive, so it cannot
survive the app being closed. Instead:

- **The app** (`qml/pages/MainPage.qml`) edits settings and, when you
  press the button, asks **systemd** to start a background job.
- **A systemd user service** (`systemd/harbour-smstrigger-sender.service`)
  runs the job independent of the app's lifecycle.
- **A shell script** (`scripts/harbour-smstrigger-sender`) reads the
  saved settings, sends the first code, sleeps for the delay, sends the
  second code. Plain `/bin/sh`.

Sending goes straight to the modem via oFono
(`org.ofono.MessageManager.SendMessage`) — no Messaging app UI.

## Things I could not test — please verify on your device

None of this has been run on real hardware. Sailfish's app sandbox
(Sailjail) could block either of these calls depending on your OS
version and install method:

1. The app calling `org.freedesktop.systemd1.Manager.StartUnit` on the
   session bus.
2. The script calling `org.ofono.MessageManager.SendMessage` on the
   system bus.

Test the service on its own:
```
systemctl --user start harbour-smstrigger-sender.service
journalctl --user -t harbour-smstrigger -f
```
If that works but the app button doesn't start it, the app is being
sandboxed from systemd.

Test oFono and find your modem path:
```
dbus-send --system --print-reply --dest=org.ofono / \
  org.ofono.Manager.GetModems
```
Use the path it lists (e.g. `/ril_0`) in Settings → "Modem D-Bus path".

## Project layout

```
.github/workflows/build.yml                  GitHub Actions build for the RPM
harbour-smstrigger.pro                       qmake project file
harbour-smstrigger.desktop                   app launcher entry
src/harbour-smstrigger.cpp                   native entry point
qml/harbour-smstrigger.qml                   main window
qml/pages/MainPage.qml                       trigger button, starts the service
qml/pages/SettingsPage.qml                   number / codes / delay / modem path
qml/cover/CoverPage.qml                      app grid cover
scripts/harbour-smstrigger-sender            background script
systemd/harbour-smstrigger-sender.service    systemd user unit
rpm/harbour-smstrigger.spec                  RPM packaging spec
icons/86x86/harbour-smstrigger.png           placeholder icon
```
