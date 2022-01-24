package cl.ceisufro.fluttersensors

import android.content.Context
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


class FlutterSensorsPlugin() : FlutterPlugin, MethodCallHandler {
    private var eventChannels = hashMapOf<Int, EventChannel>()
    private var streamHandlers = hashMapOf<Int, SensorStreamHandler>()
    private lateinit var context: Context
    private lateinit var messenger: BinaryMessenger
    private lateinit var sensorManager: SensorManager

    constructor(context: Context, binaryMessenger: BinaryMessenger) : this() {
        this.context = context
        this.messenger = binaryMessenger
        this.sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val methodChannel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        this.context = binding.applicationContext
        this.messenger = binding.binaryMessenger
        this.sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        methodChannel.setMethodCallHandler(this)
    }

    companion object {
        private const val CHANNEL_NAME = "flutter_sensors"

        @Suppress("deprecation")
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val context = registrar.context()
            val binaryMessenger = registrar.messenger()
            val plugin = FlutterSensorsPlugin(context, binaryMessenger)
            methodChannel.setMethodCallHandler(plugin)
            registrar.addViewDestroyListener {
                plugin.onDestroy()
                false
            }
        }
    }

    override fun onDetachedFromEngine(p0: FlutterPlugin.FlutterPluginBinding) {
        removeAllListeners()
    }

    private fun onDestroy() {
        removeAllListeners()
    }

    private fun removeAllListeners() {
        eventChannels.forEach {
            val streamHandler = streamHandlers[it.key]
            streamHandler?.stopListener()
            streamHandlers.remove(it.key)
            it.value.setStreamHandler(null)
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
                val eventChannel = EventChannel(messenger, "flutter_sensors/$sensorId")
                val sensorManager =
                    context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
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
}
