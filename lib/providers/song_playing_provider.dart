import 'package:flutter/material.dart';

class SongPlayingProvider extends ChangeNotifier {
  bool isSongPlaying = false;
  void isSongPlayingFunc(bool isPlaying) {
    isSongPlaying = isPlaying;
    notifyListeners();
  }

  String songName = "";
  void songNameFunc(String name) {
    songName = name;
    notifyListeners();
  }

  String songArtist = "";
  void songArtistFunc(String artist) {
    songArtist = artist;
    notifyListeners();
  }
}
