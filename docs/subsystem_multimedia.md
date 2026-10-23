# Multimedia Subsystem: Audio, Camera & Display (merlinx)

> [!NOTE]
> Specification of audio routing, camera hardware sensors, and display configuration for the **Xiaomi Redmi Note 9 (`merlinx`)**.

---

## 1. Audio Architecture & Routing
* **Sound Card:** MediaTek MT6768 Sound Core (`mt6768-sound`).
* **Audio HAL Version:** `android.hardware.audio@7.0::IDevicesFactory/default`.
* **Audio Effects Factory:** `android.hardware.audio.effect@7.0::IEffectsFactory/default`.
* **Acoustic Calibration Profile:** `J15S-Audiopara-V13-20220623`.
* **Hardware Routing Endpoints:**
  * `earpiece`: Handset voice call receiver (0.5W).
  * `speaker`: Bottom-firing main loudspeaker.
  * `headset`: 3.5mm TRRS analog audio jack with automatic insertion detection via `ACCDET`.
  * `builtin_mic`: Primary microphone at handset bottom.
  * `back_mic`: Secondary noise-cancelling microphone at handset top.
* **Volume Steps:**
  * Voice call: 1 - 11 levels.
  * System / Ring: 0 - 15 levels.
  * Media: 0 - 15 levels.
* **Sailfish OS Integration:**
  * Driven by PulseAudio with `pulseaudio-modules-droid-hidl`.
  * Configuration: `/etc/pulse/arm_droid_card_custom.pa`.

---

## 2. Camera & Imaging Subsystem
* **Camera Provider HAL:** MediaTek Camera HAL3 (`android.hardware.camera.provider@2.6::ICameraProvider/internal/0`).
* **Flashlight HAL:** Dual-tone LED torch managed via Camera Provider.
* **Camera Hardware Units:**
  1. **Rear Main Camera (`Device 0`):**
     * Sensor: Samsung S5KGM1SP
     * Resolution: 48.0 MP (8000 x 6000), default 4-in-1 binning to 12.0 MP (4000 x 3000)
     * Aperture: f/1.79, 1/2.0" sensor size, 0.8µm pixel pitch
     * Focus: Phase Detection Autofocus (PDAF)
  2. **Front Selfie Camera (`Device 1`):**
     * Sensor: OmniVision OV13B10
     * Resolution: 13.0 MP (4208 x 3120)
     * Aperture: f/2.25, 1/3.06" sensor size, 1.12µm pixel pitch
     * Focus: Fixed Focus
  3. **Rear Ultra-Wide Camera (`Device 21`):**
     * Sensor: Samsung S5K4H7
     * Resolution: 8.0 MP (3264 x 2448)
     * Field of View: 118° ultrawide lens, f/2.2, 1.12µm
  4. **Rear Macro Camera (`Device 22`):**
     * Sensor: OmniVision OV02B10
     * Resolution: 2.0 MP (1600 x 1200)
     * Focus: Macro autofocus (2cm - 10cm range), f/2.4
  5. **Rear Depth Camera (`Device 23`):**
     * Sensor: OmniVision OV2180
     * Resolution: 2.0 MP (1600 x 1200)
     * Function: Hardware stereo depth mapping for portrait bokeh
* **Sailfish OS Integration:**
  * `droidmedia`: Compiled from `android16-qpr2` branch for Android 16 compatibility.
  * GStreamer 1.0 plugins: `gst-droid` (`droidcamsrc`).
  * Jolla Camera application for still capture and video recording.

---

## 3. Display & SurfaceFlinger
* **Panel Identity:** `TRULY_IN` (TRULY Semiconductors FHD+ IPS LCD).
* **Resolution:** 1080 x 2340 pixels (~395 dpi, 19.5:9 aspect ratio).
* **Refresh Rate:** 60.00 Hz.
* **Color Depth:** 24-bit RGB888.
* **Gralloc Allocator:** Gralloc 4.0 (`android.hardware.graphics.allocator@4.0`).
* **Hardware Composer:** HWC 2.1 (`android.hardware.graphics.composer@2.1`).
* **Sailfish OS Integration:**
  * Wayland Compositor (Lipstick) using `hybris-hwcomposer` window system.
  * Pixel ratio: 1.5 in `/usr/share/lipstick/lipstick.conf` and `droid-config-merlinx`.
