




part of 'package:sanmill/appearance_settings/widgets/appearance_settings_page.dart';


final List<String> _bgPaths = <String>[
  Assets.images.backgroundImage1.path,
  Assets.images.backgroundImage2.path,
  Assets.images.backgroundImage3.path,
  Assets.images.backgroundImage4.path,
  Assets.images.backgroundImage5.path,
  Assets.images.backgroundImage6.path,
  Assets.images.backgroundImage7.path,
  Assets.images.backgroundImage8.path,
  Assets.images.backgroundImage9.path,
  Assets.images.backgroundImage10.path,
];



class _BackgroundImagePicker extends StatefulWidget {
  const _BackgroundImagePicker();

  @override
  _BackgroundImagePickerState createState() => _BackgroundImagePickerState();
}

class _BackgroundImagePickerState extends State<_BackgroundImagePicker> {


  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    final String backgroundImageText = S.of(context).backgroundImage;


    final double aspectRatio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;

    return Semantics(
      label: backgroundImageText,
      child: ValueListenableBuilder<Box<DisplaySettings>>(
        valueListenable: DB().listenDisplaySettings,
        builder: (BuildContext context, Box<DisplaySettings> box, _) {
          final DisplaySettings displaySettings = box.get(
            DB.displaySettingsKey,
            defaultValue: const DisplaySettings(),
          )!;

          return Padding(
            padding: const EdgeInsets.only(top: 20,bottom: 20),
            child: GridView.builder(
              key: const Key('background_image_gridview'),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: aspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),

              itemCount: _bgPaths.length + 2,
              itemBuilder: (BuildContext context, int index) {
                if (index < _bgPaths.length + 1) {


                  final String asset = index == 0 ? '' : _bgPaths[index - 1];
                  return _BackgroundImageItem(
                    key: Key('background_image_item_$index'),
                    asset: asset,
                    isSelect: displaySettings.backgroundImagePath == asset,
                    onChanged: () {


                      DB().displaySettings = displaySettings.copyWith(
                        backgroundImagePath: asset,
                      );
                    },
                  );
                } else {

                  return _CustomBackgroundImageItem(
                    key: const Key('custom_background_image_item'),
                    isSelected: displaySettings.backgroundImagePath ==
                        displaySettings.customBackgroundImagePath,
                    customImagePath: displaySettings.customBackgroundImagePath,
                    onSelect: () {

                      DB().displaySettings = displaySettings.copyWith(
                        backgroundImagePath:
                            displaySettings.customBackgroundImagePath ??
                                '', // TODO: '' is right?
                      );
                    },
                    onPickImage: () => _pickImage(
                      context,
                      aspectRatio: aspectRatio,
                      backgroundImageText: backgroundImageText,
                      displaySettings: displaySettings,
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }


  Future<void> _pickImage(
    BuildContext context, {
    required double aspectRatio,
    required String backgroundImageText,
    required DisplaySettings displaySettings,
  }) async {

    if (_isPicking) {

      return;
    }
    _isPicking = true;
    try {
      final NavigatorState navigator = Navigator.of(context);

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final Uint8List imageData = await pickedFile.readAsBytes();

        if (!mounted) {
          return;
        }


        final Uint8List? croppedData = await navigator.push<Uint8List?>(
          MaterialPageRoute<Uint8List?>(
            builder: (BuildContext context) => ImageCropPage(
              imageData: imageData,
              aspectRatio: aspectRatio,
              backgroundImageText: backgroundImageText,
              lineType: ReferenceLineType.none,
            ),
          ),
        );

        if (croppedData != null) {


          final Directory? appDir = (!kIsWeb && Platform.isAndroid)
              ? await getExternalStorageDirectory()
              : await getApplicationDocumentsDirectory();

          if (appDir != null) {
            final String imagesDirPath = '${appDir.path}/images';
            final Directory imagesDir = Directory(imagesDirPath);

            if (!imagesDir.existsSync()) {
              imagesDir.createSync(recursive: true);
            }


            final String timestamp =
                DateTime.now().millisecondsSinceEpoch.toString();
            final String filePath = '$imagesDirPath/$timestamp.png';


            final File imageFile = File(filePath);
            await imageFile.writeAsBytes(croppedData);


            DB().displaySettings = displaySettings.copyWith(
              customBackgroundImagePath: filePath,
              backgroundImagePath: filePath,
            );
          }
        }
      }
    } on PlatformException catch (e) {

      if (e.code == 'already_active') {

        logger.e('Another image picking operation is already in progress.');
      } else {
        rethrow;
      }
    } finally {
      _isPicking = false;
    }
  }
}


class _BackgroundImageItem extends StatelessWidget {
  const _BackgroundImageItem({
    required this.asset,
    this.isSelect = false,
    this.onChanged,
    super.key,
  });

  final String asset;
  final bool isSelect;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('background_image_gesture_$asset'),
      onTap: () {
        if (!isSelect) {
          onChanged?.call();
        }
      },
      child: Stack(
        children: <Widget>[
          Container(
            key: Key('background_image_container_$asset'),
            decoration: BoxDecoration(
              color: asset.isEmpty
                  ? DB().colorSettings.darkBackgroundColor
                  : null, // Use solid color if asset is empty
              image: asset.isEmpty
                  ? null
                  : DecorationImage(
                      image: getBackgroundImageProvider(DisplaySettings(
                        backgroundImagePath: asset,
                      ))!,
                      fit: BoxFit.cover,
                    ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Positioned(
            key: Key('background_image_icon_positioned_$asset'),
            right: 8,
            top: 8,
            child: Icon(
              isSelect ? Icons.check_circle : Icons.check_circle_outline,
              color: Colors.white,
              key: Key('background_image_icon_$asset'),
            ),
          ),
        ],
      ),
    );
  }
}




class _CustomBackgroundImageItem extends StatelessWidget {
  const _CustomBackgroundImageItem({
    required this.isSelected,
    required this.customImagePath,
    required this.onSelect,
    required this.onPickImage,
    super.key,
  });

  final bool isSelected;
  final String? customImagePath;
  final VoidCallback onSelect;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('custom_background_gesture'),

      onTap: customImagePath != null ? onSelect : onPickImage,
      child: Stack(
        children: <Widget>[

          Container(
            key: const Key('custom_background_container'),
            decoration: BoxDecoration(
              color: customImagePath == null
                  ? Colors.grey // Grey color if no custom image is selected
                  : null,
              image: customImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(customImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),

            child: customImagePath == null
                ? const Center(
                    child: Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.white,
                      key: Key('custom_background_add_icon'),
                    ),
                  )
                : null,
          ),

          if (customImagePath != null)
            Center(
              child: IconButton(
                key: const Key('custom_background_edit_button'),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: onPickImage,
                tooltip: S.of(context).chooseYourPicture,
              ),
            ),

          Positioned(
            key: const Key('custom_background_check_positioned'),
            right: 8,
            top: 8,
            child: Icon(
              isSelected ? Icons.check_circle : Icons.check_circle_outline,
              color: Colors.white,
              key: const Key('custom_background_check_icon'),
            ),
          ),
        ],
      ),
    );
  }
}





ImageProvider? getBackgroundImageProvider(DisplaySettings displaySettings) {
  final String path = displaySettings.backgroundImagePath;
  if (path.isEmpty) {

    return null;
  } else if (File(path).existsSync()) {

    return FileImage(File(path));
  } else {

    return AssetImage(path);
  }
}
