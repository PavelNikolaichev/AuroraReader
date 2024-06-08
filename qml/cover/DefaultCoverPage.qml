// SPDX-FileCopyrightText: 2023 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: root

    CoverPlaceholder {
        objectName: "placeholder"
        text: qsTr("Tiny PDF Viewer")
        icon {
            source: Qt.resolvedUrl("../images/TinyPdfViewer.svg")
            sourceSize { width: icon.width; height: icon.height }
        }
        forceFit: true
    }
}
