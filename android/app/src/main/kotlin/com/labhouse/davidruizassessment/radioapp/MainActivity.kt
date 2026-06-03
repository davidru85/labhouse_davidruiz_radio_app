package com.labhouse.davidruizassessment.radioapp

import com.ryanheise.audioservice.AudioServiceActivity

// `audio_service` requires the host Activity to extend `AudioServiceActivity`
// so the plugin can attach to the correct FlutterEngine. Without this,
// `AudioService.init()` (called from the composition root) throws a
// PlatformException at startup and `runApp` is never reached (per ADR-0022).
class MainActivity: AudioServiceActivity()
