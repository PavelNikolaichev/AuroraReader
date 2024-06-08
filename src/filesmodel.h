// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#ifndef FILESMODEL_H
#define FILESMODEL_H

#include <QAbstractListModel>

struct TimeSettingsInternal
{
    int field_1;
    unsigned int field_2;
};

struct TimeSettings
{
    bool field_1;
    bool field_2;
    bool field_3;
    bool is24;
    QMap<int, unsigned int> field_5;
    QStringList field_6;
    QList<int> field_7;
    QList<int> field_8;
    TimeSettingsInternal field_9;
    QString zoneinfo;
    QString locale;
    int field_10;
    QString field_11;
    bool field_12;
    QString field_13;
};

class QTimer;
class FilesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum FilePropertyRoles
    {
        PathRole = Qt::UserRole + 1,
        FileNameRole,
        SizeRole,
        LastChangesRole
    };

    explicit FilesModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void reset();
    Q_INVOKABLE bool removeFile(const QString &fileName);

private slots:
    void trackerGraphChanged(const QString &name, const QMap<int, int> &);
    void timeFormatChanged(const TimeSettings &);

signals:
    void graphChanged(int documentsCount);

private:
    QStringList m_data;
    QTimer *m_resetTimer;
};

Q_DECLARE_METATYPE(TimeSettingsInternal)
Q_DECLARE_METATYPE(TimeSettings)

#endif // FILESMODEL_H
