import QtQuick 2.0
import Sailfish.Silica 1.0
import Qt.labs.settings 1.0

Page {
    id: page

    Settings {
        id: settings
        category: "SmsTrigger"
        property string phoneNumber: ""
        property string firstCode: ""
        property string secondCode: ""
        property int delayMinutes: 5
        property string modemPath: "/ril_0"
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Settings"
            }

            TextField {
                width: parent.width
                label: "Phone number"
                placeholderText: "+46701234567"
                text: settings.phoneNumber
                inputMethodHints: Qt.ImhDialableCharactersOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                onTextChanged: settings.phoneNumber = text
            }

            TextField {
                width: parent.width
                label: "First code (sent immediately)"
                text: settings.firstCode
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                onTextChanged: settings.firstCode = text
            }

            TextField {
                width: parent.width
                label: "Second code (sent after delay)"
                text: settings.secondCode
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                onTextChanged: settings.secondCode = text
            }

            TextField {
                width: parent.width
                label: "Delay before second code (minutes)"
                text: settings.delayMinutes
                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                onTextChanged: {
                    var v = parseInt(text, 10)
                    if (!isNaN(v) && v >= 0) settings.delayMinutes = v
                }
            }

            TextField {
                width: parent.width
                label: "Modem D-Bus path (advanced)"
                placeholderText: "/ril_0"
                text: settings.modemPath
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                onTextChanged: settings.modemPath = text
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2 * Theme.horizontalPageMargin
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "Values are saved automatically as you type. Only change " +
                      "the modem path if sending fails — see the README for how " +
                      "to look up the correct value for your device."
            }
        }
    }
}
