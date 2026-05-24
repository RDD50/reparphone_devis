import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../models/app_data.dart';

class AboutScreen extends StatelessWidget {
  final AppData data;

  const AboutScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final profile = data.shopProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.appDisplayName,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Version $appVersion'),
                  const SizedBox(height: 12),
                  Text(profile.commercialText),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.store),
              title: Text(profile.shopName),
              subtitle: Text(
                [
                  profile.phone,
                  profile.email,
                  profile.address,
                ].where((item) => item.isNotEmpty).join('\n'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Cette application est un outil simple de gestion de réparations, clients, agenda et suivi financier. Elle ne remplace pas un logiciel certifié de comptabilité ou de facturation électronique obligatoire si la réglementation l’impose.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
