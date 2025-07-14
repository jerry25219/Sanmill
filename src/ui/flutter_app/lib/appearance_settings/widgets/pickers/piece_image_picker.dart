




part of 'package:sanmill/appearance_settings/widgets/appearance_settings_page.dart';

final List<String> _pieceBgPaths = <String>[
  '', // Pure color
  Assets.images.whitePieceImage1.path,
  Assets.images.blackPieceImage1.path,
  Assets.images.whitePieceImage2.path,
  Assets.images.blackPieceImage2.path,
  Assets.images.whitePieceImage3.path,
  Assets.images.blackPieceImage3.path,
  Assets.images.whitePieceImage4.path,
  Assets.images.blackPieceImage4.path,
  Assets.images.whitePieceImage5.path,
  Assets.images.blackPieceImage5.path,
  Assets.images.whitePieceImage6.path,
  Assets.images.blackPieceImage6.path,
  Assets.images.whitePieceImage7.path,
  Assets.images.blackPieceImage7.path,
  Assets.images.whitePieceImage8.path,
  Assets.images.blackPieceImage8.path,
];



class _PieceImagePicker extends StatefulWidget {
  const _PieceImagePicker();

  @override
  _PieceImagePickerState createState() => _PieceImagePickerState();
}

class _PieceImagePickerState extends State<_PieceImagePicker> {


  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('piece_image_picker_container'),
      color: DB().colorSettings.boardBackgroundColor,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Semantics(
        key: const Key('piece_image_picker_semantics'),
        label: S.of(context).pieceImage,
        child: ValueListenableBuilder<Box<DisplaySettings>>(
          key: const Key('piece_image_picker_value_listenable_builder'),
          valueListenable: DB().listenDisplaySettings,
          builder: (BuildContext context, Box<DisplaySettings> box, _) {
            final DisplaySettings displaySettings = box.get(
              DB.displaySettingsKey,
              defaultValue: const DisplaySettings(),
            )!;

            return Padding(
              key: const Key('piece_image_picker_padding'),
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                key: const Key('piece_image_picker_column'),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  _buildPlayerRow(
                    context,
                    S.of(context).player1,
                    displaySettings.whitePieceImagePath,
                    displaySettings.customWhitePieceImagePath,
                    (String asset) {
                      DB().displaySettings = displaySettings.copyWith(
                        whitePieceImagePath: asset,
                      );
                    },
                    displaySettings.blackPieceImagePath,
                    isPlayerOne: true,
                    displaySettings: displaySettings,
                  ),
                  const SizedBox(
                    key: Key('piece_image_picker_sized_box_player1'),
                    height: 20,
                  ),

                  _buildPlayerRow(
                    context,
                    S.of(context).player2,
                    displaySettings.blackPieceImagePath,
                    displaySettings.customBlackPieceImagePath,
                    (String asset) {
                      DB().displaySettings = displaySettings.copyWith(
                        blackPieceImagePath: asset,
                      );
                    },
                    displaySettings.whitePieceImagePath,
                    isPlayerOne: false,
                    displaySettings: displaySettings,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    BuildContext context,
    String playerLabel,
    String selectedImagePath,
    String? customImagePath,
    void Function(String) onImageSelected,
    String otherPlayerSelectedImagePath, {
    required bool isPlayerOne,
    required DisplaySettings displaySettings,
  }) {
    final ScrollController scrollController = ScrollController();


    const double aspectRatio = 1.0;

    return GestureDetector(
      key: isPlayerOne
          ? const Key('player1_row_gesture_detector')
          : const Key('player2_row_gesture_detector'),
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        scrollController.jumpTo(
          scrollController.offset - details.delta.dx,
        );
      },
      child: Listener(
        key: isPlayerOne
            ? const Key('player1_row_listener')
            : const Key('player2_row_listener'),
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            final double delta = event.scrollDelta.dy;
            scrollController.jumpTo(scrollController.offset + delta);
          }
        },
        child: Row(
          key:
              isPlayerOne ? const Key('player1_row') : const Key('player2_row'),
          children: <Widget>[
            Padding(
              key: isPlayerOne
                  ? const Key('player1_row_label_padding')
                  : const Key('player2_row_label_padding'),
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Text(
                playerLabel,
                key: isPlayerOne
                    ? const Key('player1_row_label_text')
                    : const Key('player2_row_label_text'),
                style: TextStyle(color: DB().colorSettings.boardLineColor),
              ),
            ),
            Expanded(
              key: isPlayerOne
                  ? const Key('player1_row_expanded')
                  : const Key('player2_row_expanded'),
              child: SizedBox(
                key: isPlayerOne
                    ? const Key('player1_row_sized_box')
                    : const Key('player2_row_sized_box'),
                height: 60,
                child: ListView.builder(
                  key: isPlayerOne
                      ? const Key('player1_row_list_view_builder')
                      : const Key('player2_row_list_view_builder'),
                  scrollDirection: Axis.horizontal,
                  itemCount: _pieceBgPaths.length + 1,

                  controller: scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < _pieceBgPaths.length) {
                      final String asset = _pieceBgPaths[index];
                      final bool isSelectable =
                          index == 0 || asset != otherPlayerSelectedImagePath;
                      return Padding(
                        key: Key(
                            'player${isPlayerOne ? '1' : '2'}_piece_padding_$index'),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: GestureDetector(
                          key: Key(
                              'player${isPlayerOne ? '1' : '2'}_piece_gesture_$index'),
                          onTap: isSelectable
                              ? () => onImageSelected(asset)
                              : null,
                          child: asset.isEmpty
                              ? _buildPureColorPiece(
                                  key: isPlayerOne
                                      ? const Key('player1_pure_color_piece')
                                      : const Key('player2_pure_color_piece'),
                                  isSelected: selectedImagePath == asset,
                                  isPlayerOne: isPlayerOne,
                                )
                              : _PieceImageItem(
                                  key: Key(
                                      'player${isPlayerOne ? '1' : '2'}_piece_image_item_$index'),
                                  asset: asset,
                                  isSelect: selectedImagePath == asset,
                                  isSelectable: isSelectable,
                                ),
                        ),
                      );
                    } else {

                      return Padding(
                        key: Key(
                            'player${isPlayerOne ? '1' : '2'}_custom_piece_padding'),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _CustomPieceImageItem(
                          key: isPlayerOne
                              ? const Key('player1_custom_piece_item')
                              : const Key('player2_custom_piece_item'),
                          isSelected: selectedImagePath == customImagePath,
                          customImagePath: customImagePath,
                          onSelect: () {

                            onImageSelected(customImagePath ?? '');
                          },
                          onPickImage: () => _pickImage(
                            context,
                            isPlayerOne: isPlayerOne,
                            displaySettings: displaySettings,
                            aspectRatio: aspectRatio,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              key: isPlayerOne
                  ? const Key('player1_row_right_padding')
                  : const Key('player2_row_right_padding'),
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                key: isPlayerOne
                    ? const Key('player1_row_right_container')
                    : const Key('player2_row_right_container'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPureColorPiece({
    required bool isSelected,
    required bool isPlayerOne,
    Key? key,
  }) {
    return Container(
      key: key,
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isPlayerOne
            ? DB().colorSettings.whitePieceColor
            : DB().colorSettings.blackPieceColor,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: isSelected
          ? const Align(
              key: Key('pure_color_piece_selected_icon'),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            )
          : null,
    );
  }


  Future<void> _pickImage(
    BuildContext context, {
    required bool isPlayerOne,
    required DisplaySettings displaySettings,
    required double aspectRatio,
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
              key: const Key('custom_piece_image_crop_page'),
              imageData: imageData,
              aspectRatio: aspectRatio,
              backgroundImageText: S.of(context).pieceImage,
              lineType: ReferenceLineType.circle,
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


            if (isPlayerOne) {
              DB().displaySettings = displaySettings.copyWith(
                customWhitePieceImagePath: filePath,
                whitePieceImagePath: filePath,
              );
            } else {
              DB().displaySettings = displaySettings.copyWith(
                customBlackPieceImagePath: filePath,
                blackPieceImagePath: filePath,
              );
            }
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


class _PieceImageItem extends StatelessWidget {
  const _PieceImageItem({
    required this.asset,
    this.isSelect = false,
    this.isSelectable = true,
    super.key,
  });

  final String asset;
  final bool isSelect;
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      key: Key('piece_image_item_opacity_$asset'),
      opacity: isSelectable ? 1.0 : 0.5,
      child: Stack(
        key: Key('piece_image_item_stack_$asset'),
        children: <Widget>[
          Container(
            key: Key('piece_image_item_container_$asset'),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(asset),
                fit: BoxFit.contain,
              ),
              border:
                  isSelect ? Border.all(color: Colors.green, width: 2) : null,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          if (isSelect)
            const Align(
              key: Key('piece_image_item_selected_icon'),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}





class _CustomPieceImageItem extends StatelessWidget {
  const _CustomPieceImageItem({
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
      key: const Key('custom_piece_image_gesture_detector'),


      onTap: customImagePath != null ? onSelect : onPickImage,
      child: Stack(
        key: const Key('custom_piece_image_stack'),
        children: <Widget>[

          Container(
            key: const Key('custom_piece_image_container'),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: customImagePath == null
                  ? Colors.grey // Grey color if no custom image is selected
                  : null,
              image: customImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(customImagePath!)),
                      fit: BoxFit.contain,
                    )
                  : null,
              border:
                  isSelected ? Border.all(color: Colors.green, width: 2) : null,
              borderRadius: BorderRadius.circular(8),
            ),

            child: customImagePath == null
                ? const Center(
                    key: Key('custom_piece_image_add_icon'),
                    child: Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          if (customImagePath != null)
            Center(
              key: const Key('custom_piece_image_edit_icon_center'),
              child: IconButton(
                key: const Key('custom_piece_image_edit_button'),
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: onPickImage,
                tooltip: S.of(context).chooseYourPicture,
              ),
            ),

          if (isSelected)
            const Align(
              key: Key('custom_piece_image_selected_icon'),
              child: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
