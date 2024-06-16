// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import ru.aurora.TinyPdfViewer 1.0

Page {
    id: root

    property var timeFormat: Format.Timepoint
    readonly property var statesNames: ["loading", "work", "documentsNotFound"]
    property SortModel filesModel: SortModel {
        function escapeRegExp(text) {
            return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
        }

        objectName: "sortModel"
        sourceModel: FilesModel {
            onGraphChanged: {
                root.state = documentsCount > 0 ? root.statesNames[1] : root.statesNames[2]

                if (pageStack.currentPage === null || pageStack.currentPage.objectName === root.objectName)
                    return

                var contentPage = pageStack.find(function(page) { if (page.objectName === "contentPage" || page.objectName === "txtContentPage") return page })
                if (contentPage !== undefined)
                    contentPage.checkCurrentFile()
            }
            onDataChanged: {
                root.timeFormat = ""
                root.timeFormat = Format.Timepoint
            }

            Component.onCompleted: {
                root.state = statesNames[0]
                reset()
            }

            objectName: "filesModel"
        }
        filterRegExp: RegExp(escapeRegExp(filesView.searchText), "i")
    }

    function chooseFile(path) {
        console.log("Adding path: ", path)
        while (pageStack.depth > 1)
            pageStack.pop(undefined, PageStackAction.Immediate)
// TODO: fix the error with wrong paths
//        pageStack.push(Qt.resolvedUrl("TxtContentPage.qml"), { txtPath: path === undefined ? "" : path })
        pageStack.push(Qt.resolvedUrl("TxtContentPage.qml"), { txtPath: path === undefined ? "" : "/run/media/defaultuser/sdk/CoolThings.txt" })
//        pageStack.push(Qt.resolvedUrl("ContentPage.qml"), { pdfPath: path === undefined ? "" : path })
    }

    objectName: "filesPage"
    allowedOrientations: Orientation.All

    BusyIndicator {
        id: documentListLoadIndicator

        objectName: "busyIndicator"
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    Label {
        id: documentsNotFoundLabel

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }
        objectName: "errorLabel"
        enabled: filesView.count <= 0
        visible: enabled
        color: Theme.highlightColor
        textFormat: Text.PlainText
        text: qsTr("Documents not found")
        font.pixelSize: Theme.fontSizeExtraLarge
    }

    SilicaListView {
        id: filesView

        property bool searchEnabled
        property string searchText

        onCountChanged: root.state = filesView.count > 0 ? root.statesNames[1] : root.statesNames[2]

        Component.onCompleted: currentIndex = -1

        objectName: "filesView"
        anchors.fill: parent
        delegate: fileDelegateComponent
        header: filesViewHeaderComponent
        model: root.filesModel
    }

    Component {
        id: filesViewHeaderComponent

        Column {
            width: parent.width

            property alias searchText: searchField.text

            PageHeader {
                objectName: "listHeader"
                title: qsTr("Tiny PDF Viewer")
            }

            SearchField {
                id: searchField

                onTextChanged: filesView.searchText = text
                onActiveChanged: if (active) forceActiveFocus()
                onHeightChanged: filesView.contentY -= height
                EnterKey.onClicked: focus = false

                objectName: "searchField"
                active: filesView.searchEnabled
                width: parent.width
                height: active ? Theme.itemSizeMedium : 0
                placeholderText: qsTr("Search documents")
                transitionDuration: 400
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
            }

            PullDownMenu {
                id: menu

                property bool _searchEnabled

                onActiveChanged: {
                    filesView.searchEnabled = _searchEnabled
                }

                objectName: "searchMenu"

                MenuItem {
                    objectName: "searchMenuItem"
                    text: filesView.searchEnabled
                          ? qsTr("Hide search field")
                          : qsTr("Show search field")
                    onClicked: menu._searchEnabled = !menu._searchEnabled
                }
            }
        }
    }

    Component {
        id: fileDelegateComponent

        ListItem {
            id: fileDelegate

            onClicked: root.chooseFile(model.path)

            objectName: "delegateItem"
            contentHeight: Theme.itemSizeMedium

            Icon {
                id: fileIcon

                objectName: "fileIcon"
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-file-pdf-light"
            }

            Column {
                objectName: "delegateColumn"
                anchors {
                    left: fileIcon.right
                    leftMargin: Theme.paddingMedium
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    objectName: "filenameLabel"
                    width: parent.width
                    color: fileDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    text: filesView.searchText.length > 0
                          ? Theme.highlightText(model.fileName, filesView.searchText, Theme.highlightColor)
                          : model.fileName
                    textFormat: filesView.searchText.length > 0 ? Text.StyledText : Text.PlainText
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                }

                Item {
                    objectName: "fileInfoItem"
                    width: parent.width
                    height: fileSizeLabel.height

                    Label {
                        id: fileSizeLabel

                        objectName: "sizeLabel"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: fileDelegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: Format.formatFileSize(model.size)
                    }

                    Label {
                        objectName: "fileTimeLabel"
                        anchors.right: parent.right
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: fileDelegate.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: Format.formatDate(model.lastChanges, root.timeFormat)
                    }
                }
            }

            function deleteFile() {
                var currentRow = index
                remorseDelete(function() { filesModel.removeFile(model.path) })
            }

            menu: Component {
                ContextMenu {
                    objectName: "contexMenu"

                    MenuItem {
                        objectName: "shareMenu"
                        text: qsTr("Share")
                        onClicked: {
                            shareAction.resources = [Qt.resolvedUrl(model.path)]
                            shareAction.trigger()
                        }
                    }
                    MenuItem {
                        objectName: "deleteMenu"
                        text: qsTr("Delete")
                        onClicked: fileDelegate.deleteFile()
                    }
                }
            }
        }
    }

    ShareAction {
        id: shareAction
        objectName: "shareAction"
    }

    Connections {
        onFileOpenRequested: chooseFile(path)

        target: dbusAdaptor
    }

    states: [
        State {
            name: "loading"

            PropertyChanges { target: documentsNotFoundLabel; visible: false }
            PropertyChanges { target: documentListLoadIndicator; visible: true; running: true }
        },
        State {
            name: "work"

            PropertyChanges { target: documentsNotFoundLabel; visible: false }
            PropertyChanges { target: documentListLoadIndicator; visible: false; running: false }
        },
        State {
            name: "documentsNotFound"

            PropertyChanges { target: documentsNotFoundLabel; visible: true }
            PropertyChanges { target: documentListLoadIndicator; visible: false; running: false }
        }
    ]
}
