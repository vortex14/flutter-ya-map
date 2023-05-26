package com.example.yandex_map_example
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.yandex.mapkit.MapKitFactory

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
      MapKitFactory.setApiKey("72d9e23e-3adf-4f7f-9c38-a180b53a29b6") // Your generated API key
      super.configureFlutterEngine(flutterEngine)
    }
  }
