// SPDX-FileCopyrightText: 2022 Open Mobile Platform LLC <community@omp.ru>
// SPDX-License-Identifier: BSD-3-Clause

#include "filesmodel.h"
#include "sortmodel.h"

SortModel::SortModel(QObject *parent) : QSortFilterProxyModel (parent)
{
    this->setFilterRole(FilesModel::FilePropertyRoles::FileNameRole);
    setSortParameter(SortParameter::Date);
    setSortCaseSensitivity(Qt::CaseInsensitive);
}

SortModel::~SortModel() = default;

FilesModel *SortModel::sourceModel() const
{
    return static_cast<FilesModel*>(QSortFilterProxyModel::sourceModel());
}

int SortModel::sortParameter() const
{
    return m_sortParameter;
}

bool SortModel::removeFile(const QString &fileName)
{
    if (sourceModel() == nullptr)
        return false;

    auto filesModel = qobject_cast<FilesModel *>(sourceModel());
    if (filesModel == nullptr)
        return false;

    return filesModel->removeFile(fileName);
}

void SortModel::setSourceModel(FilesModel *sourceModel)
{
    QSortFilterProxyModel::setSourceModel(static_cast<QAbstractItemModel*>(sourceModel));
}

void SortModel::setSortParameter(int sortParameter)
{
    if (m_sortParameter == sortParameter)
        return;

    m_sortParameter = sortParameter;
    Qt::SortOrder order = Qt::AscendingOrder;

    switch (m_sortParameter) {
    case None: break;
    case Date:
        setSortRole(FilesModel::FilePropertyRoles::LastChangesRole);
        order = Qt::DescendingOrder;
        break;
    default:
        break;
    }

    emit sortParameterChanged(m_sortParameter);

    sort(0, order);
}
