// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#include <QUrl>
#include <QStringList>
#include <QDBusConnection>
#include <QDBusConnectionInterface>

#include "dbusadaptor.h"

DBusAdaptor::DBusAdaptor(QObject *parent):  QDBusAbstractAdaptor(parent)
{

    QDBusConnection dbusConnection = QDBusConnection::sessionBus();
    if (!dbusConnection.interface()->isServiceRegistered(QStringLiteral("ru.aurora.TinyPdfVewer"))) {
        dbusConnection.registerObject(QStringLiteral("/ru/aurora/TinyPdfViewer"), parent);
        dbusConnection.registerService(QStringLiteral("ru.aurora.TinyPdfViewer"));
    }
}

void DBusAdaptor::openFile(const QStringList &args)
{
    if (args.isEmpty())
        return;

    QString path;
    for (const auto &arg : args) {
        if (arg.isEmpty())
            continue;

        path = arg;
        break;
    }

    path = QUrl::fromPercentEncoding(path.toUtf8());
    path.remove(QStringLiteral("file://"));

    emit fileOpenRequested(path);
}
