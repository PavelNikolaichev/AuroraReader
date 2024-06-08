// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import ru.omp.amberpdf 1.0
import ru.aurora.TinyPdfViewer 1.0
import "../controls"

Page {
    id: root

    property string filePath: ""
    property var fileHandler: null

    readonly property var statesNames: ["correctWork", "loadingDocument", "badFile", "fileNotFound"]

    Component.onCompleted: {
        loadFile(filePath)
    }

    function loadFile(path) {
        filePath = path
        determineFileType()
    }

    function determineFileType() {
        if (filePath.endsWith(".pdf")) {
            fileHandler = Qt.createComponent("PdfFileHandler.qml").createObject(root, { filePath: filePath })
        } else {
            // Handle other file types or set an error state
            root.state = root.statesNames[3]
        }
    }

    onStatusChanged: {
        if (pageStack.currentPage.objectName === objectName) {
            if (status === PageStatus.Active && state === statesNames[1]) {
                if (fileHandler) {
                    fileHandler.displayFile()
                }
            }
        }
    }

    allowedOrientations: Orientation.All
    objectName: "contentPage"
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
        z: pdfPagesView.z + 1

        Rectangle {
            id: pageHeaderBackground

            z: -1
            color: pdfPagesView.zoom > 1.0
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
                                                     : fileHandler ? fileHandler.pageCount : 0,
                                          fileInfo: fileInfo
                                      })
        }
    }

    Item {
        id: fileContent
        anchors.fill: parent
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

            onClicked: if (fileHandler && fileHandler.orientation) {
                fileHandler.orientation = fileHandler.orientation === Qt.Vertical ? Qt.Horizontal : Qt.Vertical
            }

            icon.height: Theme.iconSizeMedium
            icon.width: Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
            icon.source: fileHandler && fileHandler.orientation === ListView.Horizontal
                         ? "../images/icon-m-scroll-horizontal.svg"
                         : "../images/icon-m-scroll-vertical.svg"
        }

        MouseArea {
            id: navigationButton

            onClicked: if (fileHandler) {
                var navigationPage = pageStack.push(Qt.resolvedUrl("NavigationPage.qml"), {
                                                         count: fileHandler.pageCount,
                                                     })
                navigationPage.pageSelected.connect(function(page) { fileHandler.goToPage(page - 1) })
            }

            height: Theme.itemSizeMedium
            width: Math.min(navigationButtonLabel.width, Theme.itemSizeLarge)
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: navigationButtonLabel

                text: qsTr("%L1 | %L2").arg(fileHandler ? fileHandler.currentPage + 1 : 0).arg(fileHandler ? fileHandler.pageCount : 0)
                color: navigationButton.pressed ? palette.highlightBackgroundColor : palette.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.centerIn: parent
            }
        }
    }

    FileInfo {
        id: fileInfo

        objectName: "fileInfo"
        path: root.filePath
    }

    ShareAction {
        id: shareAction
        objectName: "shareAction"
    }

    states: [
        State {
            name: root.statesNames[0]

            PropertyChanges { target: fileContent; visible: true }
        },
        State {
            name: root.statesNames[1]

            PropertyChanges { target: fileContent; visible: false }
        },
        State {
            name: root.statesNames[2]

            PropertyChanges { target: root; filePath: "" }
            PropertyChanges { target: errorText; text: qsTr("Could not open document") }
            PropertyChanges { target: fileContent; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        },
        State {
            name: root.statesNames[3]

            PropertyChanges { target: root; filePath: "" }
            PropertyChanges { target: errorText; text: qsTr("File not found") }
            PropertyChanges { target: fileContent; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        }
    ]
}
