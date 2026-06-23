import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../account/account_screen.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;
  const SpaceScreen({super.key, required this.space});

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.space.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(spaceId: widget.space.id),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search accounts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Theme.of(context).cardTheme.color,
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Accounts List
            Expanded(
              child: StreamBuilder<List<Account>>(
                stream: db.searchAccounts(widget.space.id, _searchQuery),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final accounts = snapshot.data!;

                  if (accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vpn_key_outlined, size: 64, color: Colors.grey.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? 'No accounts in this space' : 'No matching accounts found',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          if (_searchQuery.isEmpty)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountScreen(spaceId: widget.space.id),
                                  ),
                                );
                              },
                              child: const Text('Add First Account'),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final account = accounts[index];
                      final initial = account.accountName.isNotEmpty ? account.accountName[0].toUpperCase() : '?';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: account.isFavorite ? Colors.amber.withOpacity(0.15) : const Color(0xFF3B82F6).withOpacity(0.1),
                            foregroundColor: account.isFavorite ? Colors.amber : const Color(0xFF3B82F6),
                            child: Text(initial, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  account.accountName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (account.isFavorite)
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                          subtitle: Text(
                            account.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Favorite Toggle Button
                              IconButton(
                                icon: Icon(
                                  account.isFavorite ? Icons.star : Icons.star_border,
                                  color: account.isFavorite ? Colors.amber : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  await db.updateAccount(account.copyWith(
                                    isFavorite: !account.isFavorite,
                                  ));
                                },
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccountScreen(
                                  spaceId: widget.space.id,
                                  account: account,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
