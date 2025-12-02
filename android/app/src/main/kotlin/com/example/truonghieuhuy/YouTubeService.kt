package com.example.truonghieuhuy

import android.app.Activity
import android.content.Intent
import android.net.Uri

object YouTubeService {
    fun openYouTube(activity: Activity, url: String) {
        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse(url)
        intent.setPackage("com.google.android.youtube")
        try {
            activity.startActivity(intent)
        } catch (e: Exception) {
            // Nếu không có app YouTube, mở bằng trình duyệt
            val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            activity.startActivity(webIntent)
        }
    }
}
