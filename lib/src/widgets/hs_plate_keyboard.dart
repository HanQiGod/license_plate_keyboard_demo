import 'package:flutter/material.dart';

typedef HsPlateKeyboardDisplayBuilder = Widget Function(
  BuildContext context,
  String value,
);

typedef HsPlateKeyboardBuilder = Widget Function(
  BuildContext context,
  HsPlateKeyboardController controller,
  ValueChanged<String> onConfirm,
);

const List<String> _hsPlateProvinceKeys = [
  '京',
  '沪',
  '津',
  '渝',
  '冀',
  '晋',
  '蒙',
  '辽',
  '吉',
  '黑',
  '苏',
  '浙',
  '皖',
  '闽',
  '赣',
  '鲁',
  '豫',
  '鄂',
  '湘',
  '粤',
  '桂',
  '琼',
  '川',
  '贵',
  '云',
  '藏',
  '陕',
  '甘',
  '青',
  '宁',
  '新',
];

const List<String> _hsPlateLetterKeys = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'J',
  'K',
  'L',
  'M',
  'N',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

const List<String> _hsPlateAlphaNumericSpecialKeys = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'J',
  'K',
  'L',
  'M',
  'N',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
  '0',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '学',
  '警',
  '挂',
  '港',
  '澳',
];

String _normalizePlateValue(String value) {
  return value.toUpperCase();
}

const Duration _hsPlateKeyboardAnimationDuration = Duration(milliseconds: 250);
const Curve _hsPlateKeyboardShowCurve = Curves.easeOutCubic;
const Curve _hsPlateKeyboardHideCurve = Curves.easeInCubic;

/// 页面级车牌号键盘容器。
///
/// 将页面内容与车牌号键盘放在同一布局树中，输入框获取焦点后，
/// 键盘会像系统键盘一样占据底部空间，页面主体自动上推。
class HsPlateKeyboardPageContainer extends StatefulWidget {
  const HsPlateKeyboardPageContainer({
    super.key,
    required this.child,
    this.animationDuration = _hsPlateKeyboardAnimationDuration,
    this.animationCurve = _hsPlateKeyboardShowCurve,
  });

  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<HsPlateKeyboardPageContainer> createState() =>
      _HsPlateKeyboardPageContainerState();
}

class _HsPlateKeyboardPageContainerState
    extends State<HsPlateKeyboardPageContainer>
    with SingleTickerProviderStateMixin {
  _HsPlateKeyboardTextFieldState? _activeField;
  _HsPlateKeyboardTextFieldState? _displayField;
  bool _keyboardRebuildScheduled = false;
  late final AnimationController _keyboardAnimationController;

  @override
  void initState() {
    super.initState();
    _keyboardAnimationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.animationDuration,
    )..addStatusListener(_handleKeyboardAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(covariant HsPlateKeyboardPageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _keyboardAnimationController.duration = widget.animationDuration;
      _keyboardAnimationController.reverseDuration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _keyboardAnimationController
      ..removeStatusListener(_handleKeyboardAnimationStatusChanged)
      ..dispose();
    super.dispose();
  }

  void showKeyboard(_HsPlateKeyboardTextFieldState field) {
    if (_activeField == field && _displayField == field) {
      scheduleKeyboardRebuild();
      return;
    }

    if (!mounted) return;
    setState(() {
      _activeField = field;
      _displayField = field;
    });
    _keyboardAnimationController.forward();
  }

  void hideKeyboard(_HsPlateKeyboardTextFieldState field) {
    if (_activeField != field || !mounted) {
      return;
    }

    setState(() {
      _activeField = null;
    });
    _keyboardAnimationController.reverse();
  }

  void scheduleKeyboardRebuild() {
    if (_displayField == null || _keyboardRebuildScheduled || !mounted) {
      return;
    }

    _keyboardRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardRebuildScheduled = false;
      if (!mounted || _displayField == null) {
        return;
      }
      setState(() {});
    });
  }

  void _handleKeyboardAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.dismissed ||
        _activeField != null ||
        _displayField == null ||
        !mounted) {
      return;
    }

    setState(() {
      _displayField = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget keyboard = _displayField == null
        ? const SizedBox.shrink()
        : SizedBox(
            width: double.infinity,
            child: _displayField!._buildInlineKeyboard(context),
          );

    return _HsPlateKeyboardPageScope(
      state: this,
      child: Column(
        children: [
          Expanded(child: widget.child),
          _HsKeyboardRevealTransition(
            animation: _keyboardAnimationController,
            forwardCurve: widget.animationCurve,
            reverseCurve: _hsPlateKeyboardHideCurve,
            child: keyboard,
          ),
        ],
      ),
    );
  }
}

