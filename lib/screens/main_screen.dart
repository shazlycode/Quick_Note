import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keepnote/Helpers/ad_helper.dart';
import 'package:keepnote/providers/note_provider.dart';
import 'package:keepnote/screens/add_note_screen.dart';
import 'package:keepnote/screens/note_detail_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BannerAd _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;

  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _bottomBannerAd.load();
  }

// interstitial Ad

  InterstitialAd? _interstitialAd;

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _createInterstitialAd();
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
    }
  }

  void _instanceId() async {
    // await Firebase.initializeApp();
    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.instance.sendMessage();
    var token = await FirebaseMessaging.instance.getToken();
    print("Print Instance Token ID: " + token!);
  }

  @override
  void initState() {
    super.initState();
    _instanceId();
    _createBottomBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomBannerAd.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).bottomAppBarColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _showInterstitialAd();

          // _interstitialAd?.show();
          Navigator.pushNamed(context, AddNoteScreen.id);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  _showInterstitialAd();

                  //  _interstitialAd?.show();
                  Navigator.pushNamed(context, AddNoteScreen.id);
                },
                icon: const Icon(Icons.text_snippet)),
            // IconButton(
            //     onPressed: () {}, icon: const Icon(Icons.brush_outlined)),
            // IconButton(
            //     onPressed: () {}, icon: const Icon(Icons.image_outlined)),
            // IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none)),
          ],
        ),
        shape: const CircularNotchedRectangle(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Column(
              children: [
                Row(
                  children: const [
                    Text('NOTE'),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onChanged: (value) {
                    context.read<NoteProvider>().search(value);
                  },
                  decoration: const InputDecoration(
                    label: Text('Search Note'),
                    suffixIcon: Icon(MdiIcons.searchWeb),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                    future:
                        context.read<NoteProvider>().fetchAndSetData('notes'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Consumer<NoteProvider>(
                        child: const Text('No notes saved yet, Add new one!!!'),
                        builder: (context, np, ch) {
                          if (np.notes.isEmpty) {
                            return const Text(
                                'No notes saved yet, Add new one!!!');
                          }
                          return StaggeredGridView.countBuilder(
                              crossAxisCount: 2,
                              itemCount: np.notes.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Delete Note!!!'),
                                              content: const Text(
                                                  'Are you sure to delete this note?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child:
                                                        const Text('Cancel')),
                                                IconButton(
                                                    onPressed: () {
                                                      context
                                                          .read<NoteProvider>()
                                                          .deleteNot(np
                                                              .notes[index]
                                                              .id!);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ))
                                              ],
                                            ));
                                  },
                                  onTap: () {
                                    // _interstitialAd?.show();
                                    _showInterstitialAd();

                                    Navigator.pushNamed(context, NoteDetails.id,
                                        arguments: np.notes[index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: np.notes[index].color,
                                          border: Border.all(
                                              width: 1, color: Colors.grey),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        children: [
                                          Text(
                                            np.notes[index].title!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText2!
                                                .copyWith(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          ReadMoreText(
                                            np.notes[index].content!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .copyWith(fontSize: 18),
                                            trimLines: 4,
                                            colorClickableText: Colors.pink,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'Show more',
                                            trimExpandedText: 'Show less',
                                            moreStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // Text(
                                          //   np.notes[index].content!,
                                          //   style: Theme.of(context)
                                          //       .textTheme
                                          //       .bodyText1,
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              staggeredTileBuilder: (index) =>
                                  const StaggeredTile.fit(1));
                          // np.notes.isEmpty ? ch : const ListTile();
                        },
                      );
                    },
                  ),
                )),
                // if (_isBannerAdReady)
                //   Align(
                //     alignment: Alignment.topCenter,
                //     child: SizedBox(
                //       width: _bannerAd.size.width.toDouble(),
                //       height: _bannerAd.size.height.toDouble(),
                //       child: AdWidget(ad: _bannerAd),
                //     ),
                //   ),
                if (_isBottomBannerAdLoaded)
                  SizedBox(
                    height: _bottomBannerAd.size.height.toDouble(),
                    width: _bottomBannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
