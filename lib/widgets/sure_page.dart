import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:meal/components/saved_tabIndex.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meal/components/control_buttons.dart';
import 'package:meal/components/get_cuz_list.dart';
import 'package:meal/components/saved_sure_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

import '../common.dart';

class SurePage extends StatefulWidget {
  const SurePage({
    Key? key,
  }) : super(key: key);

  @override
  State<SurePage> createState() => _SurePageState();
}

class _SurePageState extends State<SurePage> with WidgetsBindingObserver {
  final _playlistSure = ConcatenatingAudioSource(children: sureList());
  late AudioPlayer _player;
  bool isLoading = false;

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _player = AudioPlayer();

    init();
  }

  int? currentSureIndex;
  Duration? surePosition;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    SharedPreferences prefsSure = await SharedPreferences.getInstance();
    String? json = prefsSure.getString("keySure");

    if (json == null) {
      currentSureIndex = 0;
      surePosition = Duration.zero;
    } else {
      Map<String, dynamic> map = jsonDecode(json);

      final savedInfo = SavedSureInfo.fromJson(map);
      print(json);

      currentSureIndex = int.tryParse(savedInfo.sureIndex ?? "0");
      surePosition = parseDuration(savedInfo.surePosition ?? "0");
    }
    try {
      // Preloading audio is not currently supported on Linux.
      await _player
          .setAudioSource(_playlistSure,
              preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux,
              initialIndex: currentSureIndex,
              initialPosition: surePosition)
          .whenComplete(() {
        setState(() {
          isLoading = true;
        });
      });
    } catch (e) {
      // Catch load errors: 404, invalid url...
      print("Error loading audio source: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      print("applife circle içi");
      saveTabIndex();
      saveData();
    }
  }

  void saveData() async {
    SharedPreferences prefsSure = await SharedPreferences.getInstance();

    print("saveData ${_player.currentIndex}    ve    ${_player.position}");
    final saveData = SavedSureInfo(
      sureIndex: _player.currentIndex.toString(),
      surePosition: _player.position.toString(),
    );
    print("kayıt altında ${saveData.surePosition}");

    String json = jsonEncode(saveData);
    prefsSure.setString("keySure", json);
  }

  void saveTabIndex() async {
    SharedPreferences prefTabIndex = await SharedPreferences.getInstance();

    final saveData = SavedTabIndex(tabIndex: "1");

    String json = jsonEncode(saveData);
    print("tabindex sureİÇİ $json");
    prefTabIndex.setString("keyTabIndex", json);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    saveTabIndex();
    saveData();

    _player.dispose();
    super.dispose();
  }

  @override
  Future<DisposePlayerResponse> disposePlayer(
      DisposePlayerRequest request) async {
    saveTabIndex();

    saveData();
    return DisposePlayerResponse();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Center(child: CircularProgressIndicator())
        : Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<SequenceState?>(
                      stream: _player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        //  final currentIndex = state.currentIndex ?? 0;
                        if (state?.sequence.isEmpty ?? true)
                          return const SizedBox();
                        final metadata = state!.currentSource!.tag as MediaItem;

                        double sureLenght() {
                          if (metadata.album!.length > 19) {
                            return 14;
                          } else if (metadata.album!.length > 15) {
                            return 15;
                          } else {
                            return 20;
                          }
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              fit: StackFit.loose,
                              alignment: AlignmentDirectional.center,
                              children: [
                                Center(
                                  child: Image(
                                    image: AssetImage(
                                        "assets/images/monogram.png"),
                                    height: 150,
                                    width: 150,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    metadata.album ?? "Meal",
                                    style: TextStyle(
                                        fontSize: sureLenght(),
                                        color: Colors.yellowAccent,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                height: 25,
                color: Colors.grey,
              ),
              Flexible(
                flex: 4,
                child: StreamBuilder<SequenceState?>(
                  stream: _player.sequenceStateStream,
                  builder: (context, snapshot) {
                    final state = snapshot.data;
                    final sequence = state?.sequence ?? [];
                    return ReorderableListView(
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) newIndex--;
                        _playlistSure.move(oldIndex, newIndex);
                      },
                      children: [
                        for (var i = 0; i < sequence.length; i++)
                          ListTile(
                            key: ValueKey(sequence[i]),
                            title: Text(sequence[i].tag.title as String),
                            onTap: () {
                              _player.seek(Duration.zero, index: i);
                            },
                          ),
                      ],
                      scrollController: ScrollController(
                        initialScrollOffset:
                            (55 * (_player.currentIndex!)).toDouble(),
                      ),
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StreamBuilder<PositionData>(
                    stream: _positionDataStream,
                    builder: (context, snapshot) {
                      final positionData = snapshot.data;
                      return SeekBar(
                        duration: positionData?.duration ?? Duration.zero,
                        position: positionData?.position ?? Duration.zero,
                        bufferedPosition:
                            positionData?.bufferedPosition ?? Duration.zero,
                        onChangeEnd: (newPosition) {
                          _player.seek(newPosition);
                        },
                      );
                    },
                  ),
                  ControlButtons(_player),
                ],
              ),
            ],
          );
  }
}
