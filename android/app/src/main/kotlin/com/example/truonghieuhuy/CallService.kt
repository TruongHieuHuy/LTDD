package com.example.truonghieuhuy

import android.app.Activity
import android.content.Intent
import android.net.Uri

object CallService {
    fun callPhone(activity: Activity, phone: String) {
        val intent = Intent(Intent.ACTION_DIAL)
        intent.data = Uri.parse("tel:$phone")
        activity.startActivity(intent)
    }
}
