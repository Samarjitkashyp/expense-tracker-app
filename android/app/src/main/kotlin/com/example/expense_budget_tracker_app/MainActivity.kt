package com.example.expense_budget_tracker_app

import io.flutter.embedding.android.FlutterActivity

import android.os.Environment
import android.os.StatFs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.spendwise.app/storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFreeStorageSpace") {
                try {
                    val stat = StatFs(Environment.getDataDirectory().path)
                    val bytesAvailable = stat.blockSizeLong * stat.availableBlocksLong
                    result.success(bytesAvailable)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
