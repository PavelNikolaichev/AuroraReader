// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.aurora.TinyPdfViewer 1.0

Page {
    id: root

    property int count: -1

    signal pageSelected(int s)

    allowedOrientations: Orientation.All
    objectName: "navigationPage"

    PageHeader {
        objectName: "pageHeader"
        title: qsTr("Document navigation")
    }

    SilicaFlickable {
        objectName: "pageInputBlock"
        anchors {
            bottom: root.bottom
            left: parent.left
            right: parent.right
        }
        height: blockHeader.height + textField.height + Theme.paddingLarge + Theme.paddingMedium

        Rectangle {
            objectName: "background"
            anchors.fill: parent
            color: "black"
            opacity: 0.4
        }

        SectionHeader {
            id: blockHeader

            objectName: "blockHeader"
            text: qsTr("Go to page")
        }

        TextField {
            id: textField

            EnterKey.onClicked: {
                pageSelected(text)
                pageStack.pop()
            }

            objectName: "textField"
            placeholderText: qsTr("Enter page number")
            inputMethodHints: Qt.ImhDigitsOnly
            validator: IntValidator { top: root.count; bottom: 1 }
            errorHighlight: !acceptableInput && text.length !== 0
            font.pixelSize: Theme.fontSizeLarge
            EnterKey.enabled: acceptableInput
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.highlighted: acceptableInput
            anchors {
                top: blockHeader.bottom
                left: parent.left
                right: parent.right
            }

            labelComponent: Column {
                objectName: "labelColumn"
                width: parent.width

                Label {
                    objectName: "pageNumberLabel"
                    width: parent.width
                    text: qsTr("Page number")
                    opacity: textField.length > 0 ? 1.0 : 0.0
                    height: contentHeight * opacity
                    font.pixelSize: Theme.fontSizeSmall

                    Behavior on opacity { FadeAnimation { } }
                }

                Label {
                    objectName: "countLabel"
                    width: parent.width
                    text: qsTr("Document has %n page(s)", "", root.count)
                    color: palette.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }
            }
        }
    }
}
