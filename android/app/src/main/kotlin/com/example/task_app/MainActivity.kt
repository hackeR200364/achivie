package com.example.task_app

import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {

    private val CHANNEL = "my_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // TODO: Register the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
                flutterEngine, "listTile", ListTileNativeAdFactory(context))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    when (call.method) {
                        "getMediaMetadata" -> {
                            val metadata = getMediaMetadata()
                            result.success(metadata)
                        }
                        else -> result.notImplemented()
                    }
                }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // TODO: Unregister the ListTileNativeAdFactory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }



    private fun getMediaMetadata(): Map<String, String> {
        val metadata = HashMap<String, String>()
        val contentResolver = context.contentResolver
        val uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val cursor = contentResolver.query(uri, null, null, null, null)

        if (cursor != null && cursor.moveToFirst()) {
            val titleColumn = cursor.getColumnIndex(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndex(MediaStore.Audio.Media.ARTIST)
            val pathColumn = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)

            val title = cursor.getString(titleColumn)
            val artist = cursor.getString(artistColumn)
            val path = cursor.getString(pathColumn)

            metadata[MediaMetadataRetriever.METADATA_KEY_TITLE.toString()] = title
            metadata[MediaMetadataRetriever.METADATA_KEY_ARTIST.toString()] = artist
//            metadata[MediaMetadataRetriever.METADATA_KEY_DURATION.toString()] = duration.toString()

            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(path)

            metadata[MediaMetadataRetriever.METADATA_KEY_ALBUM.toString()] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)!!
            metadata[MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST.toString()] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)!!
            retriever.release()
        }

        cursor?.close()
        return metadata
    }



}
