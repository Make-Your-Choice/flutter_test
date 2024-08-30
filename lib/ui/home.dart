import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../api/provider/token state/token_state_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late AppLifecycleState? _appState;
  late final AppLifecycleListener _appStateListener;

  @override
  void initState() {
    super.initState();
    // _appState = SchedulerBinding.instance.lifecycleState;

    // _appStateListener = AppLifecycleListener(
    //   onStateChange: (state) => _onStateChange(state),
    // );

  }

  // @override
  // void dispose() {
  //   _appStateListener.dispose();
  //   super.dispose();
  // }
  //
  // void _onStateChange(AppLifecycleState state) {
  //   switch(state) {
  //     case AppLifecycleState.detached: _deleteToken();
  //     case AppLifecycleState.paused: _deleteToken();
  //     case AppLifecycleState.resumed: {}
  //     case AppLifecycleState.inactive: {}
  //     case AppLifecycleState.hidden: {}
  //   }
  // }
  //
  // void _deleteToken() {
  //   var storage = const FlutterSecureStorage();
  //   storage.deleteAll();
  //
  // }

  @override
  Widget build(BuildContext context) {
    var tokenState = ref.watch(tokenStateProvider);
    return Scaffold(
        backgroundColor: const Color.fromRGBO(102, 82, 255, 1),
        body: Consumer(
    builder: (BuildContext context, WidgetRef ref, Widget? child) {
      return SizedBox(
        height: MediaQuery
            .of(context)
            .size
            .height,
        child: Stack(children: [
          Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.fitHeight,
            height: 400,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 80.0, horizontal: 40.0),
              height: MediaQuery
                  .of(context)
                  .size
                  .height - 370,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(children: [
                Image.asset('assets/images/logo.png', fit: BoxFit.fitHeight),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Personal task tracker',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Bottom text - bottom text',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(141, 141, 141, 1)),
                ),
                const SizedBox(
                  height: 70,
                ),
                GestureDetector(
                  onTap: () {
                    tokenState.when(
                        data: (data) => {
                          if(data == true) {
                            context.go('/tasks')
                          } else {
                            context.go('/sign-in')
                          }
                        },
                        error: (error, stackTrace) {
                          if(error is DioException) {
                            if(error.response?.statusCode == 401 || error.response?.data['code'] == 101) {
                              context.go('/sign-in');
                            } else {
                              showDialog(
                                  useSafeArea: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('Error!\n${error.response?.statusCode}: ${error.response?.statusMessage}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Return'),
                                        )
                                      ],
                                    );
                                  });
                            }
                          }
                        },
                        loading: () => const CircularProgressIndicator());
                    },
                    // var service = await ApiService.create();
                    // try {
                      // var isLoggedIn = await service.checkToken();
                      // if (isLoggedIn) {
                      //   context.go('/tasks');
                      // } else {
                      //   context.go('/sign-in');
                      // }
                    // } on DioException catch(e) {
                    //
                    // }
                  // },
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.2, 0.5],
                        colors: [
                          Color.fromRGBO(139, 120, 255, 1),
                          Color.fromRGBO(84, 81, 214, 0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: const Text(
                      'Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 1.35,
                          color: Colors.white),
                    ),
                  ),
                )
              ]),
            ),
          )
        ]),
      );
    })
    );
  }
}
