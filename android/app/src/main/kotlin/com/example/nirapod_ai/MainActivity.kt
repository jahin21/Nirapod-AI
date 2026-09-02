package com.example.nirapod_ai

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.hardware.usb.UsbManager
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address
import java.net.InetSocketAddress
import java.net.NetworkInterface
import java.net.Socket
import java.util.Collections
import java.util.concurrent.Executors
import java.nio.ByteBuffer
import java.nio.ByteOrder
import org.tensorflow.lite.Interpreter

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "com.nirapod/native"
    private var channel: MethodChannel? = null
    private var pendingSharedText: String? = null
    private var permissionResult: MethodChannel.Result? = null
    private var pendingNotification: Pair<String, String>? = null
    private var notificationResult: MethodChannel.Result? = null
    private var wifiInfoResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        readSharedText(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readSharedText(intent)
        pendingSharedText?.let {
            channel?.invokeMethod("sharedTextReceived", it)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).also { methodChannel ->
            methodChannel.setMethodCallHandler(::handleMethod)
        }
    }

    private fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "authenticate" -> authenticate(result)
            "startProtection" -> {
                ContextCompat.startForegroundService(
                    this,
                    Intent(this, ProtectionService::class.java),
                )
                result.success(true)
            }
            "stopProtection" -> {
                stopService(Intent(this, ProtectionService::class.java))
                result.success(true)
            }
            "showNotification" -> {
                requestNotification(
                    call.argument<String>("title") ?: "Nirapod",
                    call.argument<String>("body") ?: "Security update",
                    result,
                )
            }
            "getClipboardText" -> result.success(readClipboard())
            "getSharedText" -> {
                result.success(pendingSharedText)
                pendingSharedText = null
            }
            "scanLocalNetwork" -> scanLocalNetwork(result)
            "currentWifiInfo" -> currentWifiInfo(result)
            "scanNearbyBluetooth" -> scanNearbyBluetooth(result)
            "advancedRoomCapabilities" -> result.success(advancedRoomCapabilities())
            "connectedUsbAccessories" -> result.success(connectedUsbAccessories())
            "classifyRoomImage" -> classifyRoomImage(call.argument<String>("path"), result)
            "platformCapabilities" -> result.success(
                mapOf(
                    "android" to true,
                    "biometric" to canAuthenticate(),
                    "bluetooth" to (
                        packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)
                    ),
                    "camera" to packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY),
                    "uwb" to packageManager.hasSystemFeature("android.hardware.uwb"),
                    "usbHost" to packageManager.hasSystemFeature(PackageManager.FEATURE_USB_HOST),
                ),
            )
            else -> result.notImplemented()
        }
    }

    private fun advancedRoomCapabilities(): Map<String, Any> {
        val usb = connectedUsbAccessories()
        return mapOf(
            "uwbSupported" to packageManager.hasSystemFeature("android.hardware.uwb"),
            "uwbReady" to false,
            "thermalReady" to false,
            "directionalRfReady" to false,
            "usbAccessoryCount" to usb.size,
            "note" to "UWB requires a participating compatible peer. Thermal and directional RF require a supported vendor accessory.",
        )
    }

    private fun connectedUsbAccessories(): List<Map<String, Any>> {
        val manager = getSystemService(Context.USB_SERVICE) as UsbManager
        return manager.deviceList.values.map { device ->
            mapOf(
                "deviceName" to device.deviceName,
                "vendorId" to device.vendorId,
                "productId" to device.productId,
                "deviceClass" to device.deviceClass,
            )
        }
    }

    private fun authenticate(result: MethodChannel.Result) {
        if (!canAuthenticate()) {
            result.error("UNAVAILABLE", "No enrolled secure biometric or device credential.", null)
            return
        }
        val prompt = BiometricPrompt(
            this,
            ContextCompat.getMainExecutor(this),
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    authenticationResult: BiometricPrompt.AuthenticationResult,
                ) {
                    result.success(true)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    result.error("AUTH_ERROR", errString.toString(), errorCode)
                }
            },
        )
        val authenticators =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        prompt.authenticate(
            BiometricPrompt.PromptInfo.Builder()
                .setTitle("Unlock Nirapod")
                .setSubtitle("Confirm your identity to protect security data")
                .setAllowedAuthenticators(authenticators)
                .build(),
        )
    }

    private fun canAuthenticate(): Boolean {
        val authenticators =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        return BiometricManager.from(this).canAuthenticate(authenticators) ==
            BiometricManager.BIOMETRIC_SUCCESS
    }

    private fun showNotification(title: String, body: String) {
        val channelId = "nirapod_alerts"
        val manager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    channelId,
                    "Nirapod Alerts",
                    NotificationManager.IMPORTANCE_DEFAULT,
                ),
            )
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName)
                ?: Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        manager.notify(
            (System.currentTimeMillis() % Int.MAX_VALUE).toInt(),
            NotificationCompat.Builder(this, channelId)
                .setSmallIcon(android.R.drawable.ic_dialog_alert)
                .setContentTitle(title)
                .setContentText(body)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .build(),
        )
    }

    private fun requestNotification(
        title: String,
        body: String,
        result: MethodChannel.Result,
    ) {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            pendingNotification = title to body
            notificationResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                5103,
            )
            return
        }
        showNotification(title, body)
        result.success(true)
    }

    private fun readClipboard(): String? {
        val clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        if (!clipboard.hasPrimaryClip()) return null
        if (!clipboard.primaryClipDescription!!.hasMimeType(ClipDescription.MIMETYPE_TEXT_PLAIN)) {
            return null
        }
        return clipboard.primaryClip?.getItemAt(0)?.coerceToText(this)?.toString()
    }

    private fun readSharedText(intent: Intent?) {
        if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            pendingSharedText = intent.getStringExtra(Intent.EXTRA_TEXT)?.trim()
        }
    }

    private fun localIpv4(): String? {
        for (networkInterface in Collections.list(NetworkInterface.getNetworkInterfaces())) {
            for (address in Collections.list(networkInterface.inetAddresses)) {
                if (!address.isLoopbackAddress && address is Inet4Address && address.isSiteLocalAddress) {
                    return address.hostAddress
                }
            }
        }
        return null
    }

    private fun classifyRoomImage(path: String?, result: MethodChannel.Result) {
        if (path.isNullOrBlank()) {
            result.error("INVALID_IMAGE", "A captured image path is required.", null)
            return
        }
        Executors.newSingleThreadExecutor().execute {
            try {
                val source = BitmapFactory.decodeFile(path)
                    ?: throw IllegalArgumentException("The captured image could not be decoded.")
                val bitmap = Bitmap.createScaledBitmap(source, 224, 224, true)
                val input = ByteBuffer.allocateDirect(224 * 224 * 3 * 4)
                    .order(ByteOrder.nativeOrder())
                val pixels = IntArray(224 * 224)
                bitmap.getPixels(pixels, 0, 224, 0, 0, 224, 224)
                pixels.forEach { pixel ->
                    input.putFloat(((pixel shr 16 and 0xff) / 127.5f) - 1f)
                    input.putFloat(((pixel shr 8 and 0xff) / 127.5f) - 1f)
                    input.putFloat(((pixel and 0xff) / 127.5f) - 1f)
                }
                input.rewind()
                val output = Array(1) { FloatArray(4) }
                assets.openFd("room_safe_classifier_v3.tflite").use { descriptor ->
                    descriptor.createInputStream().channel.use { channel ->
                        val model = channel.map(
                            java.nio.channels.FileChannel.MapMode.READ_ONLY,
                            descriptor.startOffset,
                            descriptor.declaredLength,
                        )
                        Interpreter(model).use { interpreter -> interpreter.run(input, output) }
                    }
                }
                val labels = arrayOf("laptop", "phone", "tablet", "screen_display")
                val best = output[0].indices.maxByOrNull { output[0][it] } ?: 0
                val confidence = output[0][best].toDouble()
                val threshold = 0.901572585105896
                val payload = mapOf(
                    "label" to labels[best],
                    "confidence" to confidence,
                    "threshold" to threshold,
                    "confidentKnownSafe" to (confidence >= threshold),
                    "model" to "stage_a_v3",
                    "limitation" to "This classifies resemblance to an ordinary device; it cannot prove the device or room is safe.",
                )
                runOnUiThread { result.success(payload) }
                if (bitmap !== source) bitmap.recycle()
                source.recycle()
            } catch (error: Exception) {
                runOnUiThread { result.error("STAGE_A_FAILED", error.message, null) }
            }
        }
    }

    private fun currentWifiInfo(result: MethodChannel.Result) {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.NEARBY_WIFI_DEVICES
        } else {
            Manifest.permission.ACCESS_FINE_LOCATION
        }
        if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
            wifiInfoResult = result
            ActivityCompat.requestPermissions(this, arrayOf(permission), 5104)
            return
        }
        deliverWifiInfo(result)
    }

    @Suppress("DEPRECATION")
    private fun deliverWifiInfo(result: MethodChannel.Result) {
        val manager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val info = manager.connectionInfo
        val rawSsid = info.ssid?.trim()?.trim('"').orEmpty()
        val ssid = if (rawSsid.isBlank() || rawSsid == WifiManager.UNKNOWN_SSID) {
            "Unknown Wi-Fi"
        } else {
            rawSsid
        }
        val security = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            when (info.currentSecurityType) {
                WifiInfo.SECURITY_TYPE_OPEN -> "Open"
                WifiInfo.SECURITY_TYPE_WEP -> "WEP"
                WifiInfo.SECURITY_TYPE_PSK -> "WPA/WPA2-Personal"
                WifiInfo.SECURITY_TYPE_EAP -> "WPA/WPA2-Enterprise"
                WifiInfo.SECURITY_TYPE_SAE -> "WPA3-Personal"
                WifiInfo.SECURITY_TYPE_EAP_WPA3_ENTERPRISE -> "WPA3-Enterprise"
                WifiInfo.SECURITY_TYPE_OWE -> "Enhanced Open (OWE)"
                WifiInfo.SECURITY_TYPE_PASSPOINT_R1_R2 -> "Passpoint"
                WifiInfo.SECURITY_TYPE_PASSPOINT_R3 -> "Passpoint WPA3"
                else -> "Unknown"
            }
        } else {
            "Unknown"
        }
        result.success(
            mapOf(
                "ssid" to ssid,
                "security" to security,
                "rssi" to info.rssi,
                "frequencyMhz" to info.frequency,
                "ip" to (localIpv4() ?: "Unknown"),
            ),
        )
    }

    private fun scanLocalNetwork(result: MethodChannel.Result) {
        val localIp = localIpv4()
        if (localIp == null) {
            result.error("NO_NETWORK", "Connect to an authorized Wi-Fi network first.", null)
            return
        }
        Thread {
            val subnet = localIp.substringBeforeLast(".")
            val cameraPorts = listOf(80, 443, 554, 8000, 8080, 8554)
            val pool = Executors.newFixedThreadPool(32)
            val findings = Collections.synchronizedList(mutableListOf<Map<String, Any>>())
            val tasks = (1..254).map { host ->
                pool.submit {
                    val ip = "$subnet.$host"
                    val openPorts = mutableListOf<Int>()
                    for (port in cameraPorts) {
                        try {
                            Socket().use { socket ->
                                socket.connect(InetSocketAddress(ip, port), 120)
                                openPorts.add(port)
                            }
                        } catch (_: Exception) {
                        }
                    }
                    if (openPorts.isNotEmpty()) {
                        findings.add(mapOf("ip" to ip, "ports" to openPorts))
                    }
                }
            }
            tasks.forEach { it.get() }
            pool.shutdown()
            runOnUiThread { result.success(findings.sortedBy { it["ip"].toString() }) }
        }.start()
    }

    private fun scanNearbyBluetooth(result: MethodChannel.Result) {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_SCAN
        } else {
            Manifest.permission.ACCESS_FINE_LOCATION
        }
        if (ContextCompat.checkSelfPermission(this, permission) != PackageManager.PERMISSION_GRANTED) {
            permissionResult = result
            val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                arrayOf(
                    Manifest.permission.BLUETOOTH_SCAN,
                    Manifest.permission.BLUETOOTH_CONNECT,
                )
            } else {
                arrayOf(permission)
            }
            ActivityCompat.requestPermissions(this, permissions, 5102)
            return
        }
        performBluetoothScan(result)
    }

    private fun performBluetoothScan(result: MethodChannel.Result) {
        val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val adapter: BluetoothAdapter? = manager.adapter
        val scanner = adapter?.bluetoothLeScanner
        if (adapter == null || !adapter.isEnabled || scanner == null) {
            result.error("BLUETOOTH_OFF", "Turn on Bluetooth and try again.", null)
            return
        }
        val devices = linkedMapOf<String, Map<String, Any?>>()
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, scanResult: ScanResult) {
                val device = scanResult.device
                val name = if (
                    Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                    ActivityCompat.checkSelfPermission(
                        this@MainActivity,
                        Manifest.permission.BLUETOOTH_CONNECT,
                    ) == PackageManager.PERMISSION_GRANTED
                ) device.name else null
                devices[device.address] = mapOf(
                    "name" to (name ?: "Unknown nearby device"),
                    "address" to device.address,
                    "rssi" to scanResult.rssi,
                )
            }
        }
        scanner.startScan(callback)
        Handler(Looper.getMainLooper()).postDelayed({
            scanner.stopScan(callback)
            result.success(devices.values.toList())
        }, 6000)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 5102) {
            val result = permissionResult ?: return
            permissionResult = null
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
                performBluetoothScan(result)
            } else {
                result.error("PERMISSION_DENIED", "Nearby-device permission was denied.", null)
            }
        }
        if (requestCode == 5103) {
            val result = notificationResult ?: return
            val notification = pendingNotification
            notificationResult = null
            pendingNotification = null
            if (
                grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED &&
                notification != null
            ) {
                showNotification(notification.first, notification.second)
                result.success(true)
            } else {
                result.error(
                    "PERMISSION_DENIED",
                    "Notification permission was denied.",
                    null,
                )
            }
        }
        if (requestCode == 5104) {
            val result = wifiInfoResult ?: return
            wifiInfoResult = null
            if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
                deliverWifiInfo(result)
            } else {
                result.error(
                    "PERMISSION_DENIED",
                    "Nearby Wi-Fi permission was denied.",
                    null,
                )
            }
        }
    }
}
