import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:meal/components/saved_tabIndex.dart';
import 'package:rxdart/rxdart.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:meal/components/control_buttons.dart';
import 'package:meal/components/get_cuz_list.dart';
import 'package:meal/components/saved_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio_platform_interface/just_audio_platform_interface.dart';

import '../common.dart';

class CuzPage extends StatefulWidget {
  const CuzPage({
    Key? key,
  }) : super(key: key);

  // final ConcatenatingAudioSource _playlist;

  @override
  State<CuzPage> createState() => _CuzPageState();
}

class _CuzPageState extends State<CuzPage>
    with WidgetsBindingObserver, JustAudioBackground {
  final _playlistCuz = ConcatenatingAudioSource(children: cuzList());
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
    _player = AudioPlayer();
    WidgetsBinding.instance?.addObserver(this);

    init();
  }

  Duration? cuzPosition;
  int? currentCuzIndex;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? json = prefs.getString("key");

    if (json == null) {
      currentCuzIndex = 0;
      cuzPosition = Duration.zero;
      print(json);
    } else {
      Map<String, dynamic> map = jsonDecode(json);

      final savedInfo = SavedInfo.fromJson(map);
      print(json);

      currentCuzIndex = int.tryParse(savedInfo.cuzIndex ?? "0");
      cuzPosition = parseDuration(savedInfo.cuzPosition ?? "0");
    }
    try {
      // Preloading audio is not currently supported on Linux.

      await _player
          .setAudioSource(_playlistCuz,
              preload: kIsWeb || defaultTargetPlatform != TargetPlatform.linux,
              initialIndex: currentCuzIndex,
              initialPosition: cuzPosition)
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

  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print("saveData ${_player.currentIndex}    ve    ${_player.position}");
    final saveData = SavedInfo(
      cuzIndex: _player.currentIndex.toString(),
      cuzPosition: _player.position.toString(),
    );
    print("kayıt altında ${saveData.cuzPosition}");

    String json = jsonEncode(saveData);
    prefs.setString("key", json);
  }

  void saveTabIndex() async {
    SharedPreferences prefTabIndex = await SharedPreferences.getInstance();

    final saveData = SavedTabIndex(tabIndex: "0");

    String json = jsonEncode(saveData);
    print("tabindex $json");

    prefTabIndex.setString("keyTabIndex", json);
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
                                        fontSize: 20,
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
                        _playlistCuz.move(oldIndex, newIndex);
                      },
                      children: [
                        for (var i = 0; i < sequence.length; i++)
                          ListTile(
                            selectedColor: Colors.blueAccent,
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
