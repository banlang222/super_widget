import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:extension/extension.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'file_icon.dart';
import 'super_form_field.dart';

typedef SendProgressCallback = Function(num progress);
typedef DoUpload = Function(SendProgressCallback progressCallback,
    {String? fileName, Uint8List? fileBytes, String? filePath});

class UploadField implements SuperFormField<List<String>> {
  UploadField(
      {required this.name,
      this.text,
      this.defaultValue,
      this.helperText,
      this.isRequired = false,
      this.readonly = false,
      this.editMode = true,
      this.uploadUrl,
      this.doUpload}) {
    _value.value = defaultValue?.map((e) => {'url': e}).toList() ?? [];
  }

  UploadField.fromMap(Map<String, dynamic> map) {
    defaultValue = map['defaultValue'];
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
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
  late bool editMode;

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

  final _errorText = Rx<String?>(null);
  @override
  set errorText(String? v) {
    _errorText.value = v;
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
        editMode: editMode,
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
      'editMode': editMode,
      'isRequired': isRequired,
      'helperText': helperText
    };
  }

  final RxList<Map<String, dynamic>> _value = <Map<String, dynamic>>[].obs;
  GlobalKey filesKey = GlobalKey();

  @override
  Widget toWidget() {
    return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(
          () => InputDecorator(
            decoration: InputDecoration(
                labelText: '$text',
                isDense: true,
                isCollapsed: true,
                contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                helperText: '${isRequired ? ' * ' : ''}${helperText ?? ''}',
                errorText: _errorText.value),
            isFocused: true,
            isEmpty: false,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  DropTarget(
                      onDragEntered: (details) {
                        _dragText.value = '请松手';
                      },
                      onDragDone: (details) async {
                        var xFile = details.files.first;
                        await upload(xFile);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 20, 25),
                        child: SizedBox(
                          width: 300,
                          child: InkWell(
                            onTap: () async {
                              XFile? xFile = await openFile();
                              if (xFile != null) {
                                upload(xFile);
                              }
                            },
                            child: DottedBorder(
                              borderType: BorderType.RRect,
                              color: Colors.grey,
                              radius: const Radius.circular(10),
                              padding: const EdgeInsets.all(30),
                              child: Center(child: Text(_dragText.value)),
                            ),
                          ),
                        ),
                      )),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: _value.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 40),
                                  child: Text('还没有文件'),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _value
                                      .map((element) => Container(
                                            margin: const EdgeInsets.all(10),
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5)),
                                                color: Colors.black12),
                                            child: (element['url'] as String)
                                                    .isEmpty
                                                ? Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child:
                                                        LinearProgressIndicator(
                                                      backgroundColor:
                                                          Colors.grey[100],
                                                      value:
                                                          element['progress'],
                                                      minHeight: 40,
                                                    ),
                                                  )
                                                : Wrap(
                                                    spacing: 10,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Icon(SFileType.fromUrl(
                                                              element['url'])!
                                                          .icon),
                                                      Text('${element['url']}'),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      // TextButton.icon(
                                                      //   icon: const Icon(
                                                      //     Icons.open_in_new,
                                                      //     size: 20,
                                                      //   ),
                                                      //   label: const Text('查看'),
                                                      //   onPressed: () {
                                                      //     print('url=${element['url']}');
                                                      //   },
                                                      // ),
                                                      TextButton.icon(
                                                        icon: const Icon(
                                                          Icons.cancel,
                                                          size: 20,
                                                        ),
                                                        label: const Text('删除'),
                                                        onPressed: () {
                                                          _value.removeWhere(
                                                              (e) =>
                                                                  e == element);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                          ))
                                      .toList())),
                    ],
                  )),
                ],
              ),
            ),
          ),
        ));
  }

  final _dragText = '将文件拖到这里，或点此选取文件'.obs;

  Future<void> upload(XFile xFile) async {
    _dragText.value = '正在上传';
    String? extension;
    try {
      extension =
          xFile.name.substring(xFile.name.lastIndexOf('.') + 1).toLowerCase();
    } catch (e) {
      print('e=$e');
    }
    if (extension != null && SFileType.fromExt(extension) != null) {
      _errorText.value = null;
      Map<String, dynamic> file = {
        'origin': xFile.path,
        'url': '',
        'progress': 0.0
      };
      if (_value
          .where((element) => element['origin'] == file['origin'])
          .isEmpty) {
        _value.add(file);
      }
      String? url = await doUpload!(
        (num progress) {
          file['progress'] = progress;
          _value.refresh();
        },
        fileName: xFile.name,
        fileBytes: await xFile.readAsBytes(),
      );
      if (!url.isNullOrEmpty) {
        file['url'] = url;
        _value.refresh();
      } else {
        _errorText.value = '上传失败';
      }
    } else {
      _errorText.value = '不允许上传 $extension 文件';
    }
    _dragText.value = '将文件拖到这里，或点此选取文件';
  }
}

class SFileType {
  const SFileType._(this.name, this.icon);

  final String name;
  final IconData icon;

  static const SFileType png = SFileType._('png', FileIcon.file_image);
  static const SFileType jpg = SFileType._('jpg', FileIcon.file_image);
  static const SFileType jpeg = SFileType._('jpeg', FileIcon.file_image);
  static const SFileType gif = SFileType._('gif', FileIcon.file_image);
  static const SFileType bmp = SFileType._('bmp', FileIcon.file_image);
  static const SFileType rar = SFileType._('rar', FileIcon.file_archive);
  static const SFileType zip = SFileType._('zip', FileIcon.file_archive);
  static const SFileType doc = SFileType._('doc', FileIcon.file_word);
  static const SFileType docx = SFileType._('docx', FileIcon.file_word);
  static const SFileType xls = SFileType._('xls', FileIcon.file_excel);
  static const SFileType xlsx = SFileType._('xlsx', FileIcon.file_excel);
  static const SFileType ppt = SFileType._('ppt', FileIcon.file_powerpoint);
  static const SFileType pptx = SFileType._('pptx', FileIcon.file_powerpoint);
  static const SFileType pdf = SFileType._('pdf', FileIcon.file_pdf);
  static const SFileType txt = SFileType._('txt', FileIcon.doc_text);
  static const SFileType mp4 =
      SFileType._('mp4', Icons.video_collection_outlined);

  static SFileType? fromUrl(String url) {
    String ext = url.split('.').last.toLowerCase();
    return fromExt(ext);
  }

  static SFileType? fromExt(String? ext) {
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

  static List<SFileType> get extAllowed {
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