class _HsKeyboardRevealTransition extends StatelessWidget {
  const _HsKeyboardRevealTransition({
    required this.animation,
    required this.forwardCurve,
    required this.reverseCurve,
    required this.child,
  });

  final Animation<double> animation;
  final Curve forwardCurve;
  final Curve reverseCurve;
  final Widget child;

  double _resolveAnimationValue() {
    final double progress = animation.value.clamp(0.0, 1.0);
    final Curve curve = animation.status == AnimationStatus.reverse
        ? reverseCurve
        : forwardCurve;
    return curve.transform(progress);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.bottomCenter,
            heightFactor: _resolveAnimationValue(),
            child: child,
          ),
        );
      },
    );
  }
}

class _HsPlateKeyboardPageScope extends InheritedWidget {
  const _HsPlateKeyboardPageScope({
    required this.state,
    required super.child,
  });

  final _HsPlateKeyboardPageContainerState state;

  static _HsPlateKeyboardPageContainerState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_HsPlateKeyboardPageScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(_HsPlateKeyboardPageScope oldWidget) {
    return oldWidget.state != state;
  }
}

/// 车牌号键盘控制器。
class HsPlateKeyboardController extends ValueNotifier<String> {
  HsPlateKeyboardController([super.value = '']);

  void clear() {
    value = '';
  }

  void setValue(String nextValue) {
    value = _normalizePlateValue(nextValue);
  }
}

/// 自定义车牌号键盘。
class HsPlateKeyboard extends StatefulWidget {
  const HsPlateKeyboard({
    super.key,
    this.controller,
    this.initialValue = '',
    this.placeholder = '',
    this.maxLength = 8,
    this.confirmText = '确定',
    this.onChanged,
    this.onDelete,
    this.onConfirm,
    this.showDisplay = true,
    this.displayBuilder,
    this.padding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    this.spacing = 8,
    this.displayHeight = 52,
    this.keyHeight = 48,
    this.crossAxisCount = 10,
    this.backgroundColor = const Color(0xFFF3F5F9),
    this.displayBackgroundColor = Colors.white,
    this.keyBackgroundColor = Colors.white,
    this.actionBackgroundColor = const Color(0xFFE5E7EB),
    this.confirmBackgroundColor = const Color(0xFF0B3A5B),
    this.valueTextStyle,
    this.placeholderTextStyle,
    this.keyTextStyle,
    this.actionTextStyle,
    this.confirmTextStyle,
    this.deleteIcon,
    this.deleteIconColor = const Color(0xFF1F2937),
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.displayAlignment = Alignment.centerLeft,
  })  : assert(
          controller == null || initialValue == '',
          'controller 与 initialValue 不能同时使用',
        ),
        assert(maxLength > 0, 'maxLength 必须大于 0'),
        assert(crossAxisCount > 0, 'crossAxisCount 必须大于 0'),
        assert(spacing >= 0, 'spacing 不能小于 0'),
        assert(displayHeight > 0, 'displayHeight 必须大于 0'),
        assert(keyHeight > 0, 'keyHeight 必须大于 0');

