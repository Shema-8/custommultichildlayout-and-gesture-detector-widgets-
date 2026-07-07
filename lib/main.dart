import 'package:flutter/material.dart';

void main() {
  runApp(const GestureDetectorDemoApp());
}

class GestureDetectorDemoApp extends StatelessWidget {
  const GestureDetectorDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const FileListScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class FileItem {
  final String id;
  final String name;
  final String size;
  final IconData icon;
  final Color color;

  const FileItem({
    required this.id,
    required this.name,
    required this.size,
    required this.icon,
    required this.color,
  });
}

final List<FileItem> demoFiles = [
  FileItem(id: '1', name: 'Project Report.pdf', size: '2.4 MB', icon: Icons.picture_as_pdf, color: Color(0xFFFF6B6B)),
  FileItem(id: '2', name: 'Design Assets.zip', size: '18.9 MB', icon: Icons.folder_zip, color: Color(0xFFFFB347)),
  FileItem(id: '3', name: 'Meeting Notes.docx', size: '340 KB', icon: Icons.description, color: Color(0xFF4ECDC4)),
  FileItem(id: '4', name: 'App Screenshot.png', size: '1.2 MB', icon: Icons.image, color: Color(0xFF6C63FF)),
];

// ─────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────
class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  State<FileListScreen> createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<FileItem> files = List.from(demoFiles);

