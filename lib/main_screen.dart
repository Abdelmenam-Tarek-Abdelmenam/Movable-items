import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'models.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<PageModel> pagesDataBase = [
    PageModel("First Page", [
      BoxModel("Red Card", Colors.red),
      BoxModel("green Card", Colors.green),
      BoxModel("blue Card", Colors.blue),
      BoxModel("grey Card", Colors.grey)
    ]),
    PageModel("Second Page", [
      BoxModel("amber Card", Colors.amber),
      BoxModel("deepOrange Card", Colors.deepOrange),
      BoxModel("indigo Card", Colors.indigo)
    ]),
    PageModel("Third Page", [
      BoxModel("pink Card", Colors.pink),
      BoxModel("purple Card", Colors.deepPurple),
      BoxModel("teal Card", Colors.tealAccent),
    ]),
  ];

  PageController pageViewController = PageController();
  int activeIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Row(
              children: [
                leftCorner(),
                Expanded(
                  child: PageView.builder(
                      controller: pageViewController,
                      itemCount: pagesDataBase.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return DragTarget<List<int>>(
                          onAccept: (data) {
                            int oldPage = data[0];
                            int boxIndex = data[1];
                            BoxModel box =
                                pagesDataBase[oldPage].devices[boxIndex];
                            pagesDataBase[index].devices.add(box);
                            pagesDataBase[oldPage].devices.removeAt(boxIndex);
                            activeIndex = -1;
                            setState(() {});
                          },
                          onWillAccept: (data) {
                            return data?[0] != index;
                          },
                          builder: (_, __, ___) => Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  pagesDataBase[index].name,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 4.0,
                                      crossAxisSpacing: 4.0,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, dIndex) {
                                      return boxBuilder(context, dIndex, index);
                                    },
                                    itemCount:
                                        pagesDataBase[index].devices.length,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                rightCorner(),
              ],
            ),
          ),
          dotIndicator(),
        ]),
      ),
    );
  }

  Widget boxBuilder(BuildContext context, int index, int pageIndex) {
    BoxModel box = pagesDataBase[pageIndex].devices[index];
    return DragTarget<List<int>>(
      onWillAccept: (data) {
        int oldPage = data![0];
        int oldIndex = data[1];
        if (index == oldIndex && pageIndex == oldPage) {
          return false;
        } else {
          activeIndex = index;
          setState(() {});
          return true;
        }
      },
      onLeave: (data) {
        activeIndex = -1;
      },
      onAccept: (data) {
        int oldPage = data[0];
        int oldIndex = data[1];
        pagesDataBase[pageIndex]
            .devices
            .insert(index, pagesDataBase[oldPage].devices.removeAt(oldIndex));
        activeIndex = -1;
        setState(() {});
      },
      builder: (context, data, rejectedData) {
        return Opacity(
          opacity: index == activeIndex ? 0.5 : 1,
          child: LongPressDraggable<List<int>>(
            data: [pageIndex, index],
            childWhenDragging: Container(
                //key: dynamicKey
                ),
            feedback: Material(
              color: Colors.transparent,
              type: MaterialType.card,
              child: boxDesign(box),
            ),
            child: boxDesign(box),
          ),
        );
      },
    );
  }

  Widget boxDesign(BoxModel box) => Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: box.color,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Center(
          child: Text(
            box.name,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );

  Widget leftCorner() => DragTarget(
        onWillAccept: (data) {
          pageViewController.previousPage(
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
          return true;
        },
        builder: (context, data, rejectedData) {
          return Container(
            width: 10,
          );
        },
      );

  Widget rightCorner() => DragTarget(
        onWillAccept: (data) {
          pageViewController.nextPage(
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
          return false;
        },
        builder: (context, data, rejectedData) {
          return Container(
            width: 10,
          );
        },
      );

  Widget dotIndicator() => Padding(
        padding: const EdgeInsets.all(10),
        child: SmoothPageIndicator(
          onDotClicked: (val) {
            pageViewController.animateToPage(val,
                duration: const Duration(seconds: 1), curve: Curves.easeIn);
          },
          controller: pageViewController, //PageController(),
          count: pagesDataBase.length,
          effect: const SwapEffect(
            spacing: 8,
            dotWidth: 8,
            dotHeight: 8,
            activeDotColor: Colors.blue,
          ),
        ),
      );
}
