package com.example.dermiq

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth requires FlutterFragmentActivity (not FlutterActivity) on Android
// so the biometric prompt can attach to a FragmentActivity.
class MainActivity : FlutterFragmentActivity()
