package cl.ceisufro.fluttersensors

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel
import java.util.*


class SensorStreamHandler(private val sensorManager: SensorManager, sensorId: Int, private var interval: Int?) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor: Sensor? = sensorManager.getDefaultSensor(sensorId)
    private var eventSink: EventChannel.EventSink? = null
    private var lastUpdate: Long = 0
    private var customDelay: Boolean = false

    init {
        interval = interval ?: SensorManager.SENSOR_DELAY_NORMAL
        configSensor(interval!!)
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        if (sensor != null) {
            this.eventSink = eventSink
            startListener()
        }
    }

    override fun onCancel(arguments: Any?) {
        stopListener()
    }

    private fun configSensor(interval: Int) {
        this.interval = interval
        this.customDelay = interval > SensorManager.SENSOR_DELAY_NORMAL
    }

    private fun startListener() {
        sensorManager.registerListener(this, sensor, interval!!)
    }

    fun stopListener() {
        sensorManager.unregisterListener(this)
    }

    fun updateInterval(interval: Int?) {
        if (interval != null) {
            configSensor(interval)
            stopListener()
            startListener()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        /// Not implemented
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null && isValidTime(event.timestamp / 1000)) {
            val data = arrayListOf<Float>()
            event.values.forEach {
                data.add(it)
            }
            notifyEvent(event.sensor.type, data, event.accuracy, (event.timestamp / 1000000).toInt())
            lastUpdate = event.timestamp / 1000
        }
    }

    private fun isValidTime(time: Long): Boolean {
        if (customDelay) {
            val diff = time - lastUpdate
            return diff > (interval!! - 1000)
        }
        return true
    }

    private fun notifyEvent(sensorId: Int, data: ArrayList<Float>, accuracy: Int, timestamp: Int) {
        val resultMap = mutableMapOf<String, Any?>(
                "sensorId" to sensorId,
                "data" to data,
                "accuracy" to accuracy,
                "timestamp" to timestamp)
        eventSink?.success(resultMap)
    }
}
