import 'package:flutter/material.dart';
import 'jokes_service.dart';

class JokesList extends StatelessWidget {
  const JokesList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: JokesService().fetchJokes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        final jokes = snapshot.data!;
        return ListView.builder(
          itemCount: jokes.length,
          itemBuilder: (context, i) => Card(
            child: ListTile(title: Text(jokes[i])),
          ),
        );
      },
    );
  }
}
