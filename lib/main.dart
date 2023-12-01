import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Namer_App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var Favourites = <WordPair>[];

  void toggleFavourite([WordPair? wrdpair]) {
    wrdpair = wrdpair ?? current;

    if (Favourites.contains(wrdpair)) {
      Favourites.remove(wrdpair);
    } else {
      Favourites.add(wrdpair);
    }
    notifyListeners();
  }

  void deleteFavourites(var word) {
    Favourites.remove(word);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIdx = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    if (selectedIdx == 0) {
      page = GeneratorPage();
    } else if (selectedIdx == 1) {
      page = FavouritesPage();
    } else {
      throw UnimplementedError("No widget available for $selectedIdx");
    }
    var mainArea = Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: page,
    );

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 450) {
          return Column(
            children: [
              Expanded(child: mainArea),
              BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite_outlined), label: "Favourites"),
                ],
                currentIndex: selectedIdx,
                onTap: (value) {
                  setState(() {
                    selectedIdx = value;
                  });
                },
              ),
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 650,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text(
                          "Home",
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite_outlined),
                        label: Text(
                          "Favourites",
                        ),
                      ),
                    ],
                    selectedIndex: selectedIdx,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIdx = value;
                      });
                      print(selectedIdx);
                    },
                  ),
                ),
              ),
              Expanded(
                child: mainArea,
              ),
            ],
          );
        }
      }),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.Favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border_rounded;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(
            height: 10,
          ),
          BigCard(pair: pair),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                  print(appState.Favourites);
                },
                icon: Icon(icon),
                label: Text("Like"),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  print("Button Pressed");
                  appState.getNext();
                },
                child: Text("Next"),
              ),
            ],
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var theme = Theme.of(context);
    return Center(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "You have ${appState.Favourites.length} favourites :",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 400 / 80,
                ),
                children: [
                  ...appState.Favourites.map(
                    (e) => ListTile(
                      title: Text(
                        "$e",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      leading: IconButton(
                        onPressed: () {
                          appState.deleteFavourites(e);
                        },
                        icon: Icon(Icons.delete_outline),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first,
                  style: style.copyWith(fontWeight: FontWeight.w300),
                ),
                Text(
                  pair.second,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  var _key = GlobalKey();
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.historyListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final wrdpair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                  onPressed: () {
                    appState.toggleFavourite(wrdpair);
                  },
                  icon: appState.Favourites.contains(wrdpair)
                      ? Icon(Icons.favorite_outlined)
                      : SizedBox(),
                  label: Text(
                    wrdpair.asLowerCase,
                    semanticsLabel: wrdpair.asPascalCase,
                  ),),
            ),
          );
        },
      ),
    );
  }
}

// return Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Padding(
// padding: const EdgeInsets.all(30),
// child: Text('You have '
// '${appState.favorites.length} favorites:'),
// ),
// Expanded(
// // Make better use of wide windows with a grid.
// child: GridView(
// gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
// maxCrossAxisExtent: 400,
// childAspectRatio: 400 / 80,
// ),
// children: [
// for (var pair in appState.favorites)
// ListTile(
// leading: IconButton(
// icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
// color: theme.colorScheme.primary,
// onPressed: () {
// appState.removeFavorite(pair);
// },
// ),
// title: Text(
// pair.asLowerCase,
// semanticsLabel: pair.asPascalCase,
// ),
// ),
// ],
// ),
// ),
// ],
// );