  final HsPlateKeyboardController? controller;
  final String initialValue;
  final String placeholder;
  final int maxLength;
  final String confirmText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onConfirm;
  final bool showDisplay;
  final HsPlateKeyboardDisplayBuilder? displayBuilder;
  final EdgeInsetsGeometry padding;
  final double spacing;
  final double displayHeight;
  final double keyHeight;
  final int crossAxisCount;
  final Color backgroundColor;
  final Color displayBackgroundColor;
  final Color keyBackgroundColor;
  final Color actionBackgroundColor;
  final Color confirmBackgroundColor;
  final TextStyle? valueTextStyle;
  final TextStyle? placeholderTextStyle;
  final TextStyle? keyTextStyle;
  final TextStyle? actionTextStyle;
  final TextStyle? confirmTextStyle;
  final Widget? deleteIcon;
  final Color deleteIconColor;
  final BorderRadius borderRadius;
  final Alignment displayAlignment;

  @override
  State<HsPlateKeyboard> createState() => _HsPlateKeyboardState();
}

class _HsPlateKeyboardState extends State<HsPlateKeyboard> {
  static const ValueKey<String> _displayTextKey =
      ValueKey<String>('hs-plate-keyboard-display-text');

  late HsPlateKeyboardController _controller;
  late bool _ownsController;

