import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'jokes_service.dart';

class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final _api = JokesService();
  final List<String> _jokes = [];
  final Set<String> _favorites = {};
  String _query = '';
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Загружает шутки и добавляет новые в начало списка без повторов
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh = await _api.fetchJokes();
      setState(() {
        for (final j in fresh.reversed) {
          if (!_jokes.contains(j)) _jokes.insert(0, j);
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toggleFavorite(String joke) {
    setState(() {
      if (!_favorites.add(joke)) _favorites.remove(joke);
    });
  }

  void _copy(String joke) {
    Clipboard.setData(ClipboardData(text: joke));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Скопировано')),
    );
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesScreen(
          favorites: _favorites,
          onRemove: _toggleFavorite,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final shown = _jokes
        .where((j) => j.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dad Jokes'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _favorites.isNotEmpty,
              label: Text('${_favorites.length}'),
              child: const Icon(Icons.favorite),
            ),
            onPressed: _openFavorites,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _load,
        icon: const Icon(Icons.add),
        label: const Text('Новая шутка'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск по шуткам',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(child: _buildBody(shown)),
        ],
      ),
    );
  }

  Widget _buildBody(List<String> shown) {
    if (_error != null && _jokes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Повторить')),
          ],
        ),
      );
    }
    if (shown.isEmpty) {
      return Center(child: Text(_loading ? '' : 'Ничего не найдено'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        itemCount: shown.length,
        itemBuilder: (context, i) {
          final joke = shown[i];
          final fav = _favorites.contains(joke);
          return Card(
            child: ListTile(
              title: Text(joke),
              onLongPress: () => _copy(joke),
              trailing: IconButton(
                icon: Icon(
                  fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? Colors.red : null,
                ),
                onPressed: () => _toggleFavorite(joke),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatefulWidget {
  final Set<String> favorites;
  final void Function(String) onRemove;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.onRemove,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final items = widget.favorites.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: items.isEmpty
          ? const Center(child: Text('Пока пусто'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  title: Text(items[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      widget.onRemove(items[i]);
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
