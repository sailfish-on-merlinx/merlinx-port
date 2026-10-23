# Xiaomi Redmi Note 9 (merlinx) - Hardware Architecture & Subsystem Map

> [!NOTE]
> This document details the hardware architecture, peripheral mappings, HAL interfaces, and baseline operating characteristics for the **Xiaomi Redmi Note 9 (`merlinx`)**. All private device identifiers have been scrubbed.

---

## 1. Device Overview & Core Architecture
* **Target Device:** Xiaomi Redmi Note 9 (`merlin` / `merlin_in` / `merlinx`)
* **SoC:** MediaTek Helio G85 (MT6768 / MT6769Z)
* **CPU:** 8 cores (2x ARM Cortex-A75 @ 2.0 GHz + 6x ARM Cortex-A55 @ 1.8 GHz)
* **GPU:** ARM Mali-G52 2EEMC2 (Bifrost v3 architecture, Vulkan 1.1, OpenGL ES 3.2)
* **Architecture:** 64-bit (`aarch64`)
* **RAM / Storage:** 4GB / 64GB or 6GB / 128GB eMMC 5.1
* **Kernel Baseline:** Linux 4.14.186 (Stock MIUI 13 SP1A.210812.016) / Linux 4.19.325 (LineageOS 23.2 base)
* **Android Base:** LineageOS 23.2 (`hybris-23.2` / Android 16.0.0_r4 BP4A)

---

## 2. Telephony & Radio Interface Layer (RIL)
* **Architecture:** MediaTek C6M single-rild dual SIM architecture (`ro.vendor.mtk_ril_mode: c6m_1rild`).
* **Kernel Modem Driver:** MediaTek Cross-Core Communication Interface (`/dev/ccci*`).
* **Modem Network Interfaces:**
  * `ccmni0`: Dedicated bearer for IMS / VoLTE signaling and RTP media.
  * `ccmni1`: Default packet data interface (Internet, SUPL, HIPRI).
  * `ccmni2` - `ccmni20`: Additional PDN bearers / network slices.
* **Dual SIM Support:** Dual SIM Dual Standby (DSDS) via Slot 0 and Slot 1.
* **Network Capabilities:**
  * Radio Access: 2G GSM, 3G WCDMA, 4G LTE Cat-7 (DL) / Cat-13 (UL).
  * VoPS Status: Supported (`mVopsSupport = 2, mEmcBearerSupport = 3`), VoLTE fully capable.
  * APN Protocol: IPv4v6 dual stack.
* **HAL Interfaces:**
  * `android.hardware.radio@1.6::IRadio/slot1`
  * `android.hardware.radio@1.6::IRadio/slot2`
  * `android.hardware.radio@1.6::IRadio/imsAospSlot1`
  * `android.hardware.radio@1.6::IRadio/imsAospSlot2`
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/mtkSlot1`
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/mtkSlot2`
* **Sailfish OS Integration:** Handled via `ofono-ril` (Mer-Hybris radio binder) interfacing directly to standard `@1.6` binder services.

---

## 3. Wi-Fi & Wireless Connectivity
* **Chipset:** MediaTek Talbot SoC 1.0 / MT6631 integrated wireless subsystem.
* **Firmware Version:** `t-neptune-mp-soc1_0e1-2015-TALBOT_SOC1_0_E1_ASIC-20211013122101`.
* **Kernel Driver:** `wlan_drv_gen4m` (`vendor.wlan.driver.version: 1_0_1-"20221216201321"`).
* **Interfaces:**
  * `wlan0`: Primary station interface.
  * `wlan1`: Secondary client / concurrency interface.
  * `p2p0`: Wi-Fi Direct interface.
  * `ap0`, `ap1`: SoftAP / Mobile Hotspot interfaces.
* **Capabilities:** 802.11 a/b/g/n/ac (2.4 GHz & 5.0 GHz dual band), Wi-Fi Direct, Hotspot/Tethering, WPA3-SAE, MAC Randomization.
* **HAL Interface:** `android.hardware.wifi@1.5::IWifi/default`.
* **Sailfish OS Integration:** Driven by ConnMan via `wpa_supplicant` with nl80211 driver.

---

