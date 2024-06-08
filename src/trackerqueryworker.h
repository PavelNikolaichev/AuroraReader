// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#ifndef TRACKERQUERYWORKER_H
#define TRACKERQUERYWORKER_H

#include <QObject>
#include <QRunnable>
#include <QDBusReply>

class TrackerQueryWorker : public QObject, public QRunnable
{
    Q_OBJECT

public:
    TrackerQueryWorker();
    ~TrackerQueryWorker() override;

    void run() override;

signals:
    void done(QStringList);
};

#endif // TRACKERQUERYWORKER_H
