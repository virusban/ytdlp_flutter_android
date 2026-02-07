package com.ronna.ytdlpflutterandroid

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ytdlp_flutter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (! Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "download") {
                val url = call.argument<String>("url")!!
                val path = call.argument<String>("path")!!
                val fmt = call.argument<String>("format")!!

                val py = Python.getInstance()
                val pyObj = py.getModule("ytdlp_download")
                try {
                    val output = pyObj.callAttr("download", url, path, fmt)
                    result.success(output.toString())
                } catch (e: Exception) {
                    result.error("PythonError", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
