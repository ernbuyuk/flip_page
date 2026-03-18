package com.example.flip_page

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 15+ defaults to edge-to-edge for apps targeting SDK 35.
        // This call makes behavior consistent / backward-compatible.
        this.enableEdgeToEdge()
    }
}
