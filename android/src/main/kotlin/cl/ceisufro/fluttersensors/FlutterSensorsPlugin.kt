package cl.ceisufro.fluttersensors

import android.content.Context
import android.hardware.SensorManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class FlutterSensorsPlugin(private val registrar: PluginRegistry.Registrar) : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var eventChannels = hashMapOf<Int, EventChannel>()
    private var streamHandlers = hashMapOf<Int, SensorStreamHandler>()

    companion object {
        lateinit var sensorManager: SensorManager

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val plugin = FlutterSensorsPlugin(registrar)
            sensorManager = registrar.context().getSystemService(Context.SENSOR_SERVICE) as SensorManager
            val methodChannel = MethodChannel(registrar.messenger(), "flutter_sensors")
            methodChannel.setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "is_sensor_available" -> isSensorAvailable(call.arguments, result)
            "update_sensor_interval" -> updateSensorInterval(call.arguments, result)
            "start_event_channel" -> startEventChannel(call.arguments, result)
            else -> result.notImplemented()
        }
    }

    private fun isSensorAvailable(arguments: Any, result: MethodChannel.Result) {
        val dataMap = arguments as Map<*, *>
        val sensorId: Int = dataMap["sensorId"] as Int
        val isAvailable = sensorManager.getSensorList(sensorId).isNotEmpty()
        result.success(isAvailable)
        return
    }

    private fun updateSensorInterval(arguments: Any, result: MethodChannel.Result) {
        try {
            val dataMap = arguments as Map<*, *>
            val sensorId: Int = dataMap["sensorId"] as Int
            val interval: Int? = dataMap["interval"] as Int?
            streamHandlers[sensorId]?.updateInterval(interval)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun startEventChannel(arguments: Any, result: MethodChannel.Result) {
        try {
            val dataMap = arguments as Map<*, *>
            val sensorId: Int = dataMap["sensorId"] as Int
            val interval: Int? = dataMap["interval"] as Int?
            if (!eventChannels.containsKey(sensorId)) {
                val eventChannel = EventChannel(registrar.messenger(), "flutter_sensors/$sensorId")
                val sensorManager = registrar.context().getSystemService(Context.SENSOR_SERVICE) as SensorManager
                val sensorStreamHandler = SensorStreamHandler(sensorManager, sensorId, interval)
                eventChannel.setStreamHandler(sensorStreamHandler)
                eventChannels[sensorId] = eventChannel
                streamHandlers[sensorId] = sensorStreamHandler
            }
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        /// Not implemented
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
            streamHandlers.remove(it.key)
            it.value.setStreamHandler(null)
        }
    }
}
