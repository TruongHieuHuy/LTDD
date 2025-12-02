package com.example.truonghieuhuy

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.util.Log

object GameAudioManager {
    private var soundPool: SoundPool? = null
    private val soundMap = mutableMapOf<String, Int>()
    private var isInitialized = false
    
    // Sound effects for games
    private const val SOUND_BONK = "bonk"
    private const val SOUND_BRUH = "bruh"
    private const val SOUND_VICTORY = "victory"
    private const val SOUND_SAD_TROMBONE = "sad_trombone"
    private const val SOUND_ERROR = "error"
    private const val SOUND_CLICK = "click"
    private const val SOUND_TROLL = "troll"
    
    /**
     * Initialize sound pool and load sound effects
     */
    fun initialize(context: Context) {
        if (isInitialized) {
            Log.d("GameAudioManager", "Already initialized")
            return
        }
        
        try {
            // Create SoundPool with optimal settings
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            
            soundPool = SoundPool.Builder()
                .setMaxStreams(5)
                .setAudioAttributes(audioAttributes)
                .build()
            
            // Load sound effects from assets
            // Note: You need to add these sound files to android/app/src/main/res/raw/
            // For now, we'll use placeholder IDs
            
            // TODO: Add actual sound files to res/raw/ folder
            // soundMap[SOUND_BONK] = soundPool?.load(context, R.raw.bonk, 1) ?: 0
            // soundMap[SOUND_BRUH] = soundPool?.load(context, R.raw.bruh, 1) ?: 0
            // soundMap[SOUND_VICTORY] = soundPool?.load(context, R.raw.victory, 1) ?: 0
            // soundMap[SOUND_SAD_TROMBONE] = soundPool?.load(context, R.raw.sad_trombone, 1) ?: 0
            // soundMap[SOUND_ERROR] = soundPool?.load(context, R.raw.error, 1) ?: 0
            // soundMap[SOUND_CLICK] = soundPool?.load(context, R.raw.click, 1) ?: 0
            // soundMap[SOUND_TROLL] = soundPool?.load(context, R.raw.troll, 1) ?: 0
            
            isInitialized = true
            Log.d("GameAudioManager", "Sound pool initialized with ${soundMap.size} sounds")
        } catch (e: Exception) {
            Log.e("GameAudioManager", "Failed to initialize: ${e.message}")
            isInitialized = false
        }
    }
    
    /**
     * Play a sound effect by name
     * @param soundName Name of the sound effect (bonk, bruh, victory, etc.)
     * @param volume Volume level (0.0 to 1.0)
     * @return Stream ID or null if failed
     */
    fun playSound(soundName: String, volume: Float = 1.0f): Int? {
        if (!isInitialized) {
            Log.w("GameAudioManager", "Sound pool not initialized")
            return null
        }
        
        val soundId = soundMap[soundName]
        if (soundId == null) {
            Log.w("GameAudioManager", "Sound not found: $soundName")
            return null
        }
        
        try {
            val streamId = soundPool?.play(
                soundId,
                volume,  // left volume
                volume,  // right volume
                1,       // priority
                0,       // loop (0 = no loop)
                1.0f     // playback rate
            )
            
            Log.d("GameAudioManager", "Playing sound: $soundName (volume: $volume)")
            return streamId
        } catch (e: Exception) {
            Log.e("GameAudioManager", "Failed to play sound $soundName: ${e.message}")
            return null
        }
    }
    
    /**
     * Play bonk sound (wrong answer)
     */
    fun playBonk(volume: Float = 1.0f) = playSound(SOUND_BONK, volume)
    
    /**
     * Play bruh sound (epic fail)
     */
    fun playBruh(volume: Float = 1.0f) = playSound(SOUND_BRUH, volume)
    
    /**
     * Play victory fanfare (win)
     */
    fun playVictory(volume: Float = 1.0f) = playSound(SOUND_VICTORY, volume)
    
    /**
     * Play sad trombone (lose)
     */
    fun playSadTrombone(volume: Float = 1.0f) = playSound(SOUND_SAD_TROMBONE, volume)
    
    /**
     * Play error buzz (invalid input)
     */
    fun playError(volume: Float = 1.0f) = playSound(SOUND_ERROR, volume)
    
    /**
     * Play click sound (button press)
     */
    fun playClick(volume: Float = 0.5f) = playSound(SOUND_CLICK, volume)
    
    /**
     * Play troll sound (meme moment)
     */
    fun playTroll(volume: Float = 1.0f) = playSound(SOUND_TROLL, volume)
    
    /**
     * Stop a specific sound stream
     */
    fun stopSound(streamId: Int) {
        soundPool?.stop(streamId)
    }
    
    /**
     * Stop all sounds
     */
    fun stopAllSounds() {
        soundPool?.autoPause()
    }
    
    /**
     * Resume all paused sounds
     */
    fun resumeAllSounds() {
        soundPool?.autoResume()
    }
    
    /**
     * Release resources
     */
    fun release() {
        soundPool?.release()
        soundPool = null
        soundMap.clear()
        isInitialized = false
        Log.d("GameAudioManager", "Released all resources")
    }
}
