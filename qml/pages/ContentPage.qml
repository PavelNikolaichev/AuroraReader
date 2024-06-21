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

    property string path
    property int _maxSize: Math.max(Screen.width, Screen.height)
    readonly property var statesNames: ["correctWork", "loadingDocument", "badFile", "fileNotFound"]

    function checkCurrentFile() {
        fileInfo.refresh()
        if (fileInfo.isExist())
            return

        state = root.statesNames[3]
    }

    onStatusChanged: {
        if (pageStack.currentPage.objectName === objectName) {
            if (status === PageStatus.Active && state === statesNames[1]) {
                pdfPagesView.pdfPath = path
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
                                                     : pdfPagesView.count,
                                          fileInfo: fileInfo
                                      })
        }
    }

    PdfView {
        id: pdfPagesView

        property var previousStatus: PdfDocument.Null

        onClicked: toolBar.trySetState(!toolBar.open)
        onCountChanged: {
            if (count < 0)
                return

            if (pageStack.currentPage.objectName === "aboutFilePage")
                pageStack.currentPage.pageCount = pdfView.count
        }
        onStatusChanged: {
            if (previousStatus === status)
                return

            switch(previousStatus) {
            case PdfDocument.Null:
                root.state = (status === PdfDocument.Loading ? root.statesNames[1] : root.statesNames[2])
                break
            case PdfDocument.Loading:
                root.state = (status === PdfDocument.Ready ? root.statesNames[0] : root.statesNames[2])
                toolBar.trySetState(true)
                break
            case PdfDocument.Ready:
                root.state = root.statesNames[3]
                previousStatus = PdfDocument.Error
                break
            }

            if (previousStatus !== PdfDocument.Error)
                previousStatus = status
        }
        onNoteActivate: pageStack.push(Qt.resolvedUrl("NotePage.qml"), { noteText: noteText, author: author })
        onClickedUrl: Qt.openUrlExternally(url)

        objectName: "pdfView"
        anchors {
            top: pageHeader.bottom
            bottom: toolBar.top
            right: parent.right
            left: parent.left
        }
        documentProvider: pdfiumProvider
        clip: true
        annotationsPaint: true
        notesPaint: true
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

            onClicked: pdfPagesView.orientation = pdfPagesView.orientation === Qt.Vertical ? Qt.Horizontal : Qt.Vertical

            icon.height: Theme.iconSizeMedium
            icon.width: Theme.iconSizeMedium
            anchors.verticalCenter: parent.verticalCenter
            icon.source: pdfPagesView.orientation === ListView.Horizontal
                         ? "../images/icon-m-scroll-horizontal.svg"
                         : "../images/icon-m-scroll-vertical.svg"
        }

        MouseArea {
            id: navigationButton

            onClicked: {
                 var navigationPage = pageStack.push(Qt.resolvedUrl("NavigationPage.qml"), {
                                                         count: pdfPagesView.count,
                                                     })
                navigationPage.pageSelected.connect(function(page) { pdfPagesView.goToPage(page - 1) })
            }

            height: Theme.itemSizeMedium
            width: Math.min(navigationButtonLabel.width, Theme.itemSizeLarge)
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: navigationButtonLabel

                text: qsTr("%L1 | %L2").arg(pdfPagesView.currentIndex + 1).arg(pdfPagesView.count)
                color: navigationButton.pressed ? palette.highlightBackgroundColor : palette.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.centerIn: parent
            }
        }
    }

    PdfDocument {
        id: pdfiumProvider

        objectName: "pdfDocument"
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

            PropertyChanges { target: pdfPagesView; visible: true }
        },
        State {
            name: root.statesNames[1]

            PropertyChanges { target: pdfPagesView; visible: false }
        },
        State {
            name: root.statesNames[2]

            PropertyChanges { target: root; path: "" }
            PropertyChanges { target: errorText; text: qsTr("Could not open document") }
            PropertyChanges { target: pdfPagesView; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        },
        State {
            name: root.statesNames[3]

            PropertyChanges { target: root; path: "" }
            PropertyChanges { target: errorText; text: qsTr("File not found") }
            PropertyChanges { target: pdfPagesView; enabled: false }
            PropertyChanges { target: toolBar; open: false }
        }
    ]
}
