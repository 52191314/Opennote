// 🤖 Generated wholely or partially with Google Antigravity
package com.woaiyj1314.opennote

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private const val CLIPBOARD_CHANNEL = "com.opennote.app/clipboard"
        private val IMAGE_EXTENSIONS = listOf(
            "png",
            "jpg",
            "jpeg",
            "gif",
            "webp",
            "bmp",
            "heic",
            "heif",
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (intent.getIntExtra("org.chromium.chrome.extra.TASK_ID", -1) == this.taskId) {
            this.finish()
            intent.addFlags(FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
        super.onCreate(savedInstanceState)

        WindowCompat.setDecorFitsSystemWindows(window, false)

        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.isAppearanceLightNavigationBars = true

        requestHighRefreshRate()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            requestHighRefreshRate()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CLIPBOARD_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "copyImage" -> handleCopyImage(call, result)
                "pasteImage" -> handlePasteImage(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun requestHighRefreshRate() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return

        val currentDisplay = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            display
        } else {
            @Suppress("DEPRECATION")
            windowManager.defaultDisplay
        } ?: return

        val currentMode = currentDisplay.mode ?: return
        val bestMode = currentDisplay.supportedModes
            ?.filter {
                it.physicalWidth == currentMode.physicalWidth &&
                    it.physicalHeight == currentMode.physicalHeight
            }
            ?.maxByOrNull { it.refreshRate }
            ?: return

        if (window.attributes.preferredDisplayModeId != bestMode.modeId) {
            window.attributes = window.attributes.apply {
                preferredDisplayModeId = bestMode.modeId
            }
        }
    }

    private fun handleCopyImage(call: MethodCall, result: MethodChannel.Result) {
        val bytes: ByteArray? = when (val args = call.arguments) {
            is ByteArray -> args
            is Map<*, *> -> args["bytes"] as? ByteArray
            else -> null
        }
        if (bytes == null || bytes.isEmpty()) {
            result.error("INVALID_ARGS", "Image bytes are required", null)
            return
        }

        try {
            val file = File(cacheDir, "clipboard/copied_image.png")
            file.parentFile?.mkdirs()
            file.writeBytes(bytes)

            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            if (clipboard == null) {
                result.success(false)
                return
            }

            val clip = ClipData.newUri(contentResolver, "Opennote Image", uri)
            clipboard.setPrimaryClip(clip)
            result.success(true)
        } catch (e: Exception) {
            result.error("CLIPBOARD_WRITE_ERROR", e.message, null)
        }
    }

    private fun handlePasteImage(result: MethodChannel.Result) {
        try {
            val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager
            val primaryClip = clipboard?.primaryClip
            if (primaryClip == null || primaryClip.itemCount == 0) {
                result.success(null)
                return
            }

            for (i in 0 until primaryClip.itemCount) {
                val uri = primaryClip.getItemAt(i)?.uri ?: continue
                val mimeType = contentResolver.getType(uri)?.lowercase()
                val pathExtension = resolveImageExtensionFromUri(uri)
                val isImageMime = mimeType?.startsWith("image/") == true

                if (!isImageMime && pathExtension == null) continue

                val bytes = contentResolver.openInputStream(uri)?.use { it.readBytes() }
                if (bytes == null || bytes.isEmpty()) continue

                val ext = (
                    mimeType?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) }
                        ?: pathExtension
                        ?: "png"
                    ).trimStart('.')

                result.success(
                    mapOf(
                        "bytes" to bytes,
                        "extension" to ".$ext",
                    ),
                )
                return
            }

            result.success(null)
        } catch (_: Exception) {
            result.success(null)
        }
    }

    private fun resolveImageExtensionFromUri(uri: Uri): String? {
        val path = uri.path?.lowercase() ?: return null
        return IMAGE_EXTENSIONS.firstOrNull { ext -> path.endsWith(".$ext") }
    }
}
