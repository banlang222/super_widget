import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:extension/extension.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';

import 'file_icon.dart';
import 'super_form_field.dart';

typedef SendProgressCallback = Function(num progress);
typedef DoUpload = Function(SendProgressCallback progressCallback,
    {String? fileName, Uint8List? fileBytes, String? filePath});

enum DragStatus {
  outside(0, '将文件拖到这里，或点此选取文件'),
  inside(1, '请松手'),
  uploading(2, '上传中');

  const DragStatus(this.value, this.text);
  final String text;
  final int value;
}

enum FileListPosition {
  top,
  left,
  right,
  bottom;

  static FileListPosition fromValue(int value) {
    switch (value) {
      case 0:
        return FileListPosition.top;
      case 1:
        return FileListPosition.left;
      case 3:
        return FileListPosition.bottom;
      default:
        return FileListPosition.right;
    }
  }
}

enum FileListType {
  url,
  preview,
  urlWithPreview;

  static FileListType fromValue(int value) {
    switch (value) {
      case 0:
        return FileListType.url;
      case 1:
        return FileListType.preview;
      default:
        return FileListType.urlWithPreview;
    }
  }
}

class UploadField implements SuperFormField<List<String>?> {
  UploadField(
      {required this.name,
      this.text,
      this.defaultValue,
      this.helperText,
      this.isRequired = false,
      this.readonly = false,
      this.editMode = true,
      this.uploadUrl,
      this.doUpload,
      this.singleFile = false,
      required this.allowedFileType,
      this.fileListPosition = FileListPosition.right,
      this.fileListType = FileListType.urlWithPreview}) {
    _value.value = defaultValue?.map((e) => {'url': e}).toList() ?? [];
  }

