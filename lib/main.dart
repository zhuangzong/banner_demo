import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var data = [
    {
      "videoId": 1183137,
      "posterPath":
          "https://www.themoviedb.org/t/p/w500/f46WvKEsBn98WJbPJcO47ZoKn6B.jpg",
      "voteAverage": "6.85",
      "backdropPath":
          "https://www.themoviedb.org/t/p/w780/mmpnUZebJhFXewEUuP7OGM4GuNF.jpg",
      "title": "Spaceman",
      "description":
          "During a research mission, an astronaut discovers that his marriage is in trouble. Luckily, he has the help of a mysterious creature hidden in his ship."
    },
    {
      "videoId": 1186899,
      "posterPath":
          "https://www.themoviedb.org/t/p/w500/aBkqu7EddWK7qmY4grL4I6edx2h.jpg",
      "voteAverage": "7.40",
      "backdropPath":
          "https://www.themoviedb.org/t/p/w780/H5HjE7Xb9N09rbWn1zBfxgI8uz.jpg",
      "title": "The Fall Guy",
      "description":
          "Fresh off an almost career-ending accident, stuntman Colt Seavers has to track down a missing movie star, solve a conspiracy and try to win back the love of his life while still doing his day job."
    },
    {
      "videoId": 622,
      "posterPath":
          "https://www.themoviedb.org/t/p/w500/kI4rtv5LTy5kfLwo2rbb367RTW.jpg",
      "voteAverage": "3.45",
      "backdropPath":
          "https://www.themoviedb.org/t/p/w780/tDpMjRb6JwYD5Iv4SY9Ayi8awdm.jpg",
      "title": "Bad Dinosaurs",
      "description":
          "A lovably mischievous Tyrannosaurus family explores their colorful prehistoric world, having slapstick fun with the silly dinosaurs who live there."
    }
  ];
  var imageFraction = 0.7;

  PageController pageImageController = PageController(viewportFraction: 0.7);
  PageController pageModelController = PageController();
  bool isScrolling = false;
  Timer? bannerTimer;
  int bannerIndex = 0;
  var currentModelIndex = 1;
  double pageOffset = 0.0;

  List<Map<String, dynamic>> get extendedList {
    List<Map<String, dynamic>> extendedList = [];
    extendedList = [data.last, ...data, data.first];
    return extendedList;
  }

  @override
  void initState() {
    super.initState();
    pageModelController.addListener(() {
      setState(() {
        pageOffset = pageModelController.page ??
            pageModelController.initialPage.toDouble();
      });
      pageImageController.jumpTo(pageModelController.offset * imageFraction);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentModelIndex = 1;
      if (pageModelController.hasClients) {
        pageModelController.jumpToPage(1000);
      }
      if (pageImageController.hasClients) {
        pageImageController.jumpToPage(1000);
      }
      pageOffset = 1000.0;
      bannerIndex = 1000;
      setBannerTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      backgroundColor: const Color(0xff333333),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            PageView.builder(
              controller: pageImageController,
              pageSnapping: false,
              itemBuilder: (context, index) {
                return _imageWidget(index);
              },
            ),
            SizedBox(
              height: 1000,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    if (notification.direction == ScrollDirection.idle) {
                      if (isScrolling) {
                        setBannerTimer();
                        isScrolling = false;
                      }
                    } else {
                      if (!isScrolling) {
                        cancelBannerTimer();
                        isScrolling = true;
                      }
                    }
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: pageModelController,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(height: 480),
                        _itemInformation(index),
                      ],
                    );
                  },
                  onPageChanged: (index) async {
                    setState(() {
                      bannerIndex = index;
                      currentModelIndex = (index + 1) % data.length;
                    });
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              child: SmoothPageIndicator(
                controller: pageModelController, // PageController
                count: 3,
                effect: const ExpandingDotsEffect(
                  dotWidth: 8,
                  dotHeight: 8,
                  activeDotColor: Colors.white,
                  dotColor: Color(0xffd9d9d9),
                ), // your preferred effect
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageWidget(int index) {
    final double angle = (pageOffset - index) * -0.15;
    bool isMiddleCard = (pageOffset - index).abs() < 1.0;
    final itemIndex = (index - 1) % data.length;
    double opacity = (pageOffset - index).abs() * 0.4;
    opacity = opacity.clamp(0.0, 1.0);
    var model = extendedList[itemIndex];
    double scale = 1 - (pageOffset - index).abs() * 0.2;
    bool leftOrRight = (pageOffset - index) > 0;
    double offsetX = (pageOffset - index).abs() * 30;
    double width = MediaQuery.of(context).size.width;
    double imageWidth = width * imageFraction;
    double imageHeight = imageWidth * 3 / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Transform.translate(
              offset: Offset(leftOrRight ? offsetX : -offsetX, 0),
              child: Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: angle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.network(
                          model['posterPath'],
                          width: imageWidth,
                          height: imageHeight,
                        ),
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Colors.black.withOpacity(opacity),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.6),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(6)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.red,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  model['voteAverage'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemInformation(int index) {
    final itemIndex = (index - 1) % data.length;
    Map<String, dynamic> model = extendedList[itemIndex];
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Text(
            model['title'] ?? '',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              model['description'] ?? '',
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xffb1b1b1),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text('Play', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 120,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white, size: 20),
                    SizedBox(width: 5),
                    Text('Favorite', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  setBannerTimer() {
    cancelBannerTimer();
    if (!pageModelController.hasClients) return;
    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentModelIndex < extendedList.length - 1) {
        bannerIndex++;
        if (pageModelController.page == 0) {
          pageModelController.jumpToPage(bannerIndex);
        } else {
          pageModelController.animateToPage(bannerIndex,
              duration: const Duration(milliseconds: 1500), curve: Curves.ease);
        }
      } else {
        bannerIndex = 0;
        pageModelController.jumpToPage(0);
      }
    });
  }


  cancelBannerTimer() {
    if (bannerTimer != null) {
      bannerTimer?.cancel();
    }
  }


  @override
  void dispose() {
    super.dispose();
    cancelBannerTimer();
    pageModelController.dispose();
    pageImageController.dispose();
  }
}
