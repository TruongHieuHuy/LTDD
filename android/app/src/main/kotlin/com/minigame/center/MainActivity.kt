package com.minigame.center

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.regex.Pattern

class MainActivity : FlutterActivity() {
	private val CHANNEL = "smart_student_tools"
	private val RECORD_AUDIO_REQUEST_CODE = 1001
	private val REQUEST_CODE_VOICE = 2001
	
	private lateinit var methodChannel: MethodChannel
	private var speechRecognizer: SpeechRecognizer? = null
	private var recognizerIntent: Intent? = null
	private var pendingResult: MethodChannel.Result? = null
	private var currentMethodCall: String? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		
		// Initialize game audio
		GameAudioManager.initialize(this)
		
		methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
		
		methodChannel.setMethodCallHandler { call, result ->
			when (call.method) {
				"callPhone" -> {
					val phone = call.argument<String>("phone") ?: ""
					CallService.callPhone(this, phone)
					result.success(null)
				}
				"openYouTube" -> {
					val url = call.argument<String>("url") ?: ""
					YouTubeService.openYouTube(this, url)
					result.success(null)
				}
				"setAlarm" -> {
					val millis = call.argument<Int>("millis") ?: 0
					AlarmService.setAlarm(this, millis.toLong())
					result.success(null)
				}
				"playGameSound" -> {
					val soundName = call.argument<String>("soundName") ?: ""
					val volume = call.argument<Double>("volume")?.toFloat() ?: 1.0f
					val streamId = GameAudioManager.playSound(soundName, volume)
					result.success(streamId)
				}
				"stopGameSound" -> {
					val streamId = call.argument<Int>("streamId") ?: -1
					if (streamId >= 0) {
						GameAudioManager.stopSound(streamId)
					}
					result.success(null)
				}
				"speechToText" -> {
					if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
						!= PackageManager.PERMISSION_GRANTED) {
						ActivityCompat.requestPermissions(
							this, 
							arrayOf(Manifest.permission.RECORD_AUDIO), 
							RECORD_AUDIO_REQUEST_CODE
						)
						result.error("PERMISSION_DENIED", "Cần quyền ghi âm", null)
						return@setMethodCallHandler
					}
					currentMethodCall = "speechToText"
					startSpeechRecognition(result, false)
				}
				"startSpeechRecognition" -> {
					if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
						!= PackageManager.PERMISSION_GRANTED) {
						ActivityCompat.requestPermissions(
							this, 
							arrayOf(Manifest.permission.RECORD_AUDIO), 
							RECORD_AUDIO_REQUEST_CODE
						)
						result.error("PERMISSION_DENIED", "Cần quyền ghi âm", null)
						return@setMethodCallHandler
					}
					currentMethodCall = "startSpeechRecognition"
					startSpeechRecognition(result, false)
				}
				"processVoiceAlarmCommand" -> {
					if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) 
						!= PackageManager.PERMISSION_GRANTED) {
						ActivityCompat.requestPermissions(
							this, 
							arrayOf(Manifest.permission.RECORD_AUDIO), 
							RECORD_AUDIO_REQUEST_CODE
						)
						result.error("PERMISSION_DENIED", "Cần quyền ghi âm", null)
						return@setMethodCallHandler
					}
					currentMethodCall = "processVoiceAlarmCommand"
					startSpeechRecognition(result, true)
				}
				else -> result.notImplemented()
			}
		}
	}

	private fun startSpeechRecognition(result: MethodChannel.Result, isAlarmCommand: Boolean) {
		pendingResult = result
		
		if (speechRecognizer == null) {
			speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
			speechRecognizer?.setRecognitionListener(object : RecognitionListener {
				override fun onReadyForSpeech(params: Bundle?) {
					Log.d("SpeechRecognizer", "Ready for speech")
				}
				
				override fun onBeginningOfSpeech() {
					Log.d("SpeechRecognizer", "Beginning of speech")
				}
				
				override fun onRmsChanged(rmsdB: Float) {}
				override fun onBufferReceived(buffer: ByteArray?) {}
				override fun onEndOfSpeech() {
					Log.d("SpeechRecognizer", "End of speech")
				}
				
				override fun onPartialResults(partialResults: Bundle?) {}
				override fun onEvent(eventType: Int, params: Bundle?) {}
				
				override fun onError(error: Int) {
					val errorMessage = when (error) {
						SpeechRecognizer.ERROR_AUDIO -> "ERROR_AUDIO"
						SpeechRecognizer.ERROR_CLIENT -> "ERROR_CLIENT"
						SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "ERROR_INSUFFICIENT_PERMISSIONS"
						SpeechRecognizer.ERROR_NETWORK -> "ERROR_NETWORK"
						SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "ERROR_NETWORK_TIMEOUT"
						SpeechRecognizer.ERROR_NO_MATCH -> "ERROR_NO_MATCH"
						SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "ERROR_RECOGNIZER_BUSY"
						SpeechRecognizer.ERROR_SERVER -> "ERROR_SERVER"
						SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "ERROR_SPEECH_TIMEOUT"
						else -> "ERROR_UNKNOWN_$error"
					}
					Log.e("SpeechRecognizer", "Error: $errorMessage")
					pendingResult?.error("SPEECH_ERROR", errorMessage, null)
					pendingResult = null
				}
				
				override fun onResults(results: Bundle?) {
					val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
					if (matches != null && matches.isNotEmpty()) {
						val text = matches[0]
						Log.d("SpeechRecognizer", "Recognized: $text")
						
						if (isAlarmCommand) {
							// Parse alarm command and set alarm
							val parsedTime = parseAlarmCommand(text)
							if (parsedTime != null) {
								AlarmService.setAlarm(this@MainActivity, parsedTime)
								
								// Tính thời gian báo thức thực tế
								val now = java.util.Calendar.getInstance()
								val alarmTime = java.util.Calendar.getInstance().apply {
									timeInMillis = now.timeInMillis + parsedTime
								}
								val alarmHour = alarmTime.get(java.util.Calendar.HOUR_OF_DAY)
								val alarmMinute = alarmTime.get(java.util.Calendar.MINUTE)
								val timeString = String.format("%02d:%02d", alarmHour, alarmMinute)
								
								val hours = parsedTime / (1000 * 60 * 60)
								val minutes = (parsedTime % (1000 * 60 * 60)) / (1000 * 60)
								
								// Trả về JSON với thông tin đầy đủ
								val result = mapOf(
									"success" to true,
									"time" to timeString,
									"message" to if (hours > 0) {
										"Đã đặt báo thức $timeString (sau $hours giờ $minutes phút)"
									} else {
										"Đã đặt báo thức $timeString (sau $minutes phút)"
									}
								)
								pendingResult?.success(result)
							} else {
								val result = mapOf(
									"success" to false,
									"message" to "Không hiểu lệnh: $text"
								)
								pendingResult?.success(result)
							}
						} else {
							pendingResult?.success(text)
						}
						pendingResult = null
					} else {
						pendingResult?.error("NO_MATCH", "Không nhận được kết quả", null)
						pendingResult = null
					}
				}
			})
		}
		
		// Always create fresh intent for each recognition
		recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
			putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
			putExtra(RecognizerIntent.EXTRA_LANGUAGE, "vi-VN")
			putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, "vi-VN")
			putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, "vi-VN")
			putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
			putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5)
			putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, packageName)
			putExtra(RecognizerIntent.EXTRA_PROMPT, if (isAlarmCommand) 
				"Nói giờ bạn muốn đặt báo thức (ví dụ: 7 giờ 30 sáng)" else "Nói để dịch...")
		}
		
		// Try to use activity-based recognition first (better on emulators)
		try {
			startActivityForResult(recognizerIntent, REQUEST_CODE_VOICE)
			return
		} catch (e: Exception) {
			Log.i("MainActivity", "Activity recognizer not available, using service: ${e.message}")
		}
		
		// Fallback to service-based recognition
		speechRecognizer?.startListening(recognizerIntent)
	}
	
	override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
		super.onActivityResult(requestCode, resultCode, data)
		
		if (requestCode == REQUEST_CODE_VOICE) {
			if (resultCode == Activity.RESULT_OK && data != null) {
				val matches = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
				if (matches != null && matches.isNotEmpty()) {
					val text = matches[0]
					Log.d("SpeechRecognizer", "Activity result: $text")
					
					// Check if this is alarm command mode
					if (currentMethodCall == "processVoiceAlarmCommand") {
						// Parse alarm command and set alarm
						val parsedTime = parseAlarmCommand(text)
						if (parsedTime != null) {
							AlarmService.setAlarm(this@MainActivity, parsedTime)
							
							// Tính thời gian báo thức thực tế
							val now = java.util.Calendar.getInstance()
							val alarmTime = java.util.Calendar.getInstance().apply {
								timeInMillis = now.timeInMillis + parsedTime
							}
							val alarmHour = alarmTime.get(java.util.Calendar.HOUR_OF_DAY)
							val alarmMinute = alarmTime.get(java.util.Calendar.MINUTE)
							val timeString = String.format("%02d:%02d", alarmHour, alarmMinute)
							
							val hours = parsedTime / (1000 * 60 * 60)
							val minutes = (parsedTime % (1000 * 60 * 60)) / (1000 * 60)
							
							// Trả về JSON với thông tin đầy đủ
							val result = mapOf(
								"success" to true,
								"time" to timeString,
								"message" to if (hours > 0) {
									"Đã đặt báo thức $timeString (sau $hours giờ $minutes phút)"
								} else {
									"Đã đặt báo thức $timeString (sau $minutes phút)"
								}
							)
							pendingResult?.success(result)
						} else {
							val result = mapOf(
								"success" to false,
								"time" to "",
								"message" to "Không hiểu lệnh: $text"
							)
							pendingResult?.success(result)
						}
					} else {
						// Regular speech recognition for translation
						pendingResult?.success(text)
					}
					pendingResult = null
				} else {
					pendingResult?.error("NO_MATCH", "Không nhận được kết quả", null)
					pendingResult = null
				}
			} else {
				pendingResult?.error("CANCELLED", "Đã hủy nhận giọng nói", null)
				pendingResult = null
			}
		}
	}
	
	override fun onRequestPermissionsResult(
		requestCode: Int,
		permissions: Array<out String>,
		grantResults: IntArray
	) {
		super.onRequestPermissionsResult(requestCode, permissions, grantResults)
		
		if (requestCode == RECORD_AUDIO_REQUEST_CODE) {
			if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
				// Permission granted, but result already sent error, user needs to try again
				Log.d("MainActivity", "Permission granted")
			} else {
				Log.e("MainActivity", "Permission denied")
			}
		}
	}
	
	private fun parseAlarmCommand(text: String): Long? {
		val lowerText = text.lowercase()
		Log.d("AlarmParser", "Parsing text: $lowerText")
		
		// Xác định AM/PM
		val isPM = lowerText.contains("chiều") || lowerText.contains("tối") || 
				   lowerText.contains("pm") || lowerText.contains("p.m")
		val isAM = lowerText.contains("sáng") || lowerText.contains("am") || 
				   lowerText.contains("a.m") || lowerText.contains("buổi sáng")
		
		// Pattern 0: "HH:MM" format - Ví dụ: "8:30 chiều", "7:30 am", "20:45"
		val colonTimePattern = Pattern.compile("(\\d{1,2}):(\\d{2})")
		val colonMatcher = colonTimePattern.matcher(lowerText)
		
		if (colonMatcher.find()) {
			var hour = colonMatcher.group(1)?.toIntOrNull() ?: 0
			val minute = colonMatcher.group(2)?.toIntOrNull() ?: 0
			
			// Chuyển đổi 12h sang 24h format nếu có AM/PM
			if (hour <= 12) {
				if (isPM && hour != 12) {
					hour += 12  // 1 PM = 13, 8 PM = 20, ...
				} else if (isAM && hour == 12) {
					hour = 0  // 12 AM = 0
				}
			}
			
			// Validate
			if (hour < 0 || hour > 23 || minute < 0 || minute >= 60) {
				Log.e("AlarmParser", "Invalid time: $hour:$minute")
				return null
			}
			
			// Calculate time from now
			val now = java.util.Calendar.getInstance()
			val targetTime = java.util.Calendar.getInstance().apply {
				set(java.util.Calendar.HOUR_OF_DAY, hour)
				set(java.util.Calendar.MINUTE, minute)
				set(java.util.Calendar.SECOND, 0)
				set(java.util.Calendar.MILLISECOND, 0)
			}
			
			// Nếu thời gian đã qua, đặt cho ngày mai
			if (targetTime.before(now) || targetTime.equals(now)) {
				targetTime.add(java.util.Calendar.DAY_OF_MONTH, 1)
			}
			
			val diffMillis = targetTime.timeInMillis - now.timeInMillis
			
			// Validate không quá 24 giờ
			val maxMillis = 24 * 60 * 60 * 1000L
			if (diffMillis > maxMillis) {
				Log.e("AlarmParser", "Time difference exceeds 24 hours: $diffMillis ms")
				return null
			}
			
			Log.d("AlarmParser", "Parsed colon time: $hour:$minute (${if(isPM) "PM" else if(isAM) "AM" else ""}), diff: $diffMillis ms")
			return diffMillis
		}
		
		// Pattern 1: "X giờ Y phút" với AM/PM - Ví dụ: "7 giờ 30 sáng"
		val timePattern = Pattern.compile("(\\d+)\\s*giờ\\s*(rưỡi|\\d+)?")
		val matcher = timePattern.matcher(lowerText)
		
		if (matcher.find()) {
			var hour = matcher.group(1)?.toIntOrNull() ?: 0
			val minuteStr = matcher.group(2)
			val minute = when {
				minuteStr == "rưỡi" -> 30
				minuteStr != null -> minuteStr.toIntOrNull() ?: 0
				else -> 0
			}
			
			// Validate hour trong khoảng 0-23
			if (hour < 0 || hour > 23) {
				Log.e("AlarmParser", "Invalid hour: $hour")
				return null
			}
			
			// Chuyển đổi 12h sang 24h format
			if (hour <= 12) {
				if (isPM && hour != 12) {
					hour += 12  // 1 PM = 13, 2 PM = 14, ...
				} else if (isAM && hour == 12) {
					hour = 0  // 12 AM = 0
				}
			}
			
			// Validate lại sau khi convert
			if (hour < 0 || hour > 23 || minute < 0 || minute >= 60) {
				Log.e("AlarmParser", "Invalid time after conversion: $hour:$minute")
				return null
			}
			
			// Calculate time from now
			val now = java.util.Calendar.getInstance()
			val targetTime = java.util.Calendar.getInstance().apply {
				set(java.util.Calendar.HOUR_OF_DAY, hour)
				set(java.util.Calendar.MINUTE, minute)
				set(java.util.Calendar.SECOND, 0)
				set(java.util.Calendar.MILLISECOND, 0)
			}
			
			// Nếu thời gian đã qua, đặt cho ngày mai
			if (targetTime.before(now) || targetTime.equals(now)) {
				targetTime.add(java.util.Calendar.DAY_OF_MONTH, 1)
			}
			
			val diffMillis = targetTime.timeInMillis - now.timeInMillis
			
			// Validate không quá 24 giờ
			val maxMillis = 24 * 60 * 60 * 1000L
			if (diffMillis > maxMillis) {
				Log.e("AlarmParser", "Time difference exceeds 24 hours: $diffMillis ms")
				return null
			}
			
			Log.d("AlarmParser", "Parsed time: $hour:$minute (${if(isPM) "PM" else if(isAM) "AM" else ""}), diff: $diffMillis ms")
			return diffMillis
		}
		
		// Pattern 2: "sau X giờ Y phút"
		val afterPattern = Pattern.compile("sau\\s+(\\d+)\\s*giờ\\s*(\\d+)?\\s*phút?")
		val matcher2 = afterPattern.matcher(lowerText)
		if (matcher2.find()) {
			val hours = matcher2.group(1)?.toLongOrNull() ?: 0
			val minutes = matcher2.group(2)?.toLongOrNull() ?: 0
			
			// Validate không quá 24 giờ
			if (hours > 24 || (hours == 24L && minutes > 0)) {
				Log.e("AlarmParser", "Duration exceeds 24 hours: $hours h $minutes m")
				return null
			}
			
			val millis = (hours * 60 + minutes) * 60 * 1000
			Log.d("AlarmParser", "Parsed duration: $hours h $minutes m = $millis ms")
			return millis
		}
		
		// Pattern 3: "sau X phút"
		val minutePattern = Pattern.compile("sau\\s+(\\d+)\\s*phút")
		val matcher3 = minutePattern.matcher(lowerText)
		if (matcher3.find()) {
			val minutes = matcher3.group(1)?.toLongOrNull() ?: 0
			if (minutes > 24 * 60) {
				Log.e("AlarmParser", "Duration exceeds 24 hours: $minutes minutes")
				return null
			}
			val millis = minutes * 60 * 1000
			Log.d("AlarmParser", "Parsed minutes: $minutes = $millis ms")
			return millis
		}
		
		// Pattern 4: "sau X giờ"
		val hourPattern = Pattern.compile("sau\\s+(\\d+)\\s*giờ")
		val matcher4 = hourPattern.matcher(lowerText)
		if (matcher4.find()) {
			val hours = matcher4.group(1)?.toLongOrNull() ?: 0
			if (hours > 24) {
				Log.e("AlarmParser", "Duration exceeds 24 hours: $hours hours")
				return null
			}
			val millis = hours * 60 * 60 * 1000
			Log.d("AlarmParser", "Parsed hours: $hours = $millis ms")
			return millis
		}
		
		Log.w("AlarmParser", "No pattern matched")
		return null
	}
	
	override fun onDestroy() {
		speechRecognizer?.destroy()
		GameAudioManager.release()
		super.onDestroy()
	}
}
