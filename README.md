# AuroraReader

The project provides a simple reader for viewing various documents based on the example `TinyPdfViewer`.

The main goal is to obtain a ready-made application for reading e-books.

## Terms of Use and Participation

The source code of the project is provided under [the license](LICENSE.BSD-3-CLAUSE.md),
which allows its use in third-party applications.

The [contributor agreement](CONTRIBUTING.md) documents the rights granted by contributors
of the Open Mobile Platform.

Information about the contributors is specified in the [AUTHORS](AUTHORS.md) file.

[Code of conduct](CODE_OF_CONDUCT.md) is a current set of rules of the Open Mobile
Platform which informs you how we expect the members of the community will interact
while contributing and communicating.

## Project Structure

The project has a standard structure of an application based on C++ and QML for Aurora OS.

* **[ru.auroraos.TinyPdfViewer.pro](ru.auroraos.TinyPdfViewer.pro)** file
        describes the project structure for the qmake build system.
* **[icons](icons)** directory contains the application icons for different screen resolutions.
* **[qml](qml)** directory contains the QML source code and the UI resources.
    * **[cover](qml/cover)** directory contains the application cover implementations.
    * **[icons](qml/icons)** directory contains the additional custom UI icons.
    * **[pages](qml/pages)** directory contains the application pages.
    * **[ru.auroraos.TinyPdfViewer.qml](qml/ru.auroraos.TinyPdfViewer.qml)** file
                provides the application window implementation.
* **[rpm](rpm)** directory contains the rpm-package build settings.
    * **[ru.auroraos.TinyPdfViewer.spec](rpm/ru.auroraos.TinyPdfViewer.spec)** file
                is used by rpmbuild tool.
* **[src](src)** directory contains the C++ source code.
    * **[main.cpp](src/main.cpp)** file is the application entry point.
* **[translations](translations)** directory contains the UI translation files.
* **[ru.auroraos.TinyPdfViewer.desktop](ru.auroraos.TinyPdfViewer.desktop)** file
        defines the display and parameters for launching the application.

## Compatibility

The project is compatible with all the current versions of the Aurora OS.

## Application Workflow

- [FilesModel](src/filesmodel.h) provides a list model of the files stored on the device.
  The [FilesPage](qml/pages/FilesPage.qml) uses SilicaListView to display these files.
  
- The list of files is the result of a Tracker3 DBus query. 
  The Tracker3 DBus call is executed in the [TrackerQueryWorker](src/trackerqueryworker.h).

- [DBusAdaptor](src/dbusadaptor.h) implements a DBus service to open files on an external query.
  The adaptor emits [fileOpenRequested](src/dbusadaptor.h#L20) signal when the DBus method 
  [openFile](src/dbusadaptor.h#L17) is called. That signal activates
  [Application](qml/ru.auroraos.TinyPdfViewer.qml#L49) and sends the file path to the [FilesPage](qml/pages/FilesPage.qml#L287).
  
- [ContentPage](qml/pages/ContentPage.qml#L145) uses a PdfView QML type from the ru.omp.amberpdf plugin
  to show the PDF document content. That plugin can render PDF documents in horizontal and
  vertical orientations, draw annotations, notes. PdfView supports fast scroll, navigation,
  bookmarks, notes.

- [TxtContentPage](qml/pages/TxtContentPage.qml#L145) uses a TxtView QML type created based on `ContentPage.qml`
  to display TXT document content. This plugin can render TXT documents in horizontal and
  vertical orientations. TxtView supports simple navigation due to the simplicity of TXT documents.

## Screenshots

![screenshots](screenshots/screenshots.png)

## This document in Russian / Перевод этого документа на русский язык

- [README.ru.md](README.ru.md)

