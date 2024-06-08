// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#include <QScopedPointer>
#include <QGuiApplication>
#include <QQuickView>
#include <QQmlContext>

#include <auroraapp.h>

#include "filesmodel.h"
#include "sortmodel.h"
#include "dbusadaptor.h"
#include "fileinfo.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> application(Aurora::Application::application(argc, argv));
    application->setOrganizationName(QStringLiteral("ru.aurora"));
    application->setApplicationName(QStringLiteral("TinyPdfViewer"));

    qmlRegisterType<FilesModel>("ru.aurora.TinyPdfViewer", 1, 0, "FilesModel");
    qmlRegisterType<SortModel>("ru.aurora.TinyPdfViewer", 1, 0, "SortModel");   
    qmlRegisterType<FileInfo>("ru.aurora.TinyPdfViewer", 1, 0, "FileInfo");

    QScopedPointer<QQuickView> view(Aurora::Application::createView());

    DBusAdaptor dbusAdaptor(view.data());
    view->rootContext()->setContextProperty(QStringLiteral("dbusAdaptor"), &dbusAdaptor);

    view->setSource(Aurora::Application::pathTo(QStringLiteral("qml/ru.aurora.TinyPdfViewer.qml")));
    view->show();

    return application->exec();
}
