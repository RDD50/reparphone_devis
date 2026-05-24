import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../services/storage_service.dart';
import '../agenda/agenda_screen.dart';
import '../clients/client_list_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../plus/plus_screen.dart';
import '../repairs/repair_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;
  AppData data = AppData.empty();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final loadedData = await StorageService.loadData();

    setState(() {
      data = loadedData;
      loading = false;
    });
  }

  Future<void> updateData(AppData updatedData) async {
    setState(() {
      data = updatedData;
    });

    await StorageService.saveData(updatedData);
  }

  void openTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screens = [
      DashboardScreen(
        data: data,
        onDataChanged: updateData,
        openTab: openTab,
      ),
      RepairListScreen(
        data: data,
        onDataChanged: updateData,
      ),
      ClientListScreen(
        data: data,
        onDataChanged: updateData,
      ),
      AgendaScreen(
        data: data,
        onDataChanged: updateData,
      ),
      PlusScreen(
        data: data,
        onDataChanged: updateData,
      ),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: openTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Dossiers',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}
