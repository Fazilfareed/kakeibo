# Kakeibo release rules.
# Flutter and the plugins ship their own rules. Keep the app package, which
# Android reaches by name (activities, receivers), and the notification receivers.
-keep class com.fazil.kakeibo.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.google.android.play.core.**
