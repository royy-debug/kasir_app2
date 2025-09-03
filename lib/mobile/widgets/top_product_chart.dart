import 'package:flutter/material.dart';

class TopProductChart extends StatelessWidget {
  final Map<String, int> obatCount;

  const TopProductChart({
    super.key,
    required this.obatCount,
  });

  @override
  Widget build(BuildContext context) {
    final sortedEntries = obatCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.take(3).map((entry) {
        return ListTile(
          leading: const Icon(Icons.star, color: Colors.orange),
          title: Text(entry.key),
          trailing: Text("${entry.value}x terjual"),
        );
      }).toList(),
    );
  }
}
