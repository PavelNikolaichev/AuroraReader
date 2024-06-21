// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import ru.aurora.TinyPdfViewer 1.0
import com.example.filereader 1.0
import "../controls"

Page {
    id: root

    property string path
    property int _maxSize: Math.max(Screen.width, Screen.height)
    readonly property var statesNames: ["correctWork", "loadingDocument", "badFile", "fileNotFound"]

    FileReader {
        id: fileReader
    }

    function checkCurrentFile() {
        fileInfo.refresh()
        if (fileInfo.isExist())
            // Implement loading properly
            state = root.statesNames[0]
            return

        state = root.statesNames[3]
    }

    onStatusChanged: {
        if (pageStack.currentPage.objectName === objectName) {
            if (status === PageStatus.Active && state === statesNames[1]) {
                textView.text = fileReader.readTextFile(path)
                console.log("TextView: ", textView.text);
                state = root.statesNames[0]
            }
        }
    }

    allowedOrientations: Orientation.All
    objectName: "txtContentPage"
    state: root.statesNames[1]

    TextArea {
        id: errorText

        width: parent.width
        visible: root.state !== root.statesNames[0]
        color: Theme.highlightColor
        readOnly: true
        horizontalAlignment: TextEdit.AlignHCenter
        font.pixelSize: Theme.fontSizeExtraLarge
        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        background: Rectangle {
            color: "transparent"
            border.color: "transparent"
        }
    }

    PageHeader {
        id: pageHeader

        title: fileInfo.fileName
        rightMargin: Theme.horizontalPageMargin + infoIcon.width + Theme.paddingSmall
        titleColor: infoIcon.highlighted ? palette.highlightColor : Theme.primaryColor
        width: root.width
        y: toolBar.open ? 0 : -height
        z: textView.z + 1

        Rectangle {
            id: pageHeaderBackground

            z: -1
            color: textView.contentY > 0
                   ? Theme.rgba(Theme.overlayBackgroundColor, Theme.opacityOverlay)
                   : "transparent"
            anchors.fill: parent

            Behavior on color { ColorAnimation { duration: toolBar.animationDuration } }
        }

        HighlightImage {
            id: infoIcon

            source: "image://theme/icon-m-about"
            highlightColor: palette.highlightColor
            highlighted: headerMouseArea.pressed
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }
        }

        Behavior on y { NumberAnimation { id: headerOpenCloseAnimation; duration: toolBar.animationDuration } }

        MouseArea {
            id: headerMouseArea

            anchors.fill: parent

            onClicked: pageStack.push(Qt.resolvedUrl("DetailsPage.qml"), {
                                          pageCount: root.state === root.statesNames[1]
                                                     ? qsTr("Loading")
                                                     : textView.length,
                                          fileInfo: fileInfo
                                      })
        }
    }

    TextArea {
        id: textView

        width: parent.width
        height: parent.height - pageHeader.height - toolBar.height
        readOnly: true
        wrapMode: TextEdit.Wrap
        anchors {
            top: pageHeader.bottom
            bottom: toolBar.top
            left: parent.left
            right: parent.right
        }

        text: "Testing asjkdljsdckvnefiwpedocvmernofiwdejaskoldcfkreijwdoasxmcvfiogejwp" +
              "Lorem ipsum dolor sit amet, consectetur adipisicing elit, " +
                      "sed do eiusmod tempor incididunt ut labore et dolore magna " +
                      "aliqua. Ut enim ad minim veniam, quis nostrud exercitation " +
                      "ullamco laboris nisi ut aliquip ex ea commodo cosnsequat. "
    }

    ToolBar {
        id: toolBar

        function trySetState(newState) {
            if (root.state !== root.statesNames[0]) {
                open = false
                return
            }

            if (open) {
                if (!newState) {
                    open = false
                    return
                }
            } else {
                if (newState) {
                    open = true
                    return
                }
            }
        }

        Component.onCompleted: trySetState(true)

        width: parent.width
        open: true

        IconButton {
            id: shareButton

            onClicked: {
                shareAction.resources = [Qt.resolvedUrl(fileInfo.path)]
                shareAction.trigger()
            }

            height: Theme.iconSizeMedium
            width: Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "image://theme/icon-m-share"
        }

        IconButton {
            id: scrollingButton

            onClicked: textView.verticalScrollBarPolicy = textView.verticalScrollBarPolicy === TextArea.ScrollBarAsNeeded ? TextArea.ScrollBarAlwaysOff : TextArea.ScrollBarAsNeeded

            icon.height: Theme.iconSizeMedium
            icon.width: Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "../images/icon-m-scroll-vertical.svg"
        }

        MouseArea {
            id: navigationButton

            onClicked: {
                var navigationPage = pageStack.push(Qt.resolvedUrl("NavigationPage.qml"), {
                                                         count: textView.length,
                                                     })
                navigationPage.pageSelected.connect(function(page) { textView.position = page - 1 })
            }

            height: Theme.itemSizeMedium
            width: Math.min(navigationButtonLabel.width, Theme.itemSizeLarge)
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: navigationButtonLabel

                text: qsTr("%L1 | %L2").arg(textView.position + 1).arg(textView.length)
                color: navigationButton.pressed ? palette.highlightBackgroundColor : palette.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.centerIn: parent
            }
        }
    }

    FileInfo {
        id: fileInfo

        objectName: "fileInfo"
        path: root.path
    }

    ShareAction {
        id: shareAction
        objectName: "shareAction"
    }

    states: [
        State {
            name: root.statesNames[0]

            PropertyChanges { target: textView; visible: true }
        },
        State {
            name: root.statesNames[1]

            PropertyChanges { target: textView; visible: false }
        },
        State {
            name: root.statesNames[2]

            PropertyChanges { target: root; path: "" }
            PropertyChanges { target: errorText; text: qsTr("Could not open document") }
            PropertyChanges { target: textView; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        },
        State {
            name: root.statesNames[3]

            PropertyChanges { target: root; path: "" }
            PropertyChanges { target: errorText; text: qsTr("File not found") }
            PropertyChanges { target: textView; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        }
    ]
}
