package com.example.omukae

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.geofencing.GeofencingService

class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate();
        GeofencingService.setPluginRegistrant(this);
    }

    override fun registerWith(registry: PluginRegistry) {
        GeneratedPluginRegistrant.registerWith(registry);
    }
}
