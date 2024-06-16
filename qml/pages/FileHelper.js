.pragma library

function getFileType(filePath) {
    if (filePath.endsWith(".pdf")) {
        return "pdf"
    } else if (filePath.endsWith(".png") || filePath.endsWith(".jpg") || filePath.endsWith(".jpeg")) {
        return "image"
    } else if (filePath.endsWith(".txt")) {
        return "text"
    } else {
        return "unknown"
    }
}
