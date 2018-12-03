package cl.ceisufro.fluttersensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class FlutterSensorsPlugin : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    companion object {
        lateinit var sensorManager: SensorManager

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            val plugin = FlutterSensorsPlugin()
            val methodChannel = MethodChannel(registrar.messenger(), "flutter_sensors")
            methodChannel.setMethodCallHandler(plugin)
            val eventChannel = EventChannel(registrar.messenger(), "flutter_sensors_update_channel")
            eventChannel.setStreamHandler(plugin)
            sensorManager = registrar.context().getSystemService(Context.SENSOR_SERVICE) as SensorManager
        }
    }

    private var sinks = mutableListOf<EventChannel.EventSink?>()

    private val listener: SensorEventListener = object : SensorEventListener {
        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // NOT IMPLEMENTED
        }

        override fun onSensorChanged(event: SensorEvent?) {
            if (event != null) {
                val data = arrayListOf<Float>()
                event.values.forEach {
                    data.add(it)
                }
                val resultMap = mutableMapOf<String, Any>(
                        "sensor" to event.sensor.type,
                        "data" to data,
                        "accuracy" to event.accuracy)
                notify(resultMap)
            }
        }
    }

    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
        sinks.add(sink)

    }

    override fun onCancel(p0: Any?) {
        sinks.forEach {
            it?.endOfStream()
        }
        sinks.clear()
    }

    private fun notify(resultMap: MutableMap<String, Any>) {
        sinks.forEach {
            it?.success(resultMap)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "is_sensor_available" -> isSensorAvailable(call.arguments, result)
            "register_sensor_listener" -> registerSensorListener(call.arguments, result)
            "unregister_sensor_listener" -> unregisterSensorListener(call.arguments, result)
            else -> result.notImplemented()
        }
    }

    private fun isSensorAvailable(arguments:Any, result:MethodChannel.Result) {
        val dataMap = arguments as Map<*, *>
        val sensorType: Int = dataMap["sensor"] as Int
        val isAvailable = sensorManager.getSensorList(sensorType).isNotEmpty()
        result.success(isAvailable)
        return
    }

    private fun registerSensorListener(arguments:Any, result:MethodChannel.Result){
        try {
            val dataMap = arguments as Map<*, *>
            val sensorType: Int = dataMap["sensor"] as Int
            val rate: Int? = dataMap["delay"] as Int?
            val sampling = rate ?: SensorManager.SENSOR_DELAY_NORMAL
            val sensor = sensorManager.getDefaultSensor(sensorType)
            val register = sensorManager.registerListener(listener, sensor, sampling)
            result.success(register)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }

    private fun unregisterSensorListener(arguments:Any, result:MethodChannel.Result){
        try {
            val dataMap = arguments as Map<*, *>
            val sensorType: Int = dataMap["sensor"] as Int
            val sensor = sensorManager.getDefaultSensor(sensorType)
            sensorManager.unregisterListener(listener, sensor)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.success(false)
        }
    }
}
