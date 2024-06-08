// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#ifndef FILEINFO_H
#define FILEINFO_H

#include <QFileInfo>
#include <QObject>

class FileInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    Q_PROPERTY(qint64 size READ size NOTIFY pathChanged)
    Q_PROPERTY(QString lastModified READ lastModified NOTIFY pathChanged)
    Q_PROPERTY(QString fileName READ fileName NOTIFY pathChanged)
    Q_PROPERTY(QString baseName READ baseName NOTIFY pathChanged)

public:
    explicit FileInfo(QObject *parent = nullptr);

    QString baseName() const;
    QString fileName() const;
    QString lastModified() const;
    QString path() const;
    qint64 size() const;
    void setPath(QString path);
    Q_INVOKABLE bool isExist() const;
    Q_INVOKABLE void refresh();

signals:
    void pathChanged(QString path);

private:
    QFileInfo m_fileInfo;
};

#endif // FILEINFO_H
