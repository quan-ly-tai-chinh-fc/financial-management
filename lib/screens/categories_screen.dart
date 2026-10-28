import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Future<void> _edit(BuildContext context, {Category? cat, required String type}) async {
    final app = context.read<AppState>();
    final name = TextEditingController(text: cat?.name ?? '');
    var icon = cat?.icon ?? '💳';
    var color = cat?.color ?? '#1796A4';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: Text(cat == null ? 'Thêm danh mục' : 'Sửa danh mục'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên danh mục')),
              const SizedBox(height: 14),
              EmojiColorPicker(icon: icon, color: color, onChanged: (i, col) => setS(() {
                    icon = i;
                    color = col;
                  })),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
            FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(80, 40)), onPressed: () => Navigator.pop(c, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (name.text.trim().length < 2) {
      if (context.mounted) snack(context, 'Tên danh mục tối thiểu 2 ký tự.');
      return;
    }
    await app.db.saveCategory(app.uid, id: cat?.id, name: name.text, type: type, icon: icon, color: color);
    app.bump();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        final tabs = DefaultTabController.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Danh mục'),
            bottom: const TabBar(tabs: [Tab(text: 'Chi tiêu'), Tab(text: 'Thu nhập')]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _edit(context, type: tabs.index == 0 ? 'expense' : 'income'),
            child: const Icon(Icons.add),
          ),
          body: TabBarView(children: [
            for (final type in const ['expense', 'income'])
              DataView<List<Category>>(
                load: () => app.db.categories(app.uid, type: type),
                builder: (context, list) => ListView(padding: const EdgeInsets.fromLTRB(12, 12, 12, 96), children: [
                  for (final c in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CatAvatar(icon: c.icon, color: c.color),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(c.isDefault ? 'Mặc định' : 'Tuỳ chỉnh'),
                        trailing: c.isDefault
                            ? null
                            : Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, cat: c, type: type)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: kExpense),
                                  onPressed: () async {
                                    if (await confirmDialog(context, 'Xoá danh mục "${c.name}"? Các giao dịch cũ sẽ chuyển thành "Khác".')) {
                                      await app.db.deleteCategory(app.uid, c.id);
                                      app.bump();
                                    }
                                  },
                                ),
                              ]),
                      ),
                    ),
                ]),
              ),
          ]),
        );
      }),
    );
  }
}
