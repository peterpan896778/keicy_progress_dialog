library keicy_progress_dialog;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum ProgressDialogType { normal, download, spin }
enum Layout { row, column }

BuildContext? _context, _dismissingContext;
bool _barrierDismissible = true;
ProgressDialogType _progressDialogType = ProgressDialogType.normal;
Layout _layout = Layout.row;
Color _backgroundColor = Colors.white;
double _dialogElevation = 8.0, _borderRadius = 8.0;
Curve _insetAnimCurve = Curves.easeInOut;
double _width = 100;
double _height = 80;
double _progress = 0.0;
double _maxProgress = 100.0;
EdgeInsetsGeometry _padding = const EdgeInsets.all(15);
double _spacing = 20.0;
double _indicatorSize = 20;
Widget _progressWidget = SizedBox(
  width: _indicatorSize,
  height: _indicatorSize,
  child: CupertinoActivityIndicator(
    radius: _indicatorSize / 2,
  ),
);
TextStyle _progressTextStyle = const TextStyle(
  color: Colors.black,
  fontSize: 15.0,
  fontWeight: FontWeight.w400,
);
TextStyle _messageStyle = const TextStyle(
  color: Colors.black,
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
);
bool _isShowing = false;
Color? _spinColor;

class KeicyProgressDialog {
  _Body? _dialog;

  String _dialogMessage = "Please wait .....";

  KeicyProgressDialog(
    BuildContext? context, {
    bool? isDismissible,
    ProgressDialogType? type,
    Layout? layout,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    Curve? insetAnimCurve,
    double? width,
    double? height,
    String? message,
    double? progress,
    double? maxProgress,
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? indicatorSize,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
    Color? spinColor,
  }) {
    _context = context;
    _barrierDismissible = isDismissible ?? true;
    _progressDialogType = type ?? _progressDialogType;
    _layout = layout ?? _layout;

    if (_isShowing) return;

    _backgroundColor = backgroundColor ?? _backgroundColor;
    _borderRadius = borderRadius ?? _borderRadius;
    _dialogElevation = elevation ?? _dialogElevation;
    _insetAnimCurve = insetAnimCurve ?? _insetAnimCurve;
    _dialogMessage = message ?? _dialogMessage;
    _width = width ?? _width;
    _height = height ?? _height;
    if (_progressDialogType == ProgressDialogType.download) {
      _progress = progress ?? _progress;
    }
    _maxProgress = maxProgress ?? _maxProgress;
    _padding = padding ?? _padding;
    _spacing = spacing ?? _spacing;
    _indicatorSize = indicatorSize ?? _indicatorSize;
    _progressWidget = progressWidget ?? _progressWidget;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;
    _spinColor = spinColor;
  }

  static KeicyProgressDialog of(
    BuildContext? context, {
    bool? isDismissible,
    ProgressDialogType? type,
    Layout? layout,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    Curve? insetAnimCurve,
    double? width,
    double? height,
    String? message,
    double? progress,
    double? maxProgress,
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? indicatorSize,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
    Color? spinColor,
  }) {
    return KeicyProgressDialog(
      context,
      isDismissible: isDismissible,
      type: type,
      layout: layout,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation,
      insetAnimCurve: insetAnimCurve,
      message: message,
      width: width,
      height: height,
      progress: progress,
      maxProgress: maxProgress,
      padding: padding,
      spacing: spacing,
      indicatorSize: indicatorSize,
      progressWidget: progressWidget,
      progressTextStyle: progressTextStyle,
      messageTextStyle: messageTextStyle,
      spinColor: spinColor,
    );
  }

  void update({
    double? progress,
    double? maxProgress,
    String? message,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
  }) {
    if (_progressDialogType == ProgressDialogType.download) {
      _progress = progress ?? _progress;
    }

    _dialogMessage = message ?? _dialogMessage;
    _maxProgress = maxProgress ?? _maxProgress;
    _progressWidget = progressWidget ?? _progressWidget;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;

    if (_isShowing) _dialog!.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void dismiss() {
    if (_isShowing) {
      try {
        _isShowing = false;
        if (Navigator.of(_dismissingContext!).canPop()) {
          Navigator.of(_dismissingContext!).pop();
        }
      } catch (_) {}
    }
  }

  Future<bool> hide() {
    if (_isShowing) {
      try {
        _isShowing = false;
        Navigator.of(_dismissingContext!).pop(true);
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<bool> show() async {
    if (!_isShowing) {
      try {
        _dialog = _Body(message: _dialogMessage);
        showDialog<dynamic>(
          context: _context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            _dismissingContext = context;
            return WillPopScope(
              onWillPop: () async {
                _isShowing = false;
                return _barrierDismissible;
              },
              child: Dialog(
                backgroundColor: _backgroundColor,
                insetAnimationCurve: _insetAnimCurve,
                insetAnimationDuration: const Duration(milliseconds: 100),
                elevation: _dialogElevation,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
                child: (_progressDialogType == ProgressDialogType.spin) ? _CircularSpin() : _dialog,
              ),
            );
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(const Duration(milliseconds: 200));
        _isShowing = true;
        return true;
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }
}

// ignore: must_be_immutable
class _Body extends StatefulWidget {
  String? message;

  _Body({this.message});

  final _BodyState _dialog = _BodyState();

  update() {
    _dialog.update();
  }

  @override
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _BodyState extends State<_Body> {
  update() {
    setState(() {});
  }

  @override
  void dispose() {
    _isShowing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_layout == Layout.row) {
      return Container(
        width: _width,
        height: _height,
        padding: _padding,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _progressWidget,
              (widget.message! == "") ? const SizedBox() : SizedBox(width: _spacing),
              (widget.message! == "")
                  ? const SizedBox()
                  : (_progressDialogType == ProgressDialogType.normal)
                      ? Text(widget.message!, textAlign: TextAlign.justify, style: _messageStyle)
                      : Column(
                          children: <Widget>[
                            Text(widget.message!, style: _messageStyle),
                            const SizedBox(height: 15),
                            Text("$_progress/$_maxProgress", style: _progressTextStyle),
                          ],
                        ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: _width,
        height: _height,
        padding: _padding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _progressWidget,
              (widget.message! == "") ? const SizedBox() : SizedBox(width: _spacing),
              (widget.message! == "")
                  ? const SizedBox()
                  : _progressDialogType == ProgressDialogType.normal
                      ? Text(widget.message!, textAlign: TextAlign.justify, style: _messageStyle)
                      : Column(
                          children: <Widget>[
                            Text(widget.message!, style: _messageStyle),
                            const SizedBox(height: 15),
                            Text("$_progress/$_maxProgress", style: _progressTextStyle),
                          ],
                        ),
            ],
          ),
        ),
      );
    }
  }
}

class _CircularSpin extends StatefulWidget {
  const _CircularSpin({Key? key}) : super(key: key);

  @override
  __CircularSpinState createState() => __CircularSpinState();
}

class __CircularSpinState extends State<_CircularSpin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      padding: _padding,
      child: Center(
        child: Container(
          width: _width,
          height: _height,
          padding: _padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SpinKitFadingCircle(
            color: _spinColor,
            size: _indicatorSize,
          ),
        ),
      ),
    );
  }
}
