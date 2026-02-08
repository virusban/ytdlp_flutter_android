package com.example.ytdlp_flutter_android

import android.content.Intent
import android.net.Uri
import androidx.activity.result.contract.ActivityResultContracts
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "ytdlp_channel"
    private var pendingResult: MethodChannel.Result? = null

    private val folderPicker =
        registerForActivityResult(ActivityResultContracts.OpenDocumentTree()) { uri ->
            uri?.let {
                contentResolver.takePersistableUriPermission(
                    it,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                pendingResult?.success(it.toString())
            } ?: pendingResult?.success(null)
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFolder" -> {
                        pendingResult = result
                        folderPicker.launch(null)
                    }

                    "download" -> {
                        val py = Python.getInstance()
                        val module = py.getModule("ytdlp_download")

                        module.callAttr(
                            "download",
                            call.argument<String>("url"),
                            call.argument<String>("folderUri"),
                            call.argument<String>("format"),
                            applicationContext
                        )
                        result.success(null)
                    }
                }
            }
    }
}
