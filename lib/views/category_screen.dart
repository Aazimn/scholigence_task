import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatelessWidget {
  final int? parentId;
  final String title;

  const CategoryScreen({
    super.key,
    required this.parentId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryProvider(parentId: parentId),
      child: _CategoryView(title: title, parentId: parentId),
    );
  }
}

typedef CategoryPage = CategoryScreen;

class _CategoryView extends StatelessWidget {
  final String title;
  final int? parentId;

  const _CategoryView({
    required this.title,
    required this.parentId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final isRoot = parentId == null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 70,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isRoot
                                  ? 'No categories yet'
                                  : 'No subcategories yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap + to add one',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                        itemCount: provider.categories.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _buildTile(
                          context,
                          provider,
                          provider.categories[i],
                          isRoot: isRoot,
                        ),
                      ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddDialog(context, provider, isRoot: isRoot),
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                isRoot ? 'Add Category' : 'Add Subcategory',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: provider.currentPage > 1
                      ? () => provider.prevPage()
                      : null,
                ),
                Text('Page ${provider.currentPage} / ${provider.totalPages == 0 ? 1 : provider.totalPages}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: provider.currentPage < provider.totalPages
                      ? () => provider.nextPage()
                      : null,
                ),
                const SizedBox(width: 12),
                Text('Total: ${provider.totalCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    CategoryProvider provider,
    Category cat, {
    required bool isRoot,
  }) {
    return Dismissible(
      key: ValueKey(cat.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, provider, cat),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(
                        parentId: cat.id,
                        title: cat.name,
                      ),
                    ),
                  ).then((_) => provider.loadCategories());
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isRoot
                              ? Icons.folder_outlined
                              : Icons.subdirectory_arrow_right,
                          color: Colors.indigo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),

            InkWell(
              onTap: () => _showEditDialog(context, provider, cat, isRoot: isRoot),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.indigo,
                  size: 22,
                ),
              ),
            ),

            InkWell(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14),
              ),
              onTap: () => _confirmDelete(context, provider, cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(14),
                  ),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    CategoryProvider provider,
    Category cat, {
    required bool isRoot,
  }) {
    final controller = TextEditingController(text: cat.name);
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isRoot ? 'Edit Category' : 'Edit Subcategory',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() => errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'Name',
                errorText: errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() => errorText = 'Name cannot be empty');
                    return;
                  }
                  if (name.toLowerCase() == cat.name.trim().toLowerCase()) {
                    if (name != cat.name) {
                      await provider.updateCategory(cat.id!, name);
                      if (ctx.mounted) Navigator.pop(ctx);
                    } else {
                      Navigator.pop(ctx);
                    }
                    return;
                  }
                  final exists = await provider.checkExists(name, excludeId: cat.id);
                  if (exists) {
                    setDialogState(
                      () => errorText =
                          '${isRoot ? "Category" : "Subcategory"} "$name" already exists',
                    );
                    return;
                  }
                  await provider.updateCategory(cat.id!, name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    CategoryProvider provider, {
    required bool isRoot,
  }) {
    final controller = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              isRoot ? 'New Category' : 'New Subcategory',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (errorText != null) {
                  setDialogState(() => errorText = null);
                }
              },
              decoration: InputDecoration(
                hintText: isRoot ? 'e.g. Electronics' : 'e.g. Samsung',
                errorText: errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isEmpty) {
                    setDialogState(() => errorText = 'Name cannot be empty');
                    return;
                  }
                  final exists = await provider.checkExists(name);
                  if (exists) {
                    setDialogState(
                      () => errorText =
                          '${isRoot ? "Category" : "Subcategory"} "$name" already exists',
                    );
                    return;
                  }
                  await provider.addCategory(name);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    CategoryProvider provider,
    Category cat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Delete "${cat.name}" and all its subcategories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteCategory(cat.id!);
    }
    return confirmed;
  }
}
