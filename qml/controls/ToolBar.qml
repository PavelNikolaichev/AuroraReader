// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0

DockedPanel {
    id: root

    default property alias _data: contentItem.data

    height: Theme.itemSizeLarge
    dock: Dock.Bottom

    background: Rectangle {
        color: Theme.rgba(Theme.overlayBackgroundColor, Theme.opacityOverlay)
    }

    Row {
        id: contentItem

        spacing: Theme.paddingLarge * 2 + Theme.paddingMedium * 2
        height: root.height
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
