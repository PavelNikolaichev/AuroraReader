#ifndef FILEREADER_H
#define FILEREADER_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QTextStream>

class FileReader : public QObject
{
    Q_OBJECT
public:
    explicit FileReader(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString readTextFile(const QString &filePath) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return QString();
        }

        QTextStream in(&file);
        QString content = in.readAll();
        file.close();
        return content;
    }

signals:

};

#endif // FILEREADER_H
