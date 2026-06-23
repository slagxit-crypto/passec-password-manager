import 'dart:js' as js;

void downloadFileWeb(String filename, String base64Data) {
  js.context.callMethod('downloadFile', [filename, base64Data]);
}

void uploadFileWeb(Function(String) onFileSelected) {
  js.context.callMethod('uploadFile', [
    js.allowInterop((fileContent) {
      onFileSelected(fileContent);
    })
  ]);
}
