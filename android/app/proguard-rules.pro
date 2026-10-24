# Flutter / Play release. AdMob consumer rules come from the AAR.
-keep class com.arusoft.reactionduel.** { *; }

# shared_preferences_android 2.5.x calls its Kotlin API from Dart over JNI
# (package:jni). R8 can't see those calls and strips/renames the methods ->
# NoSuchMethodError in SharedPreferences.getInstance -> app stuck on splash.
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.github.dart_lang.jni.** { *; }
# package:jni looks these Kotlin coroutine/result types up by name from Dart.
-keep class kotlin.coroutines.** { *; }
-keep class kotlin.Result { *; }
-keep class kotlin.Result$* { *; }
-keep class kotlin.Unit { *; }
-keep class kotlin.jvm.internal.** { *; }
