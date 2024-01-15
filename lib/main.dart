import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'map.dart';

/** Code generation */
part 'main.g.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env.local');
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

// StatelessWidget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${ref.watch(counterProvider)}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => MapboxPage(
                              mapboxPublicToken:
                                  dotenv.get('MAPBOX_PUBLIC_TOKEN'),
                            )),
                  );
                },
                child: const Text('Open Map'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ref.read(counterProvider.notifier).increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
