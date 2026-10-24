import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models.dart';

/// Lists device cameras. Overridden in tests, where no camera plugin runs.
final cameraListProvider = Provider<Future<List<CameraDescription>> Function()>(
  (ref) => availableCameras,
);

/// Outcome of the capture step. [photo] is null when the user skipped it;
/// the route itself returns null when the user cancelled.
class CaptureResult {
  final TransactionPhoto? photo;

  const CaptureResult(this.photo);
}

/// Wraps a picked or captured file until it is uploaded on save.
TransactionPhoto pickedPhoto(XFile file) => PickedTransactionPhoto(
  file,
  kIsWeb
      ? NetworkImage(file.path) as ImageProvider
      : FileImage(File(file.path)),
);

/// Opens the photo library. Returns null when cancelled or unavailable.
Future<TransactionPhoto?> pickFromLibrary(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  try {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    return file == null ? null : pickedPhoto(file);
  } on PlatformException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.photoPickError)));
    return null;
  }
}

/// Step 1 of adding a transaction: live camera, library, or skip.
class CapturePhotoScreen extends ConsumerStatefulWidget {
  const CapturePhotoScreen({super.key});

  @override
  ConsumerState<CapturePhotoScreen> createState() => _CapturePhotoScreenState();
}

class _CapturePhotoScreenState extends ConsumerState<CapturePhotoScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  FlashMode _flash = FlashMode.off;
  double _zoom = 1;
  double _maxZoom = 1;
  bool _unavailable = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// How long to wait for the live preview before falling back to the
  /// system camera (browsers may never answer the permission request).
  static const _previewTimeout = Duration(seconds: 8);

  Future<void> _initCamera() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await ref
            .read(cameraListProvider)()
            .timeout(_previewTimeout);
      }
      if (_cameras.isEmpty) throw CameraException('none', 'No camera');
      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize().timeout(_previewTimeout);
      await controller.setFlashMode(_flash);
      final maxZoom = await controller.getMaxZoomLevel();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _maxZoom = maxZoom;
        _zoom = 1;
        _unavailable = false;
      });
    } catch (_) {
      // No camera, permission denied or timed out (common in Safari and
      // home-screen web apps). The shutter then opens the system camera.
      if (mounted) setState(() => _unavailable = true);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final old = _controller;
    setState(() {
      _controller = null;
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    });
    await old?.dispose();
    await _initCamera();
  }

  Future<void> _toggleFlash() async {
    final next = _flash == FlashMode.off ? FlashMode.always : FlashMode.off;
    await _controller?.setFlashMode(next);
    setState(() => _flash = next);
  }

  Future<void> _setZoom(double zoom) async {
    await _controller?.setZoomLevel(zoom);
    setState(() => _zoom = zoom);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(CaptureResult(pickedPhoto(file)));
    } on CameraException {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Fallback when there is no live preview: the platform's own camera
  /// (on iPhone Safari, the native camera via the file picker).
  Future<void> _systemCamera() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (file != null) {
        Navigator.of(context).pop(CaptureResult(pickedPhoto(file)));
        return;
      }
    } catch (_) {
      // Permission denied or no camera picker available.
      messenger.showSnackBar(SnackBar(content: Text(l10n.photoPickError)));
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _library() async {
    final photo = await pickFromLibrary(context);
    if (photo != null && mounted) {
      Navigator.of(context).pop(CaptureResult(photo));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _PillButton(
                  label: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.92,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(44),
                      child: _buildViewfinder(l10n),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _Shutter(
              // Without a live preview the shutter opens the system camera.
              enabled: (_controller != null || _unavailable) && !_busy,
              tooltip: l10n.takePhoto,
              onPressed: _controller != null ? _capture : _systemCamera,
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary.withValues(alpha: 0.18),
                foregroundColor: scheme.primary,
                minimumSize: const Size(0, 52),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                shape: const StadiumBorder(),
              ),
              onPressed: _library,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.chooseFromLibrary),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              onPressed: () =>
                  Navigator.of(context).pop(const CaptureResult(null)),
              child: Text(l10n.skipPhoto),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildViewfinder(AppLocalizations l10n) {
    final controller = _controller;
    if (_unavailable || controller == null) {
      return Container(
        color: const Color(0xFF1F1F1F),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        alignment: Alignment.center,
        child: _unavailable
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.no_photography_outlined,
                    size: 44,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.cameraUnavailable,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              )
            : const CircularProgressIndicator(color: Colors.white54),
      );
    }

    final previewSize = controller.value.previewSize;
    Widget overlay(Widget child, Alignment alignment) => Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            // previewSize is landscape; the phone is portrait.
            width: previewSize?.height ?? 1,
            height: previewSize?.width ?? 1,
            child: CameraPreview(controller),
          ),
        ),
        overlay(
          _RoundIconButton(
            tooltip: _flash == FlashMode.off ? l10n.flashOn : l10n.flashOff,
            icon: _flash == FlashMode.off
                ? Icons.flash_off_rounded
                : Icons.flash_on_rounded,
            onPressed: _toggleFlash,
          ),
          Alignment.topLeft,
        ),
        if (_cameras.length > 1)
          overlay(
            _RoundIconButton(
              tooltip: l10n.switchCamera,
              icon: Icons.cameraswitch_rounded,
              onPressed: _switchCamera,
            ),
            Alignment.topRight,
          ),
        if (_maxZoom >= 2)
          overlay(
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final z in const [1.0, 2.0])
                    GestureDetector(
                      onTap: () => _setZoom(z),
                      child: Container(
                        width: 44,
                        height: 32,
                        alignment: Alignment.center,
                        child: Text(
                          '${z.toInt()}x',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _zoom == z
                                ? const Color(0xFFF5C84B)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Alignment.bottomCenter,
          ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PillButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        foregroundColor: Colors.white70,
        minimumSize: const Size(88, 44),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.45),
        foregroundColor: Colors.white,
        fixedSize: const Size(48, 48),
      ),
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}

/// Large white shutter with a gradient ring in the app's green accent.
class _Shutter extends StatelessWidget {
  final bool enabled;
  final String tooltip;
  final VoidCallback onPressed;

  const _Shutter({
    required this.enabled,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: enabled ? onPressed : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: Container(
              width: 92,
              height: 92,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    Color(0xFF4ADE9A),
                    Color(0xFF14B8A6),
                    Color(0xFF3B82F6),
                    Color(0xFF4ADE9A),
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF121212),
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
