// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#include <QFileInfo>
#include <QDateTime>
#include <QDBusConnection>
#include <QDBusArgument>
#include <QTimer>
#include <QDBusMetaType>
#include <QThreadPool>
#include <QRegularExpression>

#include "dbusconstants.h"
#include "trackerqueryworker.h"
#include "filesmodel.h"

static QDBusArgument& operator<<(QDBusArgument &argument, const TimeSettingsInternal &arg)
{
    argument.beginStructure();
    argument << arg.field_1 << arg.field_2;
    argument.endStructure();
    return argument;
}

static const QDBusArgument& operator>>(const QDBusArgument &argument, TimeSettingsInternal &arg)
{
    argument.beginStructure();
    argument >> arg.field_1 >> arg.field_2;
    argument.endStructure();
    return argument;
}

static QDBusArgument& operator<<(QDBusArgument &argument, const TimeSettings &arg)
{
    argument.beginStructure();
    argument << arg.field_1 << arg.field_2 << arg.field_3 << arg.is24;
    argument.endStructure();
    return argument;
}

static const QDBusArgument& operator>>(const QDBusArgument &argument, TimeSettings &arg)
{
    argument.beginStructure();
    argument >> arg.field_1 >> arg.field_2 >> arg.field_3 >> arg.is24;
    argument.endStructure();
    return argument;
}

FilesModel::FilesModel(QObject *parent) : QAbstractListModel(parent)
{
    qDBusRegisterMetaType<QMap<int, int>>();
    qDBusRegisterMetaType<TimeSettingsInternal>();
    qDBusRegisterMetaType<TimeSettings>();

    QDBusConnection sessionBus = QDBusConnection::sessionBus();
    sessionBus.connect(TRACKER_SERVICE, TRACKER_PATH, TRACKER_INTERFACE,
                       QStringLiteral("GraphUpdated"),
                       this,
                       SLOT(trackerGraphChanged(const QString &, const QMap<int, int>)));

    auto systemBus = QDBusConnection::systemBus();
    systemBus.connect(QStringLiteral("com.nokia.time"),
                      QStringLiteral("/com/nokia/time"),
                      QStringLiteral("com.nokia.time"),
                      QStringLiteral("settings_changed"),
                      this,
                      SLOT(timeFormatChanged(const TimeSettings &)));

    m_resetTimer = new QTimer(this);
    m_resetTimer->setSingleShot(true);
    m_resetTimer->setInterval(1000);
    connect(m_resetTimer, &QTimer::timeout, this, &FilesModel::reset);
}

int FilesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_data.size();
}

QVariant FilesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() > m_data.size())
        return QVariant();

    const QFileInfo fileInfo(m_data.at(index.row()));

    switch (role) {
    case PathRole:
        return QVariant::fromValue(fileInfo.filePath());
    case FileNameRole:
        return QVariant::fromValue(fileInfo.fileName());
    case SizeRole:
        return QVariant::fromValue(fileInfo.size());
    case LastChangesRole:
        return QVariant::fromValue(fileInfo.lastModified());
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FilesModel::roleNames() const
{
    return {
        {PathRole, "path"},
        {FileNameRole, "fileName"},
        {SizeRole, "size"},
        {LastChangesRole, "lastChanges"}
    };
}

void FilesModel::reset()
{
    if (m_resetTimer->isActive())
        return;

    auto trackerQueryWorker = new TrackerQueryWorker();
    connect(trackerQueryWorker, &TrackerQueryWorker::done, this, [this](QStringList freshData) {
        // remove paths that where not in query
        {
            int index = 0;
            QMutableStringListIterator it(m_data);
            while (it.hasNext()) {
                if (!freshData.contains(it.next()) && !QFileInfo::exists(it.value())) {
                    beginRemoveRows(QModelIndex(), index, index);
                    it.remove();
                    endRemoveRows();
                } else {
                    ++index;
                }
            }
        }

        // remove known paths from query result.
        {
            QMutableStringListIterator it(freshData);
            while (it.hasNext())
                if (m_data.contains(it.next()))
                    it.remove();
        }

        // append new paths from query to model
        {
            for (const auto &path : freshData) {
                QFileInfo freshFile(path);

                int index = 0;
                for (; index < m_data.count(); ++index) {
                    QFileInfo fileInfo(m_data.at(index));
                    if (fileInfo.lastModified() < freshFile.lastModified())
                        break;
                }

                beginInsertRows(QModelIndex(), index, index);
                m_data.insert(index, path);
                endInsertRows();
            }
        }

        emit graphChanged(m_data.size());

        if (freshData.isEmpty())
            m_resetTimer->start();
    });
    QThreadPool::globalInstance()->start(trackerQueryWorker);
}

bool FilesModel::removeFile(const QString &fileName)
{
    const QFileInfo fileInfo(fileName);
    if (!fileInfo.isWritable())
        return false;

    QFile::remove(fileInfo.absoluteFilePath());
    return true;
}

void FilesModel::trackerGraphChanged(const QString &name, const QMap<int, int> &)
{
    static const QRegularExpression reDocuments("(#)(Documents)");
    static const QRegularExpression reFilesystem("(#)(FileSystem)");
    if (reDocuments.match(name).hasMatch() || reFilesystem.match(name).hasMatch())
        if (!m_resetTimer->isActive())
            reset();
}

void FilesModel::timeFormatChanged(const TimeSettings &)
{
    emit dataChanged(index(0, 0), index(m_data.size(), 0), { LastChangesRole });
}