  void _openFile(FileItem file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FileOpenScreen(file: file)),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _showContextMenu(BuildContext context, FileItem file, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      color: const Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        _menuItem('share', Icons.share_rounded, 'Share', const Color(0xFF6C63FF)),
        _menuItem('settings', Icons.settings_rounded, 'Settings', const Color(0xFF4ECDC4)),
        _menuItem('delete', Icons.delete_rounded, 'Delete', const Color(0xFFFF6B6B)),
      ],
    ).then((value) {
      if (value == null) return;
      if (value == 'delete') {
        _deleteFile(file);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${value.capitalize()} → ${file.name}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2A2A3E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _deleteFile(FileItem file) {
    setState(() {
      files.removeWhere((f) => f.id == file.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.name} deleted'),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              files.add(file);
              files.sort((a, b) => a.id.compareTo(b.id));
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Files', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('GestureDetector Demo', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF6C63FF)),
            tooltip: 'Profile',
            onPressed: _openProfile,
          ),
          IconButton(icon: const Icon(Icons.info_outline, color: Color(0xFF6C63FF)), onPressed: _showInfo),
        ],
      ),
      body: Column(
        children: [
          // ── FILE LIST ──
          Expanded(
            child: files.isEmpty
                ? _EmptyState(onRestore: () => setState(() => files = List.from(demoFiles)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: files.length,
                    itemBuilder: (context, index) => _FileCard(
                      file: files[index],
                      onTap: () => _openFile(files[index]),
                      onLongPress: (pos) => _showContextMenu(context, files[index], pos),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About GestureDetector', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const _InfoContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: Color(0xFF6C63FF))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILE CARD  ← The star of the show
// ─────────────────────────────────────────────
class _FileCard extends StatefulWidget {
  final FileItem file;
  final VoidCallback onTap;
  final ValueChanged<Offset> onLongPress;

  const _FileCard({required this.file, required this.onTap, required this.onLongPress});

  @override
  State<_FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<_FileCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scaleAnim,
      
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPressStart: (details) {
            widget.onLongPress(details.globalPosition);
          },
          onTapDown: (_) {
            setState(() => _isPressing = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressing = false);
            _controller.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressing = false);
            _controller.reverse();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isPressing ? const Color(0xFF252540) : const Color(0xFF1E1E32),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isPressing
                    ? widget.file.color.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.05),
              ),
              boxShadow: _isPressing
                  ? [BoxShadow(color: widget.file.color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1)]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.file.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.file.icon, color: widget.file.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  // Name & size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.file.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(widget.file.size,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                      ],
                    ),
                  ),
                  // Visual hint
                  Column(
                    children: [
                      Icon(Icons.touch_app_rounded, color: Colors.white.withValues(alpha: 0.2), size: 16),
                      const SizedBox(height: 2),
                      Icon(Icons.more_vert_rounded, color: Colors.white.withValues(alpha: 0.2), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILE OPEN SCREEN
// ─────────────────────────────────────────────
class FileOpenScreen extends StatelessWidget {
  final FileItem file;
  const FileOpenScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: file.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(file.icon, color: file.color, size: 52),
            ),
            const SizedBox(height: 24),
            Text(file.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(file.size, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app, color: Color(0xFF6C63FF), size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'This screen opened because you used onTap — a quick press triggers immediate action!',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUPPORTING WIDGETS (file list screen)
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onRestore;
  const _EmptyState({required this.onRestore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text('All files deleted', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRestore,
            icon: const Icon(Icons.restore),
            label: const Text('Restore Files'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoContent extends StatelessWidget {
  const _InfoContent();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('onTap', ' Quick press → opens immediately', Color(0xFF4ECDC4)),
      ('onLongPress', ' Hold 2–3s → shows options menu', Color(0xFF6C63FF)),
      ('onTapDown', ' Fires the moment finger touches', Color(0xFFFFB347)),
      ('onTapCancel', ' Fires if gesture is cancelled', Color(0xFFFF6B6B)),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'GestureDetector wraps any widget and listens for user gestures. It\'s invisible — it has no visual of its own.',
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.$3.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item.$1, style: TextStyle(color: item.$3, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.$2, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Profile-specific colors (kept separate from file-list palette) ──
const Color _violet = Color(0xFF7C3AED);
const Color _greyDark = Color(0xFF1F2937);
const Color _greyLight = Color(0xFF9CA3AF);
const Color _profileBg = Color(0xFF111827);




// ── Slot IDs for the custom layout ──
enum ProfileSlot {
  cover,
  avatar,
  name,
  stats,
}

// ── Layout delegate ──
class ProfileDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    // COVER
    layoutChild(
      ProfileSlot.cover,
      BoxConstraints.tight(
        Size(size.width, 120),
      ),
    );

    positionChild(
      ProfileSlot.cover,
      Offset.zero,
    );

    // AVATAR
    layoutChild(
      ProfileSlot.avatar,
      BoxConstraints.tight(
        Size(80, 80),
      ),
    );

    positionChild(
      ProfileSlot.avatar,
      Offset(
        size.width / 2 - 40,
        80,
      ),
    );

    // NAME
    layoutChild(
      ProfileSlot.name,
      BoxConstraints.tight(
        Size(size.width, 40),
      ),
    );

    positionChild(
      ProfileSlot.name,
      const Offset(0, 170),
    );

    // STATS
    layoutChild(
      ProfileSlot.stats,
      BoxConstraints.tight(
        Size(size.width, 60),
      ),
    );

    positionChild(
      ProfileSlot.stats,
      const Offset(0, 220),
    );
  }

  @override
  bool shouldRelayout(
      covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

// ── Profile screen (this is the "dashboard" the user sees) ──
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _profileBg,
      appBar: AppBar(
        backgroundColor: _profileBg,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: 340,
          height: 300,
          decoration: BoxDecoration(
            color: _greyDark,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomMultiChildLayout(
            delegate: ProfileDelegate(),
            children: [
              // COVER
              LayoutId(
                id: ProfileSlot.cover,
                child: Container(
                  color: _violet,
                  child: const Center(
                    child: Text(
                      'COVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // AVATAR
              LayoutId(
                id: ProfileSlot.avatar,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greyLight,
                    border: Border.all(
                      color: _greyDark,
                      width: 4,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),

              // NAME
              LayoutId(
                id: ProfileSlot.name,
                child: const Center(
                  child: Text(
                    'Shema',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // STATS
              LayoutId(
                id: ProfileSlot.stats,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: const [
                    StatItem(
                      title: 'Posts',
                      value: '120',
                    ),
                    StatItem(
                      title: 'Followers',
                      value: '3.5K',
                    ),
                    StatItem(
                      title: 'Following',
                      value: '250',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat item used inside the profile stats row ──
class StatItem extends StatelessWidget {
  final String title;
  final String value;

  const StatItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}