import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

List<AudioSource> cuzList() {
  List<AudioSource> list = [];
  for (var i = 1; i < 31; i++) {
    String cuzNumber = i.toString().padLeft(2, "0");
    print(cuzNumber);
    var audioSource = AudioSource.uri(
      Uri.parse(
          "https://archive.org/download/turkce_kuran_suat_yildirim_meali/${cuzNumber}cuz.mp3"),
      tag: MediaItem(
        id: '$i',
        album: "$i. Cüz",
        title: "Kur'an Meali $i. Cüz",
        artUri: Uri.parse("assets/images/monogram.png"),
      ),
    );
    list.add(audioSource);
  }
  return list;
}

List<String> cuzListString() {
  List<String> list = [];
  for (var i = 1; i < 31; i++) {
    String cuzNumber = i.toString().padLeft(2, "0");
    var audioSource =
        "https://archive.org/download/turkce_kuran_suat_yildirim_meali/${cuzNumber}cuz.mp3";
    list.add(audioSource);
  }
  return list;
}

List<AudioSource> sureList() {
  List<AudioSource> list = [];
  int i = 0;
  String title;
  for (var item in sureler) {
    i++;
    int index = item.indexOf("-");
    // print(index);
    if (index == -1) {
      index = 4;
    }

    title =
        "$i - ${item[index + 1].toUpperCase()}${item.substring(index + 2).toLowerCase()}";

    // print(item);
    var audioSource = AudioSource.uri(
      Uri.parse(
          "https://ia801904.us.archive.org/22/items/INDIRILIS_SIRASINA_GORE_SESLI_KURAN_MEALI/$item.mp3"),
      tag: MediaItem(
        id: "$i",
        album: "$title Suresi",
        title: "$title Suresi",
        artUri: Uri.parse("assets/images/monogram.png"),
      ),
    );
    list.add(audioSource);
  }
  return list;
}

List<String> sureler = [
  "01-alak",
  "02-kalem",
  "03-muzzemmil",
  "04-muddessir",
  "05-fatiha",
  "06-tebbet",
  "07-tekvir",
  "08-ala",
  "09-leyl",
  "10-fecr",
  "11-duha",
  "12-insirah",
  "13-asr",
  "14-adiyat",
  "15-kevser",
  "16-tekasur",
  "17-maun",
  "18-kafirun",
  "19-fil",
  "20-felak",
  "21-nas",
  "22-ihlas",
  "23-necm",
  "24-abese",
  "25-kadr",
  "26-sems",
  "27-buruc",
  "28-tin",
  "29-kureys",
  "30-karia",
  "31-kiyame",
  "32-humeze",
  "33-murselat",
  "34-kaf",
  "35-beled",
  "36-tarik",
  "37-kamer",
  "38-sad",
  "39-araf",
  "40-cin",
  "41-yasin",
  "42-furkan",
  "43-fatir",
  "44-meryem",
  "45-taha",
  "46-vakia",
  "47-suara",
  "48-neml",
  "49-kasas",
  "50-isra",
  "51-yunus",
  "52-hud",
  "53-yusuf",
  "54-hicr",
  "55-enam",
  "56-saffat",
  "57-lokman",
  "58-sebe",
  "59-zumer",
  "60-mumin",
  "61-fussilet",
  "62-sura",
  "63-zuhruf",
  "64-duhan",
  "65-casiye",
  "66-ahkaf",
  "67-zariyat",
  "68-gasiye",
  "69-kehf",
  "70-nahl",
  "71-nuh",
  "72-ibrahim",
  "73-enbiya",
  "74-muminun",
  "75-secde",
  "76-tur",
  "77-mulk",
  "78-hakka",
  "79-mearic",
  "80-nebe",
  "81-naziat",
  "82-infitar",
  "83-insikak",
  "84-rum",
  "85-ankebut",
  "86-mutaffifin",
  "87-bakara",
  "88-enfal",
  "89-aliimran",
  "90-ahzab",
  "91-mumtehine",
  "92-nisa",
  "93-zilzal",
  "94-hadid",
  "95-muhammed",
  "96-rad",
  "97-rahman",
  "98-insan",
  "99-talak",
  "s100-beyyine",
  "s101-hasr",
  "s102-nur",
  "s103-hac",
  "s104-munafikun",
  "s105-mucadele",
  "s106-hucurat",
  "s107-tahrim",
  "s108-tegabun",
  "s109-saf",
  "s110.cuma",
  "s111-fetih",
  "s112-maide",
  "s113-tevbe",
  "s114-nasr"
];
