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
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
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
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        unregisterReceiver()
    }

    private fun unregisterReceiver() {
        ContextWrapper(context).unregisterReceiver(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getProxySetting") {
            result.success(getProxySetting())
        } else if (call.method == "setProxyChangeListenerEnabled") {
            if (call.arguments<List<Boolean>>()?.get(0) == true) {
                Log.d("ProxyChangeReceiver", "Enabled receiver")
                context!!.registerReceiver(this, IntentFilter(Proxy.PROXY_CHANGE_ACTION))
            } else {
                Log.d("ProxyChangeReceiver", "Disabled receiver")
                unregisterReceiver()
            }
        } else {
            result.notImplemented()
        }
    }

    private fun getProxySetting(): Any? {
        val map = LinkedHashMap<String, Any?>()
        map["host"] = System.getProperty("http.proxyHost")
        map["port"] = System.getProperty("http.proxyPort")
        Log.d("ProxyChangeReceiver", "Properties: ${map["host"]}:${map["port"]}")
        val pi = extractProxyInfo(null) // this does not look into PAC
        Log.d("ProxyChangeReceiver", "ProxyInfo without intent: ${pi?.host}:${pi?.port}")
        return map
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (Proxy.PROXY_CHANGE_ACTION == intent.action) {
            // Handle the proxy change here
            Log.d("ProxyChangeReceiver", "Proxy settings changed")
            val pi = extractProxyInfo(intent)
            Log.d("ProxyChangeReceiver", "ProxyInfo: ${pi?.host}:${pi?.port}")
            methodChannel!!.invokeMethod("proxyChangedCallback", null)
        }
    }


    private fun extractProxyInfo(intent: Intent?): ProxyInfo? {
        val connectivityManager = getSystemService(context!!,ConnectivityManager::class.java)
        var info: ProxyInfo? = connectivityManager!!.defaultProxy
        if (info == null) {
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
                // PAC proxies are supported only when Intent is present
                return null
            }

            val extras = intent.extras
            if (extras == null) {
                return null
            }

            info = extras.get("android.intent.extra.PROXY_INFO") as ProxyInfo?
        }

        return info
    }
}
