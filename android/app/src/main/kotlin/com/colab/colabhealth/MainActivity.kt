package com.colab.colabhealth

import io.flutter.embedding.android.FlutterFragmentActivity

// The `health` plugin registers an ActivityResultLauncher to show the Health
// Connect permission UI, which requires a FragmentActivity/ComponentActivity.
// Extending FlutterActivity caused "Permission launcher not found" and the
// permission dialog never appeared.
class MainActivity : FlutterFragmentActivity()
