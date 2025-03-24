package com.victorblaess.native_flutter_proxy

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/**
 * FlutterProxyPlugin
 * 
 * Este plugin de Flutter se utiliza para obtener la configuración del proxy del sistema.
 * Implementa las interfaces FlutterPlugin y MethodCallHandler.
 */
public class FlutterProxyPlugin : FlutterPlugin, MethodCallHandler {

    // Canal de método para la comunicación entre Flutter y el código nativo.
    private var mMethodChannel: MethodChannel? = null;

    companion object {
        /**
         * Método estático para registrar el plugin con un registrar.
         * 
         * @param registrar El registrar que se utiliza para registrar el plugin.
         */
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = FlutterProxyPlugin()
            instance.onAttachedToEngine(registrar.messenger());
        }
    }

    /**
     * Método privado para adjuntar el plugin al motor de Flutter.
     * 
     * @param messenger El mensajero binario utilizado para la comunicación.
     */
    private fun onAttachedToEngine(messenger: BinaryMessenger) {
        mMethodChannel = MethodChannel(messenger, "native_flutter_proxy")
        mMethodChannel!!.setMethodCallHandler(this)
    }

    /**
     * Método llamado cuando el plugin se adjunta al motor de Flutter.
     * 
     * @param binding El enlace del plugin de Flutter.
     */
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel = MethodChannel(binding.binaryMessenger, "native_flutter_proxy")
        mMethodChannel!!.setMethodCallHandler(this)
    }

    /**
     * Método llamado cuando el plugin se desadjunta del motor de Flutter.
     * 
     * @param binding El enlace del plugin de Flutter.
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mMethodChannel!!.setMethodCallHandler(null)
        mMethodChannel = null
    }

    /**
     * Método llamado cuando se realiza una llamada de método desde Flutter.
     * 
     * @param call La llamada de método.
     * @param result El resultado de la llamada de método.
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getProxySetting") {
            result.success(getProxySetting())
        } else {
            result.notImplemented()
        }
    }

    /**
     * Método privado para obtener la configuración del proxy del sistema.
     * 
     * @return Un mapa con la configuración del proxy.
     */
    private fun getProxySetting(): Any? {
        val map = LinkedHashMap<String, Any?>()
        map["host"] = System.getProperty("http.proxyHost")
        map["port"] = System.getProperty("http.proxyPort")
        return map
    }

}