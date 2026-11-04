import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/db_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _currentPage = 1;
  final int _pageSize = 10;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        title: Text(
          _currentIndex == 0 ? 'Home' : 'My Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _currentIndex == 0 ? _buildHome() : _buildProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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

  Widget _buildHome() {
    final name = widget.user['name'] ?? 'User';

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
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search, color: Colors.indigo),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
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

        if (_searchQuery.isEmpty)
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
                  onPressed: _showAddRootCategoryDialog,
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

        // ── body: search results OR normal category list ───────
        Expanded(
          child: _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : _buildCategoryList(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    // Show all matching results without pagination
    return FutureBuilder<List<Category>>(
      future: DbService.searchCategories(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No results for "$_searchQuery"',
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
          itemBuilder: (context, i) => _searchResultCard(results[i]),
        );
      },
    );
  }

  Widget _searchResultCard(Category cat) {
    return FutureBuilder<List<Category>>(
      future: DbService.getCategoryPath(cat.id!),
      builder: (context, snapshot) {
        final path = snapshot.data ?? [cat];

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () =>
              _openCategoryPage(context, parentId: cat.id, title: cat.name),
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
                      // matched category name (highlighted)
                      _highlightedText(cat.name, _searchQuery),
                      if (path.length > 1) ...[
                        const SizedBox(height: 4),
                        // breadcrumb trail: Electronics › Android › Samsung
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

  // highlights the matched part of [text] in indigo bold
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

  // pagination state

  Widget _paginationControls(int totalCount) {
    final totalPages = (totalCount / _pageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
        ),
        Text('Page $_currentPage / $totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
        const SizedBox(width: 12),
        Text('Total: $totalCount'),
      ],
    );
  }

  Widget _buildCategoryList() {
    return FutureBuilder<int>(
      future: DbService.getChildrenCount(null),
      builder: (context, countSnap) {
        final totalCount = countSnap.data ?? 0;
        return Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: DbService.getChildrenPaged(
                  null,
                  _currentPage,
                  _pageSize,
                ),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final categories = snap.data ?? [];
                  if (categories.isEmpty) {
                    return Center(
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
                            'Tap Manage to add your first category',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _categoryCard(categories[i], isRoot: true),
                  );
                },
              ),
            ),
            _paginationControls(totalCount),
          ],
        );
      },
    );
  }

  Widget _categoryCard(Category cat, {bool isRoot = false}) {
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
          // main tappable area → drill into subcategories
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
              onTap: () =>
                  _openCategoryPage(context, parentId: cat.id, title: cat.name),
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

          // delete button
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(14),
            ),
            onTap: () => _confirmDeleteFromHome(cat),
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

  void _confirmDeleteFromHome(Category cat) {
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
              await DbService.deleteCategory(cat.id!);
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
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

  void _showAddRootCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Electronics',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              if (name.isEmpty) return;
              await DbService.addCategory(name, parentId: null);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) setState(() {});
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
      ),
    );
  }

  void _openCategoryPage(
    BuildContext context, {
    required int? parentId,
    required String title,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(parentId: parentId, title: title),
      ),
    ).then((_) => setState(() {})); // refresh home after returning
  }

  // ─── Profile Tab ─────────────────────────────────────────────────────────────

  Widget _buildProfile() {
    final name = widget.user['name'] ?? 'User';
    final email = widget.user['email'] ?? '-';
    final username = widget.user['username'] ?? '-';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.indigo,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 24),
                _profileRow(Icons.person, 'Full Name', name),
                const Divider(height: 20),
                _profileRow(Icons.alternate_email, 'Username', username),
                const Divider(height: 20),
                _profileRow(Icons.email_outlined, 'Email', email),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Category Page (reused at every level) ────────────────────────────────────

class CategoryPage extends StatefulWidget {
  final int? parentId;
  final String title;

  const CategoryPage({super.key, required this.parentId, required this.title});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int _currentPage = 1;
  final int _pageSize = 10;
  late Future<List<Category>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      // fetch paged children for current page
      _childrenFuture = DbService.getChildrenPaged(
        widget.parentId,
        _currentPage,
        _pageSize,
      );
    });
  }

  // pagination UI – always visible
  Widget _paginationControls(int totalCount) {
    final totalPages = (totalCount / _pageSize).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
        ),
        Text('Page $_currentPage / $totalPages'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
        const SizedBox(width: 12),
        Text('Total: $totalCount'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          widget.parentId == null ? 'Add Category' : 'Add Subcategory',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // ── List of sub‑categories (paged) ───────
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _childrenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
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
                          widget.parentId == null
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
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _buildTile(items[i]),
                );
              },
            ),
          ),
          // ── Pagination bar (always visible) ───────
          FutureBuilder<int>(
            future: DbService.getChildrenCount(widget.parentId),
            builder: (context, countSnap) {
              final total = countSnap.data ?? 0;
              final totalPages = (total / _pageSize).ceil();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text('Page $_currentPage / $totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text('Total: $total'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(Category cat) {
    return Dismissible(
      key: ValueKey(cat.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(cat),
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
            // tappable area → drill deeper
            Expanded(
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CategoryPage(parentId: cat.id, title: cat.name),
                    ),
                  ).then((_) => _reload());
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
                          widget.parentId == null
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

            // visible delete button
            InkWell(
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14),
              ),
              onTap: () => _confirmDelete(cat),
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

  void _showAddDialog() {
    // Existing dialog for subcategories (used in CategoryPage)
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.parentId == null ? 'New Category' : 'New Subcategory',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: widget.parentId == null
                ? 'e.g. Electronics'
                : 'e.g. Samsung',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              if (name.isEmpty) return;
              await DbService.addCategory(name, parentId: widget.parentId);
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
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
      ),
    );
  }

  // New dialog for adding a root category from HomeScreen
  void _showAddRootCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Electronics',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              if (name.isEmpty) return;
              await DbService.addCategory(name, parentId: null);
              if (ctx.mounted) Navigator.pop(ctx);
              _reload();
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
      ),
    );
  }

  Future<bool?> _confirmDelete(Category cat) async {
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
      await DbService.deleteCategory(cat.id!);
      _reload();
    }
    return confirmed;
  }
}
