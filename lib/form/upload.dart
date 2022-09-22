import 'package:flutter/material.dart';
import 'package:extension/extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'super_form_field.dart';
import 'file_icon.dart';

typedef SendProgressCallback = Function(num progress);
typedef DoUpload = Function(
    String filePath, SendProgressCallback progressCallback);

class UploadField implements SuperFormField<List<String>> {
  UploadField(
      {required this.name,
      this.text,
      this.defaultValue,
      this.helperText,
      this.isRequired = false,
      this.readonly = false,
      this.uploadUrl,
      this.doUpload}) {
    _value.value = defaultValue?.map((e) => {'url': e}).toList() ?? [];
  }

  UploadField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'];
    name = map['name'];
    readonly = map['readonly'] ?? false;
    text = map['text'];
    isRequired = map['isRequired'] ?? false;
    uploadUrl = map['uploadUrl'];
    helperText = map['helperText'];
  }

  @override
  List<String>? defaultValue;

  @override
  String? helperText;

  @override
  late bool isRequired;

  @override
  late String name;

  @override
  late bool readonly = false;

  @override
  String? text;

  @override
  FieldType? type = FieldType.upload;

  String? uploadUrl;
  DoUpload? doUpload;

  @override
  List<String> get value {
    return _value.map((e) => e['url'] as String).toList();
  }

  @override
  set value(List<String>? v) {
    if (v != null) {
      for (var element in v) {
        if (_value.where((e) => e['url'] == element).isEmpty) {
          _value.add({'url': element});
        }
      }
    }
  }

  @override
  bool check() {
    return _value.isNotEmpty &&
        _value
            .where((element) => (element['url'] as String).isNullOrEmpty)
            .isEmpty;
  }

  @override
  SuperFormField clone() {
    return UploadField(
        name: name,
        text: text,
        readonly: readonly,
        defaultValue: defaultValue,
        isRequired: isRequired,
        helperText: helperText,
        doUpload: doUpload);
  }

  @override
  Widget toFilterWidget() {
    return toWidget();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'text': text,
      'type': type?.name,
      'defaultValue': defaultValue,
      'readonly': readonly,
      'isRequired': isRequired,
      'helperText': helperText
    };
  }

  final RxList<Map<String, dynamic>> _value = <Map<String, dynamic>>[].obs;
  GlobalKey filesKey = GlobalKey();

  @override
  Widget toWidget() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$text',
          isDense: true,
          isCollapsed: true,
          contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
        ),
        isFocused: true,
        isEmpty: false,
        child: Column(
          children: [
            readonly
                ? Container()
                : Container(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: TextButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(
                                  dialogTitle: '选择文件',
                                  allowedExtensions: FileType.extAllowed
                                      .map((e) => e.name)
                                      .toList(),
                                  allowMultiple: false);
                          if (result != null && !result.paths.isNullOrEmpty) {
                            Map<String, dynamic> file = {
                              'origin': '${result.paths.first}',
                              'url': '',
                              'progress': 0.0
                            };
                            if (_value
                                .where((element) =>
                                    element['origin'] == file['origin'])
                                .isEmpty) {
                              _value.add(file);
                            }

                            String url = await doUpload!(result.paths.first!,
                                (num progress) {
                              file['progress'] = progress;
                              _value.refresh();
                            });
                            if (!url.isNullOrEmpty) {
                              file['url'] = url;
                              _value.refresh();
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                        ),
                        label: const Text('添加')),
                  ),
            Container(
              color: Colors.grey[50],
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              child: Obx(() => _value.isEmpty
                  ? const Text('还没有文件，请添加')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _value
                          .map((element) => Container(
                              height: 60,
                              margin: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Colors.black12),
                              child: (element['url'] as String).isEmpty
                                  ? Container(
                                      padding: const EdgeInsets.all(10),
                                      child: LinearProgressIndicator(
                                        backgroundColor: Colors.grey[100],
                                        value: element['progress'],
                                        minHeight: 40,
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(10),
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                        spacing: 10,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Icon(FileType.fromUrl(element['url'])!
                                              .icon),
                                          Text('${element['url']}'),
                                          const SizedBox(
                                            width: 40,
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.open_in_new,
                                              size: 20,
                                            ),
                                            label: const Text('查看'),
                                            onPressed: () {
                                              print('url=${element['url']}');
                                            },
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.cancel,
                                              size: 20,
                                            ),
                                            label: const Text('删除'),
                                            onPressed: () {
                                              _value.removeWhere(
                                                  (e) => e == element);
                                            },
                                          )
                                        ],
                                      ),
                                    )))
                          .toList())),
            ),
          ],
        ),
      ),
    );
  }
}

class FileType {
  const FileType._(this.name, this.icon);

  final String name;
  final IconData icon;

  static const FileType png = FileType._('png', FileIcon.file_image);
  static const FileType jpg = FileType._('jpg', FileIcon.file_image);
  static const FileType jpeg = FileType._('jpeg', FileIcon.file_image);
  static const FileType gif = FileType._('gif', FileIcon.file_image);
  static const FileType bmp = FileType._('bmp', FileIcon.file_image);
  static const FileType rar = FileType._('rar', FileIcon.file_archive);
  static const FileType zip = FileType._('zip', FileIcon.file_archive);
  static const FileType doc = FileType._('doc', FileIcon.file_word);
  static const FileType docx = FileType._('docx', FileIcon.file_word);
  static const FileType xls = FileType._('xls', FileIcon.file_excel);
  static const FileType xlsx = FileType._('xlsx', FileIcon.file_excel);
  static const FileType ppt = FileType._('ppt', FileIcon.file_powerpoint);
  static const FileType pptx = FileType._('pptx', FileIcon.file_powerpoint);
  static const FileType pdf = FileType._('pdf', FileIcon.file_pdf);
  static const FileType txt = FileType._('txt', FileIcon.doc_text);
  static const FileType mp4 =
      FileType._('mp4', Icons.video_collection_outlined);

  static FileType? fromUrl(String url) {
    String ext = url.split('.').last.toLowerCase();
    return fromExt(ext);
  }

  static FileType? fromExt(String? ext) {
    switch (ext) {
      case 'png':
        return png;
      case 'jpg':
        return jpg;
      case 'jpeg':
        return jpeg;
      case 'gif':
        return gif;
      case 'bmp':
        return bmp;
      case 'rar':
        return rar;
      case 'zip':
        return zip;
      case 'doc':
        return doc;
      case 'docx':
        return docx;
      case 'xls':
        return xls;
      case 'xlsx':
        return xlsx;
      case 'ppt':
        return ppt;
      case 'pptx':
        return pptx;
      case 'pdf':
        return pdf;
      case 'txt':
        return txt;
      case 'mp4':
        return mp4;
      default:
        return null;
    }
  }

  static List<FileType> get extAllowed {
    return [
      png,
      jpg,
      jpeg,
      gif,
      bmp,
      rar,
      zip,
      doc,
      docx,
      xls,
      xlsx,
      ppt,
      pptx,
      pdf,
      txt,
      mp4
    ];
  }
}
