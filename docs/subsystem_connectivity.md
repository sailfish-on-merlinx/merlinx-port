# Connectivity Subsystem: Wi-Fi, Bluetooth & GNSS (merlinx)

> [!NOTE]
> Specification of wireless connectivity hardware, firmware versions, and routing configurations for the **Xiaomi Redmi Note 9 (`merlinx`)**. All private device identifiers have been scrubbed.

---

## 1. Wi-Fi (WLAN) Subsystem
* **Integrated Wireless SoC:** MediaTek Connsys Talbot SoC 1.0 / MT6631.
* **Firmware Version:** `t-neptune-mp-soc1_0e1-2015-TALBOT_SOC1_0_E1_ASIC-20211013122101`.
* **Kernel Driver:** `wlan_drv_gen4m` (`1_0_1-"20221216201321"`).
* **Interfaces:**
  * `wlan0`: Primary station interface.
  * `wlan1`: Secondary client / concurrency interface.
  * `p2p0`: Wi-Fi Direct interface.
  * `ap0`: SoftAP / Mobile Hotspot interface.
  * `ap1`: Concurrent hotspot interface.
* **Protocol Standards:** IEEE 802.11 a/b/g/n/ac (2.4 GHz & 5 GHz dual band, MIMO).
* **Security Modes:** Open, WEP, WPA-PSK, WPA2-PSK, WPA3-SAE, WPA-Enterprise (802.1x).
* **HAL Interface:** `android.hardware.wifi@1.5::IWifi/default`.
* **Sailfish OS Integration:**
  * ConnMan manages Wi-Fi scanning, connection, and IP provisioning.
  * `wpa_supplicant` runs with `-Dnl80211 -iwlan0`.
  * Hotspot handled by ConnMan tethering daemon activating `ap0`.

---

## 2. Bluetooth Subsystem
* **Chipset:** MediaTek MT6631 Bluetooth Subsystem.
* **Core Version:** Bluetooth 5.0 (BLE + BR/EDR).
* **HAL Interfaces:**
  * `android.hardware.bluetooth@1.1::IBluetoothHci/default`
  * `android.hardware.bluetooth.audio@2.1::IBluetoothAudioProvidersFactory/default`
* **Audio Codecs:**
  * SBC (Priority: 1001)
  * AAC (Priority: 2001)
  * aptX (Priority: 3001)
  * aptX HD (Priority: 4001)
  * LDAC (Priority: 5001)
* **Supported Profiles:**
  * Handsfree Profile (HFP 1.7) & Headset Profile (HSP)
  * Advanced Audio Distribution Profile (A2DP 1.3)
  * Audio/Video Remote Control Profile (AVRCP 1.6)
  * Human Interface Device Profile (HID over GATT / HOGP)
  * Personal Area Network Profile (PAN / `bt-pan`)
  * Phonebook Access Profile (PBAP 1.2)
  * Message Access Profile (MAP 1.4)
  * Object Push Profile (OPP)
* **Sailfish OS Integration:**
  * BlueZ 5 daemon communicates with Bluetooth controller via libhybris HCI bridge.
  * PulseAudio handles Bluetooth audio sink and source routing.

---

## 3. GNSS / GPS Subsystem
* **Navigation Daemon:** MediaTek Navigation Location Daemon (`mnld`) & `agpsd`.
* **Constellations:**
  * GPS (L1 C/A)
  * GLONASS (L1)
  * BeiDou (B1)
  * Galileo (E1)
  * QZSS (L1)
  * SBAS (WAAS, EGNOS, MSAS, GAGAN)
* **Assistance Services:**
  * A-GPS over SUPL (`supl.google.com:7275`).
  * Capabilities: MSB, MSA, Satellite PVT, Measurement Corrections.
* **HAL Interfaces:**
  * `android.hardware.gnss@2.1::IGnss/default`
  * `vendor.mediatek.hardware.lbs@1.0::ILbs/*`
* **Sailfish OS Integration:**
  * GeoClue location framework.
  * MNLD can provide NMEA stream to local socket or pseudo-tty for GPS daemon.
