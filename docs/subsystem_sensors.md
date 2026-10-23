# Sensor Subsystem Specification (merlinx)

> [!NOTE]
> Detailed technical registry of all 21 hardware and algorithmic sensor devices for the **Xiaomi Redmi Note 9 (`merlinx`)**.

---

## 1. Hardware Sensor Devices & Calibration

### Accelerometer
* **Device ID:** `0x00000001`
* **Chipset / Name:** Bosch Sensortec `bmi160_acc`
* **Sensor Type:** `android.sensor.accelerometer (1)`
* **Operational Rates:** Min `12.50 Hz`, Max `400.00 Hz`
* **Sampling Buffer (FIFO):** Reserved `3000` events, Max `4500` events
* **Trigger Mode:** Continuous | Non-Wakeup
* **Sailfish OS Mapping:** `sensorfw` -> orientation, auto-rotate, step counter.

### Magnetometer (Compass)
* **Device ID:** `0x00000002`
* **Chipset / Name:** Asahi Kasei `akm09918`
* **Sensor Type:** `android.sensor.magnetic_field (2)`
* **Operational Rates:** Min `5.00 Hz`, Max `50.00 Hz`
* **Sampling Buffer:** No batching | Non-Wakeup
* **Sailfish OS Mapping:** Compass app, navigation heading.

### Gyroscope
* **Device ID:** `0x00000004`
* **Chipset / Name:** Bosch Sensortec `bmi160_gyro`
* **Sensor Type:** `android.sensor.gyroscope (4)`
* **Operational Rates:** Min `12.50 Hz`, Max `400.00 Hz`
* **Sampling Buffer (FIFO):** Reserved `3000` events, Max `4500` events
* **Trigger Mode:** Continuous | Non-Wakeup
* **Sailfish OS Mapping:** Gaming, camera EIS stabilization.

### Ambient Light Sensor
* **Device ID:** `0x00000005`
* **Chipset / Name:** Sensortek `stk3x3x_l` (STK3335)
* **Sensor Type:** `android.sensor.light (5)`
* **Operational Rate:** Min `1.00 Hz`, min delay `0 µs`
* **Trigger Mode:** On-change | Non-Wakeup
* **Sailfish OS Mapping:** Display backlight auto-brightness via `mce`.

### Proximity Sensor
* **Device ID:** `0x00000008`
* **Chipset / Name:** Sensortek `stk3x3x_p` (STK3335)
* **Sensor Type:** `android.sensor.proximity (8)`
* **Operational Rate:** Min `1.00 Hz`, min delay `0 µs`
* **Sampling Buffer (FIFO):** Reserved `100` events, Max `4500` events
* **Trigger Mode:** On-change | Wakeup
* **Sailfish OS Mapping:** Screen blanking during voice calls via `mce`.

---

## 2. MediaTek Hardware-Fused Sensors
* `0x00000003` - **Orientation Sensor**: `android.sensor.orientation (3)`, 50 - 200 Hz.
* `0x00000009` - **Gravity Sensor**: `android.sensor.gravity (9)`, 50 - 200 Hz.
* `0x0000000a` - **Linear Acceleration**: `android.sensor.linear_acceleration (10)`, 50 - 200 Hz.
* `0x0000000b` - **Rotation Vector**: `android.sensor.rotation_vector (11)`, 50 - 200 Hz, FIFO 300.
* `0x0000000e` - **Uncalibrated Magnetometer**: `android.sensor.magnetic_field_uncalibrated (14)`, 5 - 50 Hz.
* `0x0000000f` - **Game Rotation Vector**: `android.sensor.game_rotation_vector (15)`, 50 - 200 Hz.
* `0x00000010` - **Uncalibrated Gyroscope**: `android.sensor.gyroscope_uncalibrated (16)`, 10 - 400 Hz.
* `0x00000011` - **Significant Motion**: `android.sensor.significant_motion (17)`, One-shot, Wakeup.
* `0x00000012` - **Step Detector**: `android.sensor.step_detector (18)`, Special trigger.
* `0x00000013` - **Step Counter**: `android.sensor.step_counter (19)`, On-change.
* `0x00000014` - **Geomagnetic Rotation Vector**: `android.sensor.geomagnetic_rotation_vector (20)`, 50 - 200 Hz.
* `0x00000016` - **Tilt Detector**: `android.sensor.tilt_detector (22)`, Special trigger, Wakeup.
* `0x0000001b` - **Device Orientation**: `android.sensor.device_orientation (27)`, On-change.
* `0x00000023` - **Uncalibrated Accelerometer**: `android.sensor.accelerometer_uncalibrated (35)`, 12.5 - 400 Hz.
* `0x00000065` - **Step Detector Wakeup**: `android.sensor.step_detector (18)`, Special trigger, Wakeup.

---

## 3. Xiaomi OEM Custom Sensor
* `0x00000019` - **Pick-up Sensor (`pickup Wakeup`)**:
  * Type: `xiaomi pick up sensor (33171036)`
  * Trigger: On-change, Wakeup
  * Purpose: Wake display / ambient clock when handset is lifted.

---

## 4. Sailfish OS Integration Strategy
* Sensor communication is managed through `sensorfw` with the `hybris-sensorflinger` backend.
* Configuration overlay: `/etc/sensorfw/primaryuse.config` and `/etc/sensorfw/sensord-hybris.conf`.
