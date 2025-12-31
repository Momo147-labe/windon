// import 'package:flutter/material.dart';
// import 'package:gestion_moderne_magasin/pages/products_page.dart';

// import '../widgets/sidebar.dart';
// import '../pages/dashboard_page.dart';
// import '../pages/sales_page.dart';
// import '../pages/purchases_page.dart';
// import '../pages/clients_page.dart';
// import '../pages/suppliers_page.dart';
// import '../pages/reports_page.dart';

// class MainLayout extends StatefulWidget {
//   const MainLayout({super.key});

//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   int _currentIndex = 0;
//   bool _isDark = false;

//   late final List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       DashboardPage(),
//       ProductsPage(),
//       SalesPage(),
//       PurchasesPage(),
//       ClientsPage(),
//       SuppliersPage(),
//       ReportsPage(), // 🆕
//     ];
//   }

//   void _onMenuSelected(int index) {
//     if (_currentIndex == index) return;
//     setState(() => _currentIndex = index);
//   }

//   void _toggleTheme() {
//     setState(() => _isDark = !_isDark);
//   }

//   void _logout() {
//     // TODO: remplacer par ta vraie logique (Firebase / Supabase)
//     debugPrint('Déconnexion...');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
//       theme: ThemeData.light(useMaterial3: true),
//       darkTheme: ThemeData.dark(useMaterial3: true),
//       home: Scaffold(
//         body: Row(
//           children: [
//             // 🔷 SIDEBAR FIXE
//             Sidebar(
//               currentIndex: _currentIndex,
//               onChanged: _onMenuSelected,
//               isDark: _isDark,
//               onToggleTheme: _toggleTheme,
//               onLogout: _logout,
//             ),

//             // 🔷 CONTENU CENTRAL (ne se recharge pas)
//             Expanded(
//               child: IndexedStack(
//                 index: _currentIndex,
//                 children: _pages,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
