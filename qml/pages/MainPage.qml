import QtQuick 2.0
import Sailfish.Silica 1.0
import Qt.labs.settings 1.0
import org.nemomobile.dbus 2.0

Page {
    id: page

    // Shared, persisted settings (same category as SettingsPage.qml).
    // The background sender script reads this same file directly, so
    // whatever is saved here is exactly what gets sent.
    Settings {
        id: settings
        category: "SmsTrigger"
        property string phoneNumber: ""
        property string firstCode: ""
        property string secondCode: ""
        property int delayMinutes: 5
        property string modemPath: "/ril_0"
    }

    property string statusMessage: ""

    // Asks systemd (the OS's service manager) to start the background
    // sender as a separate process. Once started, it keeps running
    // and sleeping independently of this app — closing the app does
    // not stop it. See README for the sandboxing caveat.
    DBusInterface {
        id: systemdManager
        bus: DBusInterface.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1"
        iface: "org.freedesktop.systemd1.Manager"
    }

    function startSequence() {
        if (settings.phoneNumber.length === 0 ||
            settings.firstCode.length === 0 ||
            settings.secondCode.length === 0) {
            statusMessage = "Fill in phone number and both codes in Settings first."
            return
        }

        systemdManager.call("StartUnit",
            ["harbour-smstrigger-sender.service", "replace"],
            function() {
                statusMessage = "Started. The first code is sending now — " +
                                 "you can close the app, the second code " +
                                 "will still go out in " + settings.delayMinutes + " min."
            },
            function(error) {
                statusMessage = "Could not start background sender: " + error
            }
        )
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "SMS Trigger"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                text: "Number: " + (settings.phoneNumber.length ? settings.phoneNumber : "(not set)")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.secondaryColor
                text: "Delay before second code: " + settings.delayMinutes + " min"
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                color: Theme.highlightColor
                visible: statusMessage.length > 0
                text: statusMessage
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Send codes"
                onClicked: startSequence()
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "Runs as a background service — safe to close the app after pressing Send."
            }
        }
    }
}
