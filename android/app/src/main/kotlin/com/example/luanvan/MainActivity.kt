package com.example.luanvan

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log
import java.security.MessageDigest
import android.content.pm.PackageManager
import android.util.Base64

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printKeyHash()
    }

    private fun printKeyHash() {
        try {
            val info = packageManager.getPackageInfo("com.example.luanvan", PackageManager.GET_SIGNATURES)
            for (signature in info.signatures) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                Log.d("KeyHash", keyHash)
            }
        } catch (e: Exception) {
            Log.e("KeyHash", "Error: $e")
        }
    }
}