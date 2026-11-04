import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/home_provider.dart';
import 'category_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(parentId: null)),
      ],
      child: _HomeView(user: user),
    );
  }
}

class _HomeView extends StatelessWidget {
  final Map<String, dynamic> user;

  const _HomeView({required this.user});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: Text(
          homeProvider.currentIndex == 0 ? 'Home' : 'My Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: homeProvider.currentIndex == 0
          ? _buildHome(context, homeProvider, categoryProvider)
          : ProfileScreen(user: user),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: homeProvider.currentIndex,
        onTap: (index) => context.read<HomeProvider>().setIndex(index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHome(
    BuildContext context,
    HomeProvider homeProvider,
    CategoryProvider categoryProvider,
  ) {
    final name = user['name'] ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Color(0xFF7986CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back 👋',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            onChanged: (val) => context.read<HomeProvider>().search(val),
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              suffixIcon: homeProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () =>
                          context.read<HomeProvider>().clearSearch(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
              ),
            ),
          ),
        ),

        if (homeProvider.searchQuery.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddRootCategoryDialog(
                    context,
                    categoryProvider,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Category'),
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
              ],
            ),
          ),

        Expanded(
          child: homeProvider.searchQuery.isNotEmpty
              ? _buildSearchResults(context, homeProvider, categoryProvider)
              : _buildCategoryList(context, categoryProvider),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    HomeProvider homeProvider,
    CategoryProvider categoryProvider,
  ) {
    if (homeProvider.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    final results = homeProvider.searchResults;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No results for "${homeProvider.searchQuery}"',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _searchResultCard(
        context,
        homeProvider,
        categoryProvider,
        results[i],
      ),
    );
  }

  Widget _searchResultCard(
    BuildContext context,
    HomeProvider homeProvider,
    CategoryProvider categoryProvider,
    Category cat,
  ) {
    return FutureBuilder<List<Category>>(
      future: homeProvider.getCategoryPath(cat.id!),
      builder: (context, snapshot) {
        final path = snapshot.data ?? [cat];

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openCategoryPage(
            context,
            categoryProvider,
            parentId: cat.id,
            title: cat.name,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _highlightedText(cat.name, homeProvider.searchQuery),
                      if (path.length > 1) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (int i = 0; i < path.length; i++) ...[
                              if (i > 0)
                                const Icon(
                                  Icons.chevron_right,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              Text(
                                path[i].name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: i == path.length - 1
                                      ? Colors.indigo
                                      : Colors.grey,
                                  fontWeight: i == path.length - 1
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _highlightedText(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchStart = lowerText.indexOf(lowerQuery);

    if (matchStart == -1) {
      return Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      );
    }

    final matchEnd = matchStart + query.length;
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (matchStart > 0) TextSpan(text: text.substring(0, matchStart)),
          TextSpan(
            text: text.substring(matchStart, matchEnd),
            style: const TextStyle(
              color: Colors.indigo,
              backgroundColor: Color(0xFFE8EAF6),
            ),
          ),
          if (matchEnd < text.length) TextSpan(text: text.substring(matchEnd)),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
    return Column(
      children: [
        Expanded(
          child: categoryProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : categoryProvider.categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No categories yet',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap Add Category to add your first category',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: categoryProvider.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _categoryCard(
                        context,
                        categoryProvider,
                        categoryProvider.categories[i],
                      ),
                    ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: categoryProvider.currentPage > 1
                    ? () => categoryProvider.prevPage()
                    : null,
              ),
              Text(
                'Page ${categoryProvider.currentPage} / ${categoryProvider.totalPages == 0 ? 1 : categoryProvider.totalPages}',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: categoryProvider.currentPage < categoryProvider.totalPages
                    ? () => categoryProvider.nextPage()
                    : null,
              ),
              const SizedBox(width: 12),
              Text('Total: ${categoryProvider.totalCount}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryCard(
    BuildContext context,
    CategoryProvider provider,
    Category cat,
  ) {
    return Container(
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
              onTap: () => _openCategoryPage(
                context,
                provider,
                parentId: cat.id,
                title: cat.name,
              ),
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
                      child: const Icon(
                        Icons.folder_outlined,
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
            onTap: () => _showEditDialogFromHome(context, provider, cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
            onTap: () => _confirmDeleteFromHome(context, provider, cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
    );
  }

  void _showEditDialogFromHome(
    BuildContext context,
    CategoryProvider provider,
    Category cat,
  ) {
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
            title: const Text(
              'Edit Category',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                hintText: 'Category name',
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
                  final exists = await provider.checkExists(
                    name,
                    excludeId: cat.id,
                  );
                  if (exists) {
                    setDialogState(
                      () => errorText = 'Category "$name" already exists',
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

  void _showAddRootCategoryDialog(
    BuildContext context,
    CategoryProvider provider,
  ) {
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
            title: const Text(
              'Add Category',
              style: TextStyle(fontWeight: FontWeight.bold),
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
                hintText: 'e.g. Electronics',
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
                      () => errorText = 'Category "$name" already exists',
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

  void _confirmDeleteFromHome(
    BuildContext context,
    CategoryProvider provider,
    Category cat,
  ) {
    showDialog(
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteCategory(cat.id!);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openCategoryPage(
    BuildContext context,
    CategoryProvider provider, {
    required int? parentId,
    required String title,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(parentId: parentId, title: title),
      ),
    ).then((_) => provider.loadCategories());
  }
}
