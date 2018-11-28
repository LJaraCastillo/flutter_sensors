package cl.ceisufro.fluttersensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
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
            registrar.addViewDestroyListener {
                // If the view is destroyed we are going to remove all the listeners.
                plugin.unregisterAllListeners()
            }
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

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when {
            call.method == "is_sensor_available" -> {
                val dataMap = call.arguments as Map<*, *>
                val sensorType: Int = dataMap["sensor"] as Int
                val isAvailable = isSensorAvailable(sensorType)
                result.success(isAvailable)
                return
            }
            call.method == "register_sensor_listener" -> {
                try {
                    val dataMap = call.arguments as Map<*, *>
                    val sensorType: Int = dataMap["sensor"] as Int
                    val rate: Int? = dataMap["rate"] as Int?
                    val sampling = if (rate == null) SensorManager.SENSOR_DELAY_NORMAL else rate
                    val sensor = sensorManager.getDefaultSensor(sensorType)
                    val register = sensorManager.registerListener(listener, sensor, sampling)
                    result.success(register)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }
                return
            }
            call.method == "unregister_sensor_listener" -> {
                try {
                    val dataMap = call.arguments as Map<*, *>
                    val sensorType: Int = dataMap["sensor"] as Int
                    val sensor = sensorManager.getDefaultSensor(sensorType)
                    sensorManager.unregisterListener(listener, sensor)
                    result.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }
                return
            }
            call.method == "unregister_all_listeners" -> {
                val unregister = unregisterAllListeners()
                result.success(unregister)
                return
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
        sinks.add(sink)
    }

    override fun onCancel(p0: Any?) {
        unregisterAllListeners()
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

    private fun isSensorAvailable(sensor: Int): Boolean {
        return sensorManager.getSensorList(sensor).isNotEmpty()
    }

    private fun unregisterAllListeners(): Boolean {
        return try {
            sensorManager.unregisterListener(listener)
            true
        } catch (ex: Exception) {
            ex.printStackTrace()
            false
        }
    }
}
