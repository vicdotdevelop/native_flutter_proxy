package com.victorblaess.native_flutter_proxy

import android.content.BroadcastReceiver
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Proxy
import android.net.ProxyInfo
import android.net.Uri
import android.util.Log
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class FlutterProxyPlugin : FlutterPlugin, MethodCallHandler, BroadcastReceiver() {

    private var methodChannel: MethodChannel? = null
    private var context: Context? = null

    private fun setupChannel(messenger: BinaryMessenger) {
        methodChannel = MethodChannel(messenger, "native_flutter_proxy")
        methodChannel!!.setMethodCallHandler(this)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        setupChannel(binding.binaryMessenger)
        context = binding.applicationContext

        // initial default proxy, that could not be captured beforehand
        val pi = refreshProxyInfo(null) // this does not look consider proxies from PAC
        Log.d("ProxyChangeReceiver", "Properties: ${System.getProperty("http.proxyHost")}:${System.getProperty("http.proxyPort")}")
        Log.d("ProxyChangeReceiver", "ProxyInfo without intent: ${pi?.host}:${pi?.port}")

        context!!.registerReceiver(this, IntentFilter(Proxy.PROXY_CHANGE_ACTION))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        context!!.unregisterReceiver(this)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getProxySetting") {
            result.success(proxySetting)
        } else {
            result.notImplemented()
        }
    }

    private val proxySetting: LinkedHashMap<String, Any?> = LinkedHashMap<String, Any?>()

    override fun onReceive(context: Context, intent: Intent) {
        if (Proxy.PROXY_CHANGE_ACTION == intent.action) {
            // Handle the proxy change here
            Log.d("ProxyChangeReceiver", "Proxy settings changed")
            val pi = refreshProxyInfo(intent)
            Log.d("ProxyChangeReceiver", "ProxyInfo: ${pi?.host}:${pi?.port}")
            methodChannel!!.invokeMethod("proxyChangedCallback", proxySetting)
        }
    }

    /**
     * Get system proxy and update cache with optional intent argument needed for PAC.
     */
    private fun refreshProxyInfo(intent: Intent?): ProxyInfo? {
        val connectivityManager = getSystemService(context!!,ConnectivityManager::class.java)
        var info: ProxyInfo? = connectivityManager!!.defaultProxy
        if (info == null) {
            proxySetting["host"] = null
            proxySetting["port"] = null
            return null
        }

        // If a proxy is configured using the PAC file use
        // Android's injected localhost HTTP proxy.
        //
        // Android's injected localhost proxy can be accessed using a proxy host
        // equal to `localhost` and a proxy port retrieved from intent's 'extras'.
        // We cannot take a proxy port from the ProxyInfo object that's exposed by
        // the connectivity manager as it's always equal to -1 for cases when PAC
        // proxy is configured.
        if (info.pacFileUrl != null && info.pacFileUrl !== Uri.EMPTY) {
            if (intent == null) {
                proxySetting["host"] = null
                proxySetting["port"] = null
                // PAC proxies are supported only when Intent is present
                return null
            }

            val extras = intent.extras
            if (extras == null) {
                proxySetting["host"] = null
                proxySetting["port"] = null
                return null
            }

            info = extras.getParcelable("android.intent.extra.PROXY_INFO", ProxyInfo::class.java)
        }

        proxySetting["host"] = info!!.host
        proxySetting["port"] = info.port
        return info
    }
}
