package com.microblink.blinkid.flutter

import android.app.Activity
import android.content.Context
import com.microblink.blinkid.core.BlinkIdSdk
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BlinkIdScannerViewFactory(
    private val messenger: BinaryMessenger,
    private val sdkProvider: () -> BlinkIdSdk?,
    private val requestCameraPermission: (Activity, (Boolean) -> Unit) -> Unit,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(
        context: Context,
        viewId: Int,
        args: Any?,
    ): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val creationParams = args as? Map<String, Any> ?: emptyMap()
        return BlinkIdScannerView(context, viewId, messenger, creationParams, sdkProvider, requestCameraPermission)
    }
}