  UploadField.fromMap(Map<String, dynamic> map) {
    if (map['defaultValue'] != null) {
      if (map['defaultValue'] is String) {
        defaultValue = [map['defaultValue']];
      } else {
        defaultValue = map['defaultValue'];
      }
      _value.addAll(defaultValue!.map((e) => {'url': e}));
    }
    name = map['name'];
    readonly = map['readonly'] ?? false;
    editMode = map['editMode'] ?? true;
    text = map['text'];
    isRequired = map['isRequired'] ?? false;
    uploadUrl = map['uploadUrl'];
    helperText = map['helperText'];
    if (map['allowedFileType'] != null && map['allowedFileType'] is List) {
      allowedFileType = List<String>.from(map['allowedFileType'])
          .map((e) => SFileType.fromExt(e))
          .toList();
    } else {
      allowedFileType = SFileType.all;
    }
    if (map['fileListType'] != null) {
      fileListType = FileListType.fromValue(map['fileListType']);
    }
    if (map['fileListPosition'] != null) {
      fileListPosition = FileListPosition.fromValue(map['fileListPosition']);
    }
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

  bool singleFile = false;

  String? uploadUrl;
  DoUpload? doUpload;

  late List<SFileType> allowedFileType;

  FileListPosition fileListPosition = FileListPosition.right;

  FileListType fileListType = FileListType.urlWithPreview;

  @override
  List<String> get value {
    return _value.map((e) => e['url'] as String).toList();
  }

  /// 接受String及List<String>
  @override
  set value(dynamic v) {
    if (v == null) {
      _value.clear();
    } else {
      if (v is String) {
        _value.value = [
          {'url': v}
        ];
      } else if (v is List<String>) {
        _value.clear();
        for (var element in v) {
          if (_value.where((e) => e['url'] == element).isEmpty) {
            _value.add({'url': element});
          }
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
    if (isRequired && _value.isEmpty ||
        _value
            .where((element) => (element['url'] as String).isNullOrEmpty)
            .isNotEmpty) {
      _errorText.value = '请检查';
      return false;
    }
    return true;
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
        doUpload: doUpload,
        allowedFileType: allowedFileType);
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
    final ThemeData themeData = Theme.of(Get.context!);
    return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Obx(() {
          var dropTarget = DropTarget(
              onDragEntered: (details) {
                _dragStatus.value = DragStatus.uploading;
              },
              onDragExited: (details) {
                _dragStatus.value = DragStatus.outside;
              },
              onDragDone: (details) async {
                var xFile = details.files.first;
                await upload(xFile);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 20, 25),
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
                    child: Center(child: Text(_dragStatus.value.text)),
                  ),
                ),
              ));
          var fileList = fileListType == FileListType.urlWithPreview
              ? urlList(true)
              : fileListType == FileListType.url
                  ? urlList()
                  : previewList();
          return InputDecorator(
              decoration: InputDecoration(
                  labelText: '$text',
                  isDense: true,
                  isCollapsed: true,
                  enabledBorder: (readonly || !editMode)
                      ? themeData.inputDecorationTheme.disabledBorder
                      : themeData.inputDecorationTheme.border,
                  contentPadding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                  helperText:
                      '${isRequired ? ' * ' : ''}${helperText ?? '允许上传类型：${allowedFileType.map((e) => e.name).join('、')}'}',
                  errorText: _errorText.value),
              isFocused: true,
              isEmpty: false,
              child: fileListPosition == FileListPosition.right
                  ? IntrinsicHeight(
                      child: Row(
                        children: [
                          if (!readonly || editMode)
                            SizedBox(
                              width: 350,
                              child: dropTarget,
                            ),
                          Expanded(child: fileList)
                        ],
                      ),
                    )
                  : fileListPosition == FileListPosition.left
                      ? IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(child: fileList),
                              if (!readonly || editMode)
                                SizedBox(
                                  width: 350,
                                  child: dropTarget,
                                ),
                            ],
                          ),
                        )
                      : fileListPosition == FileListPosition.top
                          ? IntrinsicWidth(
                              child: Column(
                                children: [
                                  fileList,
                                  if (!readonly || editMode)
                                    SizedBox(
                                      width: double.infinity,
                                      child: dropTarget,
                                    ),
                                ],
                              ),
                            )
                          : IntrinsicWidth(
                              child: Column(
                                children: [
                                  if (!readonly || editMode)
                                    SizedBox(
                                      width: double.infinity,
                                      child: dropTarget,
                                    ),
                                  fileList,
                                ],
                              ),
                            ));
        }));
  }

  Widget previewList() {
    if (_value.length == 1) {
      var fileType = SFileType.fromUrl(_value.first['url']);
      if (fileType.isImage) {
        return Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    Get.to(() => ImageView(url: _value.first['url']));
                  },
                  child: ExtendedImage.network(
                    _value.first['url'],
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _value.clear();
                },
                icon: const Icon(Icons.delete),
              )
            ],
          ),
        );
      }
    }
    return GridView.extent(
      maxCrossAxisExtent: 300,
      padding: const EdgeInsets.all(10),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: _value.map((e) {
        var fileType = SFileType.fromUrl(e['url']);
        return Column(
          children: [
            Expanded(
                child: fileType.isImage
                    ? InkWell(
                        onTap: () {
                          Get.to(() => ImageView(url: e['url']));
                        },
                        child: ExtendedImage.network(
                          e['url'],
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : Icon(
                        fileType.icon,
                        size: 250,
                      )),
            IconButton(
              onPressed: () {
                _value.removeWhere((element) => element == e);
              },
              icon: const Icon(Icons.delete),
            )
          ],
        );
      }).toList(),
    );
  }

  Widget urlList([bool showPreview = false]) {
    return Column(
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
                    children: _value.map((element) {
                      var url = element['url'];
                      var sFileType = SFileType.fromUrl(url);
                      return Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.black12),
                        child: url.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(10),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[100],
                                  value: element['progress'],
                                  minHeight: 40,
                                ),
                              )
                            : Wrap(
                                spacing: 10,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  (showPreview && sFileType.isImage)
                                      ? Tooltip(
                                          richMessage: WidgetSpan(
                                              child: Image.network(
                                            url,
                                            width: 300,
                                          )),
                                          child: Icon(sFileType.icon),
                                        )
                                      : Icon(
                                          sFileType.icon,
                                        ),
                                  Text('${element['url']}'),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(
                                      Icons.cancel,
                                      size: 20,
                                    ),
                                    label: const Text('删除'),
                                    onPressed: () {
                                      _value.removeWhere((e) => e == element);
                                    },
                                  )
                                ],
                              ),
                      );
                    }).toList())),
      ],
    );
  }

  final _dragStatus = DragStatus.outside.obs;

  Future<void> upload(XFile xFile) async {
    _dragStatus.value = DragStatus.uploading;
    String? extension;
    try {
      extension =
          xFile.name.substring(xFile.name.lastIndexOf('.') + 1).toLowerCase();
    } catch (e) {
      print('e=$e');
    }
    if (extension != null &&
        allowedFileType.contains(SFileType.fromExt(extension))) {
      _errorText.value = null;
      Map<String, dynamic> file = {
        'origin': xFile.path,
        'url': '',
        'progress': 0.0
      };
      if (singleFile) {
        _value.value = [file];
      } else if (_value
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
    _dragStatus.value = DragStatus.outside;
  }
}

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('图片'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: ExtendedImage.network(
            url,
            fit: BoxFit.fitWidth,
          ),
        ),
      ),
    );
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
  static const SFileType unknown = SFileType._('unknown', Icons.block);

  static List<SFileType> get all {
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
      txt
    ];
  }

  static SFileType fromUrl(String? url) {
    if (url.isNullOrEmpty) return SFileType.unknown;
    String ext = url!.split('.').last.toLowerCase();
    return fromExt(ext);
  }

  static SFileType fromExt(String? ext) {
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
        return unknown;
    }
  }

  bool get isImage {
    return icon == FileIcon.file_image;
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

  static List<SFileType> get image {
    return [
      png,
      jpg,
      jpeg,
      gif,
      bmp,
    ];
  }

  static List<SFileType> get word {
    return [
      doc,
      docx,
      xls,
      xlsx,
      ppt,
      pptx,
    ];
  }
}
