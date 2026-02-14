If you plan to run `flutter build` or `flutter run`, ensure Android manifest contains the Internet permission.

Add or update the file at `android/app/src/main/AndroidManifest.xml` inside the Flutter project (created by `flutter create`) and include:

<uses-permission android:name="android.permission.INTERNET" />

For storage access on Android 11+ prefer app-scoped storage (no WRITE_EXTERNAL_STORAGE). This scaffold writes to app documents directory.