## 4. Bluetooth Subsystem
* **Chipset:** MediaTek MT6631 Bluetooth Controller.
* **Core Version:** Bluetooth 5.0 (BLE + BR/EDR).
* **HAL Interface:** `android.hardware.bluetooth@1.1::IBluetoothHci/default` and `android.hardware.bluetooth.audio@2.1`.
* **Supported Audio Codecs:** SBC (priority 1001), AAC (2001), aptX (3001), aptX HD (4001), LDAC (5001).
* **Supported Profiles:** HFP/HSP (v1.7), A2DP (v1.3), AVRCP (v1.6), HID / HOGP, PAN (Network Access), BLE GATT Central & Peripheral, PBAP, MAP.
* **Sailfish OS Integration:** BlueZ 5 with PulseAudio Bluetooth modules and Hybris Bluetooth HCI bridge.

---

## 5. GNSS / GPS & Positioning
* **GNSS Engine:** MediaTek Navigation Location Daemon (`mnld`) with `agpsd`.
* **Constellations:** GPS (USA), GLONASS (Russia), BeiDou (China), Galileo (EU), QZSS (Japan), SBAS.
* **Assistance Services:** A-GPS via SUPL (`supl.google.com:7275`), MSB, MSA, Satellite PVT, Measurement Corrections.
* **HAL Interfaces:**
  * `android.hardware.gnss@2.1::IGnss/default`
  * `vendor.mediatek.hardware.lbs@1.0::ILbs/*`
* **Sailfish OS Integration:** GeoClue with MLS (Mozilla Location Services) and Hybris GNSS provider or MNLD NMEA forwarder.

---

## 6. Sensor Subsystem (21 Hardware & Fusion Sensors)
| ID | Sensor Type | Driver / Name | Vendor | Rate (Min-Max) | Trigger Mode | Wake-Up |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `0x01` | Accelerometer | `bmi160_acc` | Bosch | 12.5 Hz - 400 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x02` | Magnetometer | `akm09918` | Asahi Kasei | 5.0 Hz - 50 Hz | Continuous | Non-Wakeup |
| `0x03` | Orientation | `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous | Non-Wakeup |
| `0x04` | Gyroscope | `bmi160_gyro` | Bosch | 12.5 Hz - 400 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x05` | Ambient Light | `stk3x3x_l` | Sensortek | 1.0 Hz | On-Change | Non-Wakeup |
| `0x08` | Proximity | `stk3x3x_p` | Sensortek | 1.0 Hz | On-Change (FIFO 4500) | Wakeup |
| `0x09` | Gravity | `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous | Non-Wakeup |
| `0x0a` | Linear Acceleration | `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous | Non-Wakeup |
| `0x0b` | Rotation Vector | `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x0e` | Uncalibrated Magnetometer | `MTK` | MediaTek | 5.0 Hz - 50 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x0f` | Game Rotation Vector | `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x10` | Uncalibrated Gyroscope | `MTK` | MediaTek | 10 Hz - 400 Hz | Continuous (FIFO 4500) | Non-Wakeup |
| `0x11` | Significant Motion | `MTK` | MediaTek | N/A | One-Shot | Wakeup |
| `0x12` | Step Detector | `MTK` | MediaTek | N/A | Special-Trigger | Non-Wakeup |
| `0x13` | Step Counter | `MTK` | MediaTek | N/A | On-Change | Non-Wakeup |
| `0x14` | Geomagnetic Rotation Vector| `MTK` | MediaTek | 50 Hz - 200 Hz | Continuous | Non-Wakeup |
| `0x16` | Tilt Detector | `MTK` | MediaTek | N/A | Special-Trigger | Wakeup |
| `0x19` | Pick-up Sensor | `xiaomi pick up sensor` | Xiaomi | N/A | On-Change | Wakeup |
| `0x1b` | Device Orientation | `MTK` | MediaTek | N/A | On-Change | Non-Wakeup |
| `0x23` | Uncalibrated Accelerometer | `MTK` | MediaTek | 12.5 Hz - 400 Hz | Continuous | Non-Wakeup |
| `0x65` | Step Detector Wakeup | `MTK` | MediaTek | N/A | Special-Trigger | Wakeup |
* **Sailfish OS Integration:** Handled via `sensorfw` with `hybris-sensorflinger` plugin reading the HIDL `android.hardware.sensors@2.0/2.1` interface.

---

