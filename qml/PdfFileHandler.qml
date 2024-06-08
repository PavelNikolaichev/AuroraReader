import QtQuick 2.0
import ru.omp.amberpdf 1.0
import ru.aurora.TinyPdfViewer 1.0

BaseFileHandler {
    id: pdfFileHandler

    PdfDocument {
        id: pdfDocument
        objectName: "pdfDocument"
        path: filePath
        onStatusChanged: {
            isValid = (status === PdfDocument.Ready)
            if (!isValid) {
                errorMessage = qsTr("Could not open PDF document")
            }
        }
    }

    function checkFile() {
        // Logic to validate PDF file
        isValid = filePath.endsWith(".pdf")
        if (!isValid) {
            errorMessage = qsTr("Invalid PDF file")
        }
    }

    function displayFile() {
        if (isValid) {
            // Display the PDF using PdfView
            pdfView.filePath = filePath
        } else {
            console.error(errorMessage)
        }
    }

    PdfView {
        id: pdfView
        anchors.fill: parent
        documentProvider: pdfDocument
    }
}
