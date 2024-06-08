// SPDX-FileCopyrightText: 2020-2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0
import ru.aurora.TinyPdfViewer 1.0

Page {
    id: root

    property alias noteText: noteText.value
    property alias author: authorName.value

    allowedOrientations: Orientation.All
    objectName: "navigationPage"

    SilicaFlickable {
        objectName: "noteFlickable"
        contentHeight: contentColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: contentColumn

            objectName: "noteColumn"
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                objectName: "notePageHeader"
                title: qsTr("Note")
            }

            DetailItem {
                id: authorName

                objectName: "authorNameLabel"
                label: qsTr("Author name")
                alignment: Qt.AlignLeft
            }

            DetailItem {
                id: noteText

                objectName: "noteContentLabel"
                label: qsTr("Content")
                alignment: Qt.AlignLeft
            }
        }
    }
}
