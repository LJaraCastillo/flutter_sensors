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
    private var lastUpdate: Calendar = Calendar.getInstance()
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
        val currentTime = Calendar.getInstance()
        val diff = (currentTime.timeInMillis - lastUpdate.timeInMillis) * 1000
        if (event != null && (customDelay && diff > interval!!)) {
            val data = arrayListOf<Float>()
            event.values.forEach {
                data.add(it)
            }
            notifyEvent(event.sensor.type, data, event.accuracy)
            lastUpdate = currentTime
        }
    }

    private fun notifyEvent(sensorId: Int, data: ArrayList<Float>, accuracy: Int) {
        val resultMap = mutableMapOf<String, Any?>(
                "sensorId" to sensorId,
                "data" to data,
                "accuracy" to accuracy)
        eventSink?.success(resultMap)
    }
}