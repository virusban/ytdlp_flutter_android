package com.example.ytdlp_flutter_android

import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "ytdlp_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "download") {
                    val py = Python.getInstance()
                    val module = py.getModule("ytdlp_download")

                    module.callAttr(
                        "download",
                        call.argument<String>("url"),
                        call.argument<String>("path"),
                        call.argument<String>("format")
                    )
                    result.success(null)
                }
            }
    }
}
