# SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
# SPDX-License-Identifier: BSD-3-Clause

TARGET = ru.aurora.TinyPdfViewer

CONFIG += \
    auroraapp \

QT += \
    dbus \

SOURCES += \
    src/dbusadaptor.cpp \
    src/fileinfo.cpp \
    src/filereader.cpp \
    src/main.cpp \
    src/filesmodel.cpp \
    src/trackerqueryworker.cpp \
    src/sortmodel.cpp \

HEADERS += \
    src/dbusadaptor.h \
    src/dbusconstants.h \
    src/fileinfo.h \
    src/filereader.h \
    src/filesmodel.h \
    src/trackerqueryworker.h \
    src/sortmodel.h \

DISTFILES += \
    qml/BaseFileHandler.qml \
    qml/PdfFileHandler.qml \
    qml/pages/TextView.qml \
    qml/pages/TxtContentPage.qml \
    rpm/ru.aurora.TinyPdfViewer.spec \
    AUTHORS.md \
    CODE_OF_CONDUCT.md \
    CONTRIBUTING.md \
    LICENSE.BSD-3-CLAUSE.md \
    README.md \
    README.ru.md \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.aurora.TinyPdfViewer.ts \
    translations/ru.aurora.TinyPdfViewer-ru.ts \
