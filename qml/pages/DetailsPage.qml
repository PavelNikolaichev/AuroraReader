// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.aurora.TinyPdfViewer 1.0
Page {
    id: root

    property FileInfo fileInfo
    property string pageCount: "0"

    objectName: "aboutFilePage"
    allowedOrientations: Orientation.All

    SilicaFlickable {
        objectName: "detailFlickable"
        contentHeight: contentColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: contentColumn

            objectName: "contentColumn"
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                objectName: "pageHeader"
                title: qsTr("Details")
            }

            DetailItem {
                objectName: "pathLabel"
                label: qsTr("File path")
                value: fileInfo.path
                alignment: Qt.AlignLeft
            }

            DetailItem {
                objectName: "sizeLabel"
                label: qsTr("Size")
                value: fileInfo.isExist() ? Format.formatFileSize(fileInfo.size) : "-"
                alignment: Qt.AlignLeft
            }

            DetailItem {
                objectName: "modifiedLabel"
                label: qsTr("Last modified")
                value: fileInfo.isExist() ? Format.formatDate(fileInfo.lastModified, Format.DateFull) : "-"
                alignment: Qt.AlignLeft
            }

            DetailItem {
                objectName: "pageCountLabel"
                label: qsTr("Page count")
                value: (fileInfo.isExist() && pageCount > 0) ? pageCount : qsTr("Unknown")
                alignment: Qt.AlignLeft
            }
        }
    }
}
