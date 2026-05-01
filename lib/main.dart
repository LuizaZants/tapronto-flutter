import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/favorites_page.dart';
import 'pages/catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:            'AIzaSyDgBbsPVdCOsFWCtHEw2XDzCtYPKBQqq64',
      authDomain:        'ta-pronto-app-df47e.firebaseapp.com',
      projectId:         'ta-pronto-app-df47e',
      storageBucket:     'ta-pronto-app-df47e.firebasestorage.app',
      messagingSenderId: '203244764915',
      appId:             '1:203244764915:web:4e46e331ddb78d4a3ec186',
    ),
  );
  runApp(const TaProntoApp());
}

class TaProntoApp extends StatelessWidget {
  const TaProntoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tá Pronto!',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: AuthService().userStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
          }
          if (snap.hasData) return const MainNavigation();
          return const LoginPage();
        },
      ),
    );
  }
}

// ── Culinárias para a barra superior ─────────────────────────────────────────
const _cuisines = [
  {'label': 'Italiana',   'area': 'Italian'},
  {'label': 'Portuguesa', 'area': 'Portuguese'},
  {'label': 'Japonesa',   'area': 'Japanese'},
  {'label': 'Mexicana',   'area': 'Mexican'},
  {'label': 'Americana',  'area': 'American'},
  {'label': 'Indiana',    'area': 'Indian'},
  {'label': 'Francesa',   'area': 'French'},
  {'label': 'Chinesa',    'area': 'Chinese'},
  {'label': 'Tailandesa', 'area': 'Thai'},
  {'label': 'Grega',      'area': 'Greek'},
];

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;

  final _pages = const [HomePage(), SearchPage(), FavoritesPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(86),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
          ),
          child: SafeArea(
            child: Column(children: [
              // ── Logo + ações ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 80),
                    // Logo
                    RichText(text: const TextSpan(
                      text: 'Tá ',
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 20,
                          color: AppTheme.textDark, fontWeight: FontWeight.w700),
                      children: [TextSpan(
                        text: 'Pronto!',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900),
                      )],
                    )),
                    // Ações
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: AppTheme.textDark, size: 22),
                        onPressed: () => setState(() => _idx = 1),
                        tooltip: 'Buscar',
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: AppTheme.textDark, size: 22),
                        onPressed: () => setState(() => _idx = 2),
                        tooltip: 'Favoritos',
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
                        onPressed: () async => await AuthService().signOut(),
                        tooltip: 'Sair',
                      ),
                    ]),
                  ],
                ),
              ),
              // ── Barra de culinárias ────────────────────────────────────
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _cuisines.length,
                  separatorBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('·', style: TextStyle(color: AppTheme.divider, fontSize: 14)),
                  ),
                  itemBuilder: (ctx, i) {
                    final c = _cuisines[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => CatalogPage(
                              categoryLabel: c['label']!, categoryId: c['area']!, isArea: true))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(c['label']!,
                          style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12,
                            fontWeight: FontWeight.w500, letterSpacing: 0.3)),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _idx,
          onTap: (i) => setState(() => _idx = i),
          backgroundColor: AppTheme.surface,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_outlined),
                activeIcon: Icon(Icons.restaurant_menu), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite), label: 'Favoritos'),
          ],
        ),
      ),
    );
  }
}
