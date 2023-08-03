package com.achivie.achivie

//import android.annotation.SuppressLint
//import android.content.Context
//import android.media.AudioAttributes
//import android.media.AudioFocusRequest
//import android.media.AudioManager
//import android.media.MediaPlayer
//import android.os.Build
//import android.os.Bundle
//import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
//import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {

    private val CHANNEL = "music_control"

//    companion object {
//        private const val MUSIC_CHANNEL = "music_control"
//    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // TODO: Register the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "listTile", ListTileNativeAdFactory(this.context))

//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "controlMusicState") {
//                val packageName = call.argument<String>("packageName")
//                val command = call.argument<String>("command")
//                controlMusicState(packageName, command)
//                result.success(null)
//            } else {
//                result.notImplemented()
//            }
//        }

//        GoogleMobileAdsPlugin.registerNativeAdFactory(
//                flutterEngine, "ReportContainer", ReportsContainerAdFactory(this.context))

//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MUSIC_CHANNEL).setMethodCallHandler { call, result ->
//            when (call.method) {
//                "play" -> {
//                    playMusic(call.argument("url"))
//                    result.success(null)
//                }
//                "pause" -> {
//                    pauseMusic()
//                    result.success(null)
//                }
//                "next" -> {
//                    nextTrack()
//                    result.success(null)
//                }
//                "previous" -> {
//                    previousTrack()
//                    result.success(null)
//                }
//                else -> {
//                    result.notImplemented()
//                }
//            }
//        }

    }



    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")

//        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "ReportContainer")
    }

//    override
//    protected fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        MobileNumberPlugin.registerWith(registrarFor("com.amorenew.mobile_number.MobileNumberPlugin()"))
//    }

//    private var audioManager: AudioManager? = null
//    private var focusRequest: AudioFocusRequest? = null
//    private var audioFocusChangeListener: AudioManager.OnAudioFocusChangeListener? = null
//    private var mediaPlayer: MediaPlayer? = null
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
//
//        // Create your own OnAudioFocusChangeListener implementation
//        audioFocusChangeListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
//            // Handle audio focus changes here
//            when (focusChange) {
//                AudioManager.AUDIOFOCUS_GAIN -> {
//                    // Audio focus gained, resume or start music playback here
//                    mediaPlayer?.start()
//                }
//                AudioManager.AUDIOFOCUS_LOSS -> {
//                    // Audio focus lost, pause or stop music playback here
//                    mediaPlayer?.pause()
//                }
//                AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
//                    // Audio focus temporarily lost, pause music playback here
//                    mediaPlayer?.pause()
//                }
//                // Add more cases for other audio focus change scenarios if needed
//            }
//        }
//    }
//
//    private fun playMusic(url: String?) {
//        // Release any existing MediaPlayer instance
//        mediaPlayer?.release()
//        mediaPlayer = null
//
//        if (url != null) {
//            // Create a new MediaPlayer instance and set the data source
//            mediaPlayer = MediaPlayer()
//            mediaPlayer?.setAudioAttributes(AudioAttributes.Builder()
//                    .setUsage(AudioAttributes.USAGE_MEDIA)
//                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
//                    .build())
//
//            mediaPlayer?.setDataSource(url)
//            mediaPlayer?.prepare()
//
//            // Request audio focus before starting music playback
//            val focusResult = audioManager?.requestAudioFocus(
//                    audioFocusChangeListener,
//                    AudioManager.STREAM_MUSIC,
//                    AudioManager.AUDIOFOCUS_GAIN
//            )
//
//            if (focusResult == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
//                mediaPlayer?.start()
//            }
//        }
//    }
//
//    private fun pauseMusic() {
//        if (mediaPlayer?.isPlaying == true) {
//            mediaPlayer?.pause()
//        }
//        releaseAudioFocus()
//    }
//
//    private fun releaseAudioFocus() {
//        audioManager?.abandonAudioFocus(audioFocusChangeListener)
//    }
//
//
//    private fun nextTrack() {
//        // Handle playing the next track
//    }
//
//    private fun previousTrack() {
//        // Handle playing the previous track
//    }
//
//    // Other methods for controlling the music playback can be added here
//
//    override fun onDestroy() {
//        super.onDestroy()
//        // Release the MediaPlayer instance when the activity is destroyed
//        mediaPlayer?.release()
//        mediaPlayer = null
//    }

}
