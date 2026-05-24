import 'package:flutter/material.dart';

import '../models/client.dart';

class ClientListItem extends StatelessWidget {
  final Client client;
  final VoidCallback onTap;

  const ClientListItem({
    super.key,
    required this.client,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            client.phone,
            client.email,
          ].where((item) => item.isNotEmpty).join(' • '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
