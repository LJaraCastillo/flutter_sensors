package cl.ceisufro.fluttersensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterSensorsPlugin : MethodCallHandler {

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
                channel.invokeMethod("sensor_updated", mapOf("sensor" to event.sensor.type, "data" to data, "accuracy" to event.accuracy))
            }
        }
    }

    companion object {
        lateinit var channel: MethodChannel
        lateinit var sensorManager: SensorManager

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            channel = MethodChannel(registrar.messenger(), "flutter_sensors")
            channel.setMethodCallHandler(FlutterSensorsPlugin())
            sensorManager = registrar.context().getSystemService(Context.SENSOR_SERVICE) as SensorManager
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "is_sensor_available" -> {
                val dataMap = call.arguments as Map<*, *>
                val sensorType: Int= dataMap["sensor"] as Int
                val isAvailable = isSensorAvailable(sensorType)
                result.success(isAvailable)
                return
            }
            call.method == "register_sensor_listener" -> {
                try {
                    val dataMap = call.arguments as Map<*, *>
                    val sensorType: Int = dataMap["sensor"] as Int
                    val rate: Int? = dataMap["rate"] as Int
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
                    var sensorType: Int = dataMap["sensor"] as Int
                    val sensor = sensorManager.getDefaultSensor(sensorType)
                    sensorManager.unregisterListener(listener, sensor)
                    result.success(true)
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.success(false)
                }
                return
            }
            else -> result.notImplemented()
        }
    }

    private fun isSensorAvailable(sensor: Int): Boolean {
        return sensorManager.getSensorList(sensor).isNotEmpty()
    }
}
