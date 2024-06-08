import QtQuick 2.0

Item {
    id: baseFileHandler

    property string filePath: ""
    property string fileType: ""
    property bool isValid: false
    property string errorMessage: ""

    function loadFile(path) {
        filePath = path
        checkFile()
    }

    function checkFile() {
        // Override this function in the subclass to check the file type
    }

    function displayFile() {
        // Override this function in the subclass to display the file
    }
}
