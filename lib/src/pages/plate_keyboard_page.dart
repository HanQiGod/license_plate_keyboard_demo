import 'package:flutter/material.dart';

import '../widgets/hs_plate_keyboard.dart';

class PlateKeyboardPage extends StatefulWidget {
  const PlateKeyboardPage({super.key});

  @override
  State<PlateKeyboardPage> createState() => _PlateKeyboardPageState();
}

class _PlateKeyboardPageState extends State<PlateKeyboardPage> {
  final TextEditingController _fieldController = TextEditingController();
  final FocusNode _fieldFocusNode = FocusNode();

  String _confirmedValue = '';

  @override
  void initState() {
    super.initState();
    _fieldFocusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _fieldFocusNode.removeListener(_handleFocusChanged);
    _fieldController.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('车牌号键盘'),
      ),
      body: HsPlateKeyboardPageContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPreviewCard(theme),
            const SizedBox(height: 16),
            _buildFieldCard(),
            const SizedBox(height: 16),
            _buildActionCard(),
            const SizedBox(height: 16),
            const Text(
              '说明：输入框获取焦点后，会像系统键盘一样在页面底部出现车牌号键盘，并参与页面布局，内容不会被遮挡。',
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    final String currentValue = _fieldController.text;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '组件预览',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '当前车牌号',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentValue.isEmpty ? '--' : currentValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _fieldFocusNode.hasFocus ? '输入框状态：已获取焦点' : '输入框状态：未获取焦点',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _confirmedValue.isEmpty ? '最近一次确认：暂无' : '最近一次确认：$_confirmedValue',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '点击输入框唤起',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          HsPlateKeyboardTextField(
            controller: _fieldController,
            focusNode: _fieldFocusNode,
            hintText: '点击输入车牌号',
            keyboardShowDisplay: false,
            decoration: InputDecoration(
              hintText: '点击输入车牌号',
              filled: true,
              fillColor: const Color(0xFFF6F8FB),
              suffixIcon: const Icon(Icons.directions_car_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onTap: () => setState(() {}),
            onChanged: (_) => setState(() {}),
            onConfirm: (value) {
              setState(() {
                _confirmedValue = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value.isEmpty ? '当前没有可确认的内容' : '已确认：$value'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快捷操作',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: () => _setFieldValue('京A12345'),
                child: const Text('填入 京A12345'),
              ),
              OutlinedButton(
                onPressed: () => _setFieldValue('粤B12345D'),
                child: const Text('填入 粤B12345D'),
              ),
              OutlinedButton(
                onPressed: () => _setFieldValue(''),
                child: const Text('清空'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setFieldValue(String value) {
    _fieldController.value = _fieldController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
    setState(() {});
  }

  void _handleFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }
}
