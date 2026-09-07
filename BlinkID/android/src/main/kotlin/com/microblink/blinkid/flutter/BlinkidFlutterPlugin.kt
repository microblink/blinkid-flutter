package com.microblink.blinkid.flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.microblink.blinkid.core.BlinkIdSdk
import com.microblink.blinkid.core.session.BlinkIdProcessResult
import com.microblink.blinkid.ux.contract.BlinkIdScanActivitySettings
import com.microblink.blinkid.ux.contract.MbBlinkIdScan
import com.microblink.blinkid.core.LicenseLockedException
import com.microblink.blinkid.core.image.InputImage
import com.microblink.blinkid.core.ping.PingManager
import com.microblink.blinkid.core.ping.pinglets.WrapperProductInfo
import com.microblink.blinkid.ux.contract.ScanActivityResultStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import kotlinx.coroutines.*


/** BlinkidFlutterPlugin */
class BlinkIdFlutterPlugin() : FlutterPlugin, MethodCallHandler, ActivityAware,
    ActivityResultListener {
    private val BLINKID_METHOD_PERFORM_SCAN = "performScan"
    private val BLINKID_METHOD_PERFORM_DIRECTAPI_SCAN = "performDirectApiScan"
    private val BLINKID_LOAD_SDK = "loadBlinkIdSdk"
    private val BLINKID_UNLOAD_SDK = "unloadBlinkIdSdk"
    private val BLINKID_REFRESH_LICENSE_LEASE = "refreshLicenseLease"
    private val BLINKID_REQUEST_CODE = 1452
    private val BLINKID_ERROR_RESULT_CODE = "blinkid_android_error"
    private var blinkIdSdk: BlinkIdSdk? = null
    private var isSdkLoaded: Boolean = false

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    private var flutterPluginActivity: Activity? = null
    private var scanResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "blinkid_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            BLINKID_LOAD_SDK -> CoroutineScope(Dispatchers.Main).launch {
                loadBlinkIdSdk(call, result)
            }
            BLINKID_UNLOAD_SDK -> unloadBlinkIdSdk(call, result)
            BLINKID_REFRESH_LICENSE_LEASE -> CoroutineScope(Dispatchers.Main).launch {
                refreshLicenseLease(result)
            }
            BLINKID_METHOD_PERFORM_SCAN -> CoroutineScope(Dispatchers.Main).launch {
                performScan(call, result)
            }
            BLINKID_METHOD_PERFORM_DIRECTAPI_SCAN -> CoroutineScope(Dispatchers.Main).launch {
                performDirectApiScan(call, result)
            }
            else -> result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private suspend fun loadBlinkIdSdk(call: MethodCall, result: Result) {
        try {
            ensureLoadedSdk(call)
            result.success(true)
        } catch (error: Exception) {
            result.error(BLINKID_ERROR_RESULT_CODE, error.message, null)
        }
    }

    private suspend fun refreshLicenseLease(result: Result) {
        try {
            val sdk = BlinkIdSdk.sdkInstance
                ?: throw IllegalStateException(
                    "The BlinkID SDK is not initialized. Call loadBlinkIdSdk() first, or perform a scan."
                )
            sdk.refreshLicenseLease()
            result.success(null)
        } catch (error: Exception) {
            result.error(BLINKID_ERROR_RESULT_CODE, error.message, null)
        }
    }

    private fun unloadBlinkIdSdk(call: MethodCall, result: Result) {
        try {
            val deleteCachedResources = call.argument<Boolean>("deleteCachedResources")
            deleteCachedResources?.let {
                if (it) {
                    BlinkIdSdk.sdkInstance?.closeAndDeleteCachedAssets()
                } else {
                    BlinkIdSdk.sdkInstance?.close()
                }
                blinkIdSdk = null
                result.success("")
            }
        } catch (exception: Exception) {
            result.error(BLINKID_ERROR_RESULT_CODE, exception.message, null)
        }

    }

    private suspend fun ensureLoadedSdk(call: MethodCall): BlinkIdSdk? {

            blinkIdSdk?.let { return it }

            val blinkIdSdkSettings = call.argument<Map<String, Any>>("blinkIdSdkSettings")
            val sdkSettings = BlinkIdDeserializationUtils
                .deserializeBlinkIdSdkSettings(blinkIdSdkSettings)?: throw IllegalStateException("Incorrect SDK Settings.")

            flutterPluginActivity?.let {
                val maybeInstance = BlinkIdSdk.initializeSdk(it, sdkSettings)
                when {
                    maybeInstance.isSuccess -> {
                        blinkIdSdk = maybeInstance.getOrNull()
                        return blinkIdSdk
                    }

                    maybeInstance.isFailure -> {
                        blinkIdSdk = null
                        isSdkLoaded = false
                        throw maybeInstance.exceptionOrNull() ?: IllegalStateException("SDK initialization failed.")
                    }
                }
            }?: throw IllegalStateException("Activity not available.")

        return null
    }

    private suspend fun performScan(call: MethodCall, result: Result) {
        if (scanResult != null) {
            result.error(
                BLINKID_ERROR_RESULT_CODE,
                "A BlinkID scan is already in progress.",
                null,
            )
            return
        }

        try {
            val blinkIdSdkSettings = call.argument<Map<String, Any>>("blinkIdSdkSettings")
            val blinkIdSessionSettings = call.argument<Map<String, Any>>("blinkIdSessionSettings")
            android.util.Log.i(
                "BlinkIdFlutter",
                "performScan received blinkIdSessionSettings=$blinkIdSessionSettings",
            )
            val blinkIdScanningUxSettings = call.argument<Map<String, Any>>("blinkIdScanningUxSettings")
            val classFilterMap = call.argument<Map<String, Any>>("blinkIdClassFilter")
            val redactionSettingsResolverMap = call.argument<Map<String, Any>>("blinkIdRedactionSettingsResolver")
            android.util.Log.i(
                "BlinkIdFlutter",
                "performScan received blinkIdRedactionSettingsResolver=$redactionSettingsResolverMap",
            )
            val sdkSettings = BlinkIdDeserializationUtils
                .deserializeBlinkIdSdkSettings(blinkIdSdkSettings)
                ?: return result.error(BLINKID_ERROR_RESULT_CODE, "Incorrect SDK Settings.", null)

            val activity = flutterPluginActivity
                ?: return result.error(BLINKID_ERROR_RESULT_CODE, "Activity not found.", null)

            val intent = MbBlinkIdScan().createIntent(
                activity,
                BlinkIdScanActivitySettings(
                    sdkSettings = sdkSettings,
                    cameraSettings = BlinkIdDeserializationUtils.deserializeCameraSettings(blinkIdScanningUxSettings),
                    scanningSessionSettings = BlinkIdDeserializationUtils.deserializeBlinkIdSessionSettings(
                        blinkIdSessionSettings,
                        false
                    ),
                    uxSettings = BlinkIdDeserializationUtils.deserializeBlinkIdUxSettings(
                        blinkidUxSettingsMap = blinkIdScanningUxSettings,
                        classFilterMap = classFilterMap,
                        redactionSettingsResolverMap = redactionSettingsResolverMap,
                        sessionSettingsMap = blinkIdSessionSettings,
                    ),
                    showOnboardingDialog = (blinkIdScanningUxSettings?.getOrDefault("showOnboardingDialog", true) as? Boolean) ?: true,
                    showHelpButton = (blinkIdScanningUxSettings?.getOrDefault("showHelpButton", true) as? Boolean) ?: true,
                )
            )

            addFlutterPinglet(context)

            scanResult = result
            activity.startActivityForResult(intent, BLINKID_REQUEST_CODE)
        } catch (error: Exception) {
            scanResult = null
            when (error) {
                is LicenseLockedException -> {
                    result.error(BLINKID_ERROR_RESULT_CODE, error.message, null)
                }
                else -> {
                    result.error(BLINKID_ERROR_RESULT_CODE, error.message, null)
                }
            }
        }
    }

    private suspend fun performDirectApiScan(call: MethodCall, result: Result) {
        try {
            val blinkIdSessionSettings = call.argument<Map<String, Any>>("blinkIdSessionSettings")
            val firstImage = call.argument<String>("firstImage")
            val secondImage = call.argument<String>("secondImage")
            blinkIdSdk = ensureLoadedSdk(call)
            blinkIdSdk?.let {
                addFlutterPinglet(context)

                    val sessionResult = it.createScanningSession(
                        BlinkIdDeserializationUtils.deserializeBlinkIdSessionSettings(
                            blinkIdSessionSettings,
                            true
                        )
                    )
                    if (sessionResult.isFailure) {
                        result.error(
                            BLINKID_ERROR_RESULT_CODE,
                            sessionResult.exceptionOrNull()?.message ?: "Could not create scanning session.",
                            null,
                        )
                        return@let
                    }
                    val session = sessionResult.getOrThrow()
                    var processResult: kotlin.Result<BlinkIdProcessResult>? = null

                    firstImage?.let { firstImageBase64 ->
                        BlinkIdDeserializationUtils.base64ToBitmap(firstImageBase64)
                            ?.let { image ->
                                processResult = session.process(InputImage.createFromBitmap(image))
                            }
                    }

                    secondImage?.let { secondImageBase64 ->
                        BlinkIdDeserializationUtils.base64ToBitmap(secondImageBase64)
                            ?.let { image ->
                                processResult = session.process(InputImage.createFromBitmap(image))
                            }
                    }

                    if (processResult?.isSuccess == true) {
                        val redactionSettingsMap = call.argument<Map<String, Any>>("directApiRedactionSettings")
                        val redactionSettings = BlinkIdDeserializationUtils.deserializeRedactionSettings(redactionSettingsMap)
                        val scanningResultKotlinResult = session.getResult(redactionSettings)
                        if (scanningResultKotlinResult.isSuccess) {
                            result.success(
                                BlinkIdSerializationUtils.serializeBlinkIdScanningResult(
                                    scanningResultKotlinResult.getOrNull()
                                )
                            )
                        } else {
                            result.error(
                                BLINKID_ERROR_RESULT_CODE,
                                scanningResultKotlinResult.exceptionOrNull()?.message ?: "Could not get the results.",
                                null
                            )
                        }
                    } else {
                        result.error(
                            BLINKID_ERROR_RESULT_CODE,
                            "Could not get the results.",
                            null
                        )
                    }
                    BlinkIdSdk.sdkInstance?.close()
                    blinkIdSdk = null
            }?: result.error(BLINKID_ERROR_RESULT_CODE, "The BlinkID SDK is not initialized. Call the loadBlinkIdSdk() method to pre-load the SDK first, or try running the performDirectApiScan() method with a valid internet connection.", null)
        } catch (error: Exception) {
            result.error(BLINKID_ERROR_RESULT_CODE, error.message, null)
        }
    }

    private fun addFlutterPinglet(context: Context) {
        PingManager.getInstance(context).add(
            WrapperProductInfo(
                wrapperProduct = WrapperProductInfo.WrapperProduct.CROSSPLATFORMFLUTTER),
            0)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != BLINKID_REQUEST_CODE) {
            return false
        }

        val pendingScanResult = scanResult ?: return false
        scanResult = null

        val blinkIdResult = MbBlinkIdScan().parseResult(resultCode, data)
        when (blinkIdResult.status) {

            ScanActivityResultStatus.Scanned -> {
                blinkIdResult.result?.let { scanningResult ->
                    val success = BlinkIdSerializationUtils.serializeBlinkIdScanningResult(
                        scanningResult
                    )
                    pendingScanResult.success(success)

                } ?: pendingScanResult.error(BLINKID_ERROR_RESULT_CODE, "BlinkID result is empty.", null)
            }

            ScanActivityResultStatus.Canceled -> {
                pendingScanResult.error(BLINKID_ERROR_RESULT_CODE, "Scanning is canceled.", null)
                blinkIdSdk = null
                suspend {
                    BlinkIdSdk.sdkInstance?.close()
                }
            }

            ScanActivityResultStatus.ErrorSdkInit -> {
                pendingScanResult.error(
                    BLINKID_ERROR_RESULT_CODE,
                    "Could not initialize the SDK.",
                    null
                )
                blinkIdSdk = null
            }
        }
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        flutterPluginActivity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        flutterPluginActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        flutterPluginActivity = binding.activity
    }

    override fun onDetachedFromActivity() {
        flutterPluginActivity = null
    }
}