  TextStyle get _valueTextStyle =>
      widget.valueTextStyle ??
      const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101828),
      );

  TextStyle get _placeholderTextStyle =>
      widget.placeholderTextStyle ??
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF98A2B3),
      );

  TextStyle get _keyTextStyle =>
      widget.keyTextStyle ??
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101828),
      );

  TextStyle get _actionTextStyle =>
      widget.actionTextStyle ??
      const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475467),
      );

  TextStyle get _confirmTextStyle =>
      widget.confirmTextStyle ??
      const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  List<String> get _currentKeys {
    final int length = _controller.value.length;
    if (length == 0) {
      return _hsPlateProvinceKeys;
    }
    if (length == 1) {
      return _hsPlateLetterKeys;
    }
    return _hsPlateAlphaNumericSpecialKeys;
  }

  String get _modeLabel {
    final int length = _controller.value.length;
    if (length == 0) {
      return '当前：省份简称';
    }
    if (length == 1) {
      return '当前：城市字母';
    }
    return '当前：字母 / 数字 / 特殊';
  }

  @override
  void initState() {
    super.initState();
    _bindController();
  }

  @override
  void didUpdateWidget(covariant HsPlateKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _disposeOwnedController();
      _bindController();
      return;
    }

    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _controller.value) {
      _controller.value = _normalizePlateValue(widget.initialValue);
    }
  }

  @override
  void dispose() {
    _disposeOwnedController();
    super.dispose();
  }

  void _bindController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        HsPlateKeyboardController(_normalizePlateValue(widget.initialValue));
    _controller.addListener(_handleControllerChanged);
  }

  void _disposeOwnedController() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateValue(String nextValue) {
    final String normalizedValue = _normalizePlateValue(nextValue);
    if (normalizedValue == _controller.value) {
      return;
    }
    _controller.value = normalizedValue;
    widget.onChanged?.call(normalizedValue);
  }

  void _handleInput(String input) {
    final String currentValue = _controller.value;
    if (currentValue.length >= widget.maxLength) {
      return;
    }
    _updateValue('$currentValue$input');
  }

  void _handleDelete() {
    final String currentValue = _controller.value;
    if (currentValue.isEmpty) {
      return;
    }
    _updateValue(currentValue.substring(0, currentValue.length - 1));
    widget.onDelete?.call();
  }

  void _handleConfirm() {
    widget.onConfirm?.call(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDisplay) ...[
                _buildDisplay(),
                SizedBox(height: widget.spacing),
              ],
              _buildKeyGrid(),
              SizedBox(height: widget.spacing),
              _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return SizedBox(
      width: double.infinity,
      height: widget.displayHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.displayBackgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValueListenableBuilder<String>(
            valueListenable: _controller,
            builder: (context, value, child) {
              if (widget.displayBuilder != null) {
                return widget.displayBuilder!(context, value);
              }

              final bool isEmpty = value.isEmpty;
              return Align(
                alignment: widget.displayAlignment,
                child: Text(
                  isEmpty ? widget.placeholder : value,
                  key: _displayTextKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isEmpty ? _placeholderTextStyle : _valueTextStyle,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeyGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalSpacing =
            widget.spacing * (widget.crossAxisCount - 1);
        final double itemWidth =
            ((constraints.maxWidth - totalSpacing) / widget.crossAxisCount)
                .clamp(0.0, double.infinity);

        return Wrap(
          spacing: widget.spacing,
          runSpacing: widget.spacing,
          children: _currentKeys
              .map(
                (value) => SizedBox(
                  width: itemWidth,
                  height: widget.keyHeight,
                  child: _buildTextKey(value),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      height: widget.keyHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.actionBackgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: Center(
                child: Text(
                  _modeLabel,
                  style: _actionTextStyle,
                ),
              ),
            ),
          ),
          SizedBox(width: widget.spacing),
          Expanded(
            child: _buildActionKey(
              key: const ValueKey<String>('hs-plate-keyboard-key-delete'),
              backgroundColor: widget.actionBackgroundColor,
              onTap: _handleDelete,
              child: widget.deleteIcon ??
                  Icon(
                    Icons.backspace_outlined,
                    color: widget.deleteIconColor,
                    size: 22,
                  ),
            ),
          ),
          SizedBox(width: widget.spacing),
          Expanded(
            child: _buildActionKey(
              key: const ValueKey<String>('hs-plate-keyboard-key-confirm'),
              backgroundColor: widget.confirmBackgroundColor,
              onTap: _handleConfirm,
              child: Center(
                child: Text(
                  widget.confirmText,
                  style: _confirmTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextKey(String value) {
    return _buildActionKey(
      key: ValueKey<String>('hs-plate-keyboard-key-$value'),
      backgroundColor: widget.keyBackgroundColor,
      onTap: () => _handleInput(value),
      child: Center(
        child: Text(value, style: _keyTextStyle),
      ),
    );
  }

  Widget _buildActionKey({
    required Key key,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Material(
      key: key,
      color: backgroundColor,
      borderRadius: widget.borderRadius,
      child: InkWell(
        borderRadius: widget.borderRadius,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// 点击输入框后获取焦点，并在底部显示 [HsPlateKeyboard] 的只读输入组件。
class HsPlateKeyboardTextField extends StatefulWidget {
  const HsPlateKeyboardTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue = '',
    this.enabled = true,
    this.hintText,
    this.decoration,
    this.style,
    this.textAlign = TextAlign.start,
    this.showCursor = true,
    this.enableInteractiveSelection = false,
    this.maxLength = 8,
    this.confirmText = '确定',
    this.keyboardPlaceholder = '',
    this.keyboardShowDisplay = false,
    this.closeOnConfirm = true,
    this.onTap,
    this.onChanged,
    this.onDelete,
    this.onConfirm,
    this.keyboardBuilder,
  }) : assert(
          controller == null || initialValue == '',
          'controller 与 initialValue 不能同时使用',
        );

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String initialValue;
  final bool enabled;
  final String? hintText;
  final InputDecoration? decoration;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool showCursor;
  final bool enableInteractiveSelection;
  final int maxLength;
  final String confirmText;
  final String keyboardPlaceholder;
  final bool keyboardShowDisplay;
  final bool closeOnConfirm;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onConfirm;
  final HsPlateKeyboardBuilder? keyboardBuilder;

  @override
  State<HsPlateKeyboardTextField> createState() =>
      _HsPlateKeyboardTextFieldState();
}

class _HsPlateKeyboardTextFieldState extends State<HsPlateKeyboardTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _textController;
  late HsPlateKeyboardController _keyboardController;
  late FocusNode _focusNode;
  late bool _ownsTextController;
  late bool _ownsFocusNode;
  late final AnimationController _keyboardOverlayAnimationController;

  bool _syncingFromText = false;
  bool _syncingFromKeyboard = false;
  bool _overlayRebuildScheduled = false;
  OverlayEntry? _keyboardOverlayEntry;
  final Object _tapRegionGroupId = Object();
  _HsPlateKeyboardPageContainerState? _pageContainerStateCache;

  _HsPlateKeyboardPageContainerState? get _pageContainerState =>
      _pageContainerStateCache;

  @override
  void initState() {
    super.initState();
    _keyboardOverlayAnimationController = AnimationController(
      vsync: this,
      duration: _hsPlateKeyboardAnimationDuration,
      reverseDuration: _hsPlateKeyboardAnimationDuration,
    );
    _bindObjects();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageContainerStateCache = _HsPlateKeyboardPageScope.maybeOf(context);
  }

  @override
  void didUpdateWidget(covariant HsPlateKeyboardTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller ||
        oldWidget.focusNode != widget.focusNode) {
      _unbindObjects(
        disposeTextController: true,
        disposeKeyboard: true,
        disposeFocusNode: true,
      );
      _bindObjects();
      return;
    }

    if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue &&
        widget.initialValue != _textController.text) {
      final String normalizedValue = _normalizePlateValue(widget.initialValue);
      _syncingFromText = true;
      _textController.text = normalizedValue;
      _textController.selection = TextSelection.collapsed(
        offset: normalizedValue.length,
      );
      _syncingFromText = false;
      _keyboardController.value = normalizedValue;
    }

    _scheduleKeyboardRebuild();
  }

  @override
  void dispose() {
    _unbindObjects(
      disposeTextController: true,
      disposeKeyboard: true,
      disposeFocusNode: true,
    );
    _keyboardOverlayAnimationController.dispose();
    super.dispose();
  }

  void _bindObjects() {
    _ownsTextController = widget.controller == null;
    _textController = widget.controller ??
        TextEditingController(text: _normalizePlateValue(widget.initialValue));
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _keyboardController =
        HsPlateKeyboardController(_normalizePlateValue(_textController.text));

    _textController.addListener(_handleTextControllerChanged);
    _keyboardController.addListener(_handleKeyboardControllerChanged);
    _focusNode.addListener(_handleFocusChanged);

    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          _syncSelectionToEnd();
          _pageContainerState?.showKeyboard(this);
          _showKeyboardOverlay();
        }
      });
    }
  }

  void _unbindObjects({
    bool disposeTextController = false,
    bool disposeKeyboard = false,
    bool disposeFocusNode = false,
  }) {
    _textController.removeListener(_handleTextControllerChanged);
    _keyboardController.removeListener(_handleKeyboardControllerChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _pageContainerState?.hideKeyboard(this);
    _removeKeyboardOverlay(immediately: true);

    if (disposeTextController && _ownsTextController) {
      _textController.dispose();
    }
    if (disposeKeyboard) {
      _keyboardController.dispose();
    }
    if (disposeFocusNode && _ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleTextControllerChanged() {
    if (_syncingFromKeyboard) {
      return;
    }

    final String normalizedValue = _normalizePlateValue(_textController.text);
    if (_textController.text != normalizedValue) {
      _textController.value = _textController.value.copyWith(
        text: normalizedValue,
        selection: TextSelection.collapsed(offset: normalizedValue.length),
        composing: TextRange.empty,
      );
    }

    if (_keyboardController.value == normalizedValue) {
      return;
    }

    _syncingFromText = true;
    _keyboardController.value = normalizedValue;
    _syncingFromText = false;
  }

  void _handleKeyboardControllerChanged() {
    if (_syncingFromText) {
      return;
    }

    final String value = _keyboardController.value;
    if (_textController.text != value) {
      _syncingFromKeyboard = true;
      _textController.value = _textController.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
        composing: TextRange.empty,
      );
      _syncingFromKeyboard = false;
    }

    widget.onChanged?.call(value);
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus) {
      _syncSelectionToEnd();
      _pageContainerState?.showKeyboard(this);
      _showKeyboardOverlay();
      return;
    }
    _pageContainerState?.hideKeyboard(this);
    _removeKeyboardOverlay();
  }

  void _syncSelectionToEnd() {
    final int offset = _textController.text.length;
    final TextSelection selection = TextSelection.collapsed(offset: offset);
    if (_textController.selection != selection) {
      _textController.selection = selection;
    }
  }

  void _handleTap() {
    widget.onTap?.call();
    _syncSelectionToEnd();
    if (_focusNode.hasFocus) {
      _showKeyboardOverlay();
      return;
    }
    _focusNode.requestFocus();
  }

  void _showKeyboardOverlay() {
    if (_pageContainerState != null) {
      return;
    }

    _keyboardController.setValue(_textController.text);
    if (_keyboardOverlayEntry != null) {
      _keyboardOverlayEntry!.markNeedsBuild();
      _keyboardOverlayAnimationController.forward();
      return;
    }

    final OverlayState overlay = Overlay.of(context);
    _keyboardOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _HsKeyboardRevealTransition(
            animation: _keyboardOverlayAnimationController,
            forwardCurve: _hsPlateKeyboardShowCurve,
            reverseCurve: _hsPlateKeyboardHideCurve,
            child: TapRegion(
              groupId: _tapRegionGroupId,
              child: Material(
                color: Colors.transparent,
                child: _buildKeyboardWidget(overlayContext),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_keyboardOverlayEntry!);
    _keyboardOverlayAnimationController.forward(from: 0);
  }

  void _removeKeyboardOverlay({bool immediately = false}) {
    final OverlayEntry? entry = _keyboardOverlayEntry;
    if (entry == null) {
      _overlayRebuildScheduled = false;
      return;
    }

    _overlayRebuildScheduled = false;

    if (immediately) {
      _keyboardOverlayAnimationController.stop();
      _keyboardOverlayAnimationController.value = 0;
      entry.remove();
      if (identical(_keyboardOverlayEntry, entry)) {
        _keyboardOverlayEntry = null;
      }
      return;
    }

    _keyboardOverlayAnimationController.reverse().whenCompleteOrCancel(() {
      if (!mounted ||
          _focusNode.hasFocus ||
          _pageContainerState != null ||
          !identical(_keyboardOverlayEntry, entry)) {
        return;
      }
      entry.remove();
      _keyboardOverlayEntry = null;
    });
  }

  void _scheduleKeyboardRebuild() {
    if (_pageContainerState != null) {
      _pageContainerState!.scheduleKeyboardRebuild();
      return;
    }

    if (_keyboardOverlayEntry == null || _overlayRebuildScheduled || !mounted) {
      return;
    }

    _overlayRebuildScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayRebuildScheduled = false;
      if (!mounted || _keyboardOverlayEntry == null) {
        return;
      }
      _keyboardOverlayEntry!.markNeedsBuild();
    });
  }

  Widget _buildInlineKeyboard(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroupId,
      child: _buildKeyboardWidget(context),
    );
  }

  Widget _buildKeyboardWidget(BuildContext context) {
    return widget.keyboardBuilder?.call(
          context,
          _keyboardController,
          _handleConfirm,
        ) ??
        HsPlateKeyboard(
          controller: _keyboardController,
          placeholder: widget.keyboardPlaceholder,
          maxLength: widget.maxLength,
          confirmText: widget.confirmText,
          showDisplay: widget.keyboardShowDisplay,
          onDelete: widget.onDelete,
          onConfirm: _handleConfirm,
        );
  }

  void _handleConfirm(String value) {
    widget.onConfirm?.call(value);
    if (widget.closeOnConfirm && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  InputDecoration _buildDecoration() {
    final InputDecoration baseDecoration =
        widget.decoration ?? const InputDecoration();
    return baseDecoration.copyWith(
      hintText: baseDecoration.hintText ?? widget.hintText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      groupId: _tapRegionGroupId,
      onTapOutside: (_) {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.enabled,
        readOnly: true,
        showCursor: widget.showCursor,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        keyboardType: TextInputType.none,
        style: widget.style,
        textAlign: widget.textAlign,
        maxLength: widget.maxLength,
        decoration: _buildDecoration(),
        onTap: _handleTap,
      ),
    );
  }
}