## 7. Display, Graphics & HWC
* **LCD Panel:** TRULY Inc. Full HD+ IPS LCD (`TRULY_IN`).
* **Resolution:** 1080 x 2340 pixels (~395 ppi, 19.5:9 aspect ratio).
* **Refresh Rate:** 60.00 Hz.
* **Graphics Allocator:** Gralloc 4.0 (`android.hardware.graphics.allocator@4.0::IAllocator/default`).
* **Hardware Composer:** HWC 2.1 (`android.hardware.graphics.composer@2.1::IComposer/default`).
* **Sailfish OS Integration:** Wayland compositor (Lipstick) rendering via libhybris EGL/GLES2 to Gralloc buffer queues.

---

## 8. Input Subsystem
* **Touchscreen Controller:** FocalTech Touch (`fts_ts`) with multi-touch protocol B.
* **Secondary Touch Support:** MediaTek TPD (`mtk-tpd`).
* **Hardware Buttons:** MediaTek Keypad Driver (`mtk-kpd`):
  * `KEY_POWER` (116)
  * `KEY_VOLUMEUP` (115)
  * `KEY_VOLUMEDOWN` (114)
* **Accessory Detection:** MediaTek `ACCDET`:
  * 3.5mm Headphone Jack insertion / removal.
  * Headset inline button click (play/pause, volume).
* **Biometrics:** Goodix rear-mounted capacitive fingerprint sensor (`uinput-goodix`, `android.hardware.biometrics.fingerprint@2.1`).

---

## 9. Audio Subsystem
* **Sound Card:** MediaTek MT6768 Sound Core (`mt6768-sound`).
* **Audio HAL:** `android.hardware.audio@7.0::IDevicesFactory/default`.
* **Acoustic Calibration Profile:** `J15S-Audiopara-V13-20220623`.
* **Physical Endpoints:**
  * Primary Loudspeaker (bottom-firing).
  * Earpiece Receiver (top front).
  * 3.5 mm Audio Jack (headphone out / headset mic in).
  * Primary Microphone (bottom bezel).
  * Noise Suppression Secondary Microphone (top edge).
* **Sailfish OS Integration:** PulseAudio with `pulseaudio-modules-droid-hidl` routing streams to `@7.0` HAL.

---

## 10. Camera & Imaging Subsystem
* **Camera HAL:** MediaTek Camera HAL3 (`android.hardware.camera.provider@2.6::ICameraProvider/internal/0`).
* **Camera Hardware Units:**
  1. **Rear Main Camera (ID 0):** Samsung S5KGM1SP, 48 Megapixels (f/1.79, 1/2.0", 0.8µm, PDAF, 4-in-1 binning to 12 MP).
  2. **Front Camera (ID 1):** OmniVision OV13B10, 13 Megapixels (f/2.25, 1/3.06", 1.12µm).
  3. **Rear Ultra-Wide (ID 21):** Samsung S5K4H7, 8 Megapixels (f/2.2, 118° field of view, 1/4.0", 1.12µm).
  4. **Rear Macro Camera (ID 22):** OmniVision OV02B10, 2 Megapixels (f/2.4, macro autofocus).
  5. **Rear Depth Camera (ID 23):** OmniVision OV2180, 2 Megapixels (f/2.4 depth sensor).
* **Flashlight:** High-CRI dual LED flash via Camera Provider flashlight HAL.
* **Sailfish OS Integration:** Droidmedia compiled from `android16-qpr2` branch, driving GStreamer droidcam plugin.

---

## 11. Battery, Power & Thermal Management
* **Battery Specification:** 5020 mAh (typical) / 4920 mAh (rated) Lithium Polymer.
* **Charging Interface:** USB Type-C, supports 18W Fast Charging (MTK Pump Express / Qualcomm Quick Charge 3.0 protocol).
* **HAL Interfaces:**
  * AIDL `android.hardware.power.IPower/default`
  * `android.hardware.health@2.1::IHealth/default`
  * `init.svc.micharge-hal-1-0`, `init.svc.mi_thermald`
* **Sailfish OS Integration:** `mce` (Mode Control Entity) + `upower` + `thermal-manager`.

---

## 12. Miscellaneous Hardware
* **Infrared Blaster:** Consumer IR transmitter (`android.hardware.ir@1.0::IConsumerIr/default` and AIDL `consumer_ir`).
* **FM Radio:** MediaTek MT6631 integrated FM receiver with short antenna support (`persist.vendor.connsys.fm_chipid = mt6631`).
* **Haptics:** Linear / ERM vibrator motor via AIDL `android.hardware.vibrator.IVibrator/default`.
