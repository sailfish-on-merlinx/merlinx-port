# Sailfish OS Hardware Enablement Blueprint: Xiaomi Redmi Note 9 (merlinx)

## 1. Executive Summary & First-Boot Philosophy

The goal for the **Xiaomi Redmi Note 9 (`merlinx`)** Sailfish OS port is to achieve a **maximal, feature-complete hardware enablement on first boot**, avoiding the prolonged multi-month bring-up cycles typical of community ports.

By leveraging:
1. The **official Mer-Hybris HADK standards**,
2. Historical solutions established by the `#sailfishos-porters` community for MediaTek MT6768 (notably the **Volla Phone 22 / Volla X23 `halium-mimameid`** port), and
3. Our verified reverse-engineered hardware state from the live reference Android 12 userspace (`0856d9e10407`),

we have designed a unified integration blueprint covering every major hardware component on `merlinx`.

---

## 2. Comprehensive Hardware Topology Matrix

| Subsystem | Hardware Component / IC | Kernel Driver / Node | Userspace HAL / Daemon | Native Sailfish OS Integration Mechanism |
| :--- | :--- | :--- | :--- | :--- |
| **Back Main Camera (48MP)** | Samsung S5KGM1SP MIPI RAW | `s5kgm1sp_mipi_raw` / `/dev/kd_camera_hw` | `android.hardware.camera.provider@2.4` / `cameraserver` | `droidmedia` + `minimediaservice` + `audiosystem-passthrough-dummy-af` + `gstreamer1.0-droid` |
| **Back Ultra-Wide (8MP)** | Samsung S5K4H7 (118° FoV) | `s5k4h7yx_mipi_raw` | CameraProvider Camera ID 2 | Switchable via multi-camera lens selector in `droidcamsrc` |
| **Back Macro Camera (2MP)** | GalaxyCore GC02M1 | `gc02m1_macro_mipi_raw` | CameraProvider Camera ID 3 | Accessible via Camera HAL3 index 3 |
| **Back Depth Sensor (2MP)** | OmniVision OV2180 | `ov2180_mipi_raw` | CameraProvider Camera ID 4 | Depth point cloud / portrait mode auxiliary stream |
| **Front Selfie Camera (13MP)** | OmniVision OV13B10 Punch-Hole | `ov13b10_mipi_raw` | CameraProvider Camera ID 1 | Primary front camera in `jolla-camera` |
| **Flashlight / Torch** | Richtek / LED191 Driver | `/sys/class/flashlight_core/flashlight/flashlight_strobe` | Flashlight HAL | `jolla-settings-system-flashlight` or sysfs trigger |
| **Fingerprint Sensor** | Goodix GF3208 / GF5216 Rear | `/dev/goodix_fp` + TEE `/dev/teei_fp` | `android.hardware.biometrics.fingerprint@2.1` | `sailfish-fpd-community` + `sailfish-devicelock-fpd` |
| **Consumer IR Blaster** | MTK IRTX on GPIO 12 (38 kHz PWM) | `/dev/irtx` | `android.hardware.ir@1.0` | Character device `/dev/irtx` (compatible with `consumerir` / LIRC) |
| **Battery & 18W Fast Charge** | MT6358 Fuel Gauge + SMB1351 Charger | `/sys/class/power_supply/battery` | Health HAL 2.1 | `mce` battery monitor with `99-ignore.ini` (blacklisting `cw-bat`) |
| **Thermal Monitoring (28 Zones)**| MT6768 TS Sensors (CPU, GPU, Skin, PA) | `/sys/class/thermal/thermal_zone*` | Thermal HAL 2.0 | Autonomous kernel throttling via `mtktscpu` / `thermal-cpufreq` |
| **Wi-Fi 802.11ac (Talbot)** | MT6631 Wi-Fi Core | `wlan_drv_gen4m.ko` / `/dev/wmtWifi` | `wpa_supplicant` | `wlan-module-load.service` (`echo S > /dev/wmtWifi`) + ConnMan |
| **Bluetooth 5.0 LE** | MT6631 Bluetooth Controller | `bt_drv_connac1x.ko` / MTK UART | BlueZ 5 HCI | MAC extraction from `/mnt/vendor/nvdata/APCFG/APRDEB/BT_Addr` + `bluebinder` |
| **Cellular RIL & Dual SIM** | MediaTek C6M Baseband (LTE Cat-7) | CCCI driver / `/dev/ccci*` | `mtkfusionrild` (`android.hardware.radio@1.6`) | `ofono-binder-plugin` + `ofono-binder-plugin-ext-mtk` (`slot1`, `slot2`) |
| **VoLTE & IMS Signaling** | AP SIP Stack (`volte_stack`) | Dedicated bearer `ccmni0` (Table 1002) | `volte_stack` + `volte_ua` + `volte_imsm` | `init.volte.rc` supervised in `droid-hal` + policy routing |
| **GNSS / GPS (4 Constellations)**| MTK GNSS Core (GPS/GLO/BDS/GAL) | `/dev/stgps` / `@mtk_hal2mnl` | `mnld` + `mtk_agpsd` (SUPL 2.0) | `geoclue-provider-hybris` (with `>= ReadyState` fix) or `mtk-nmea-bridge` |

---

## 3. Deep Subsystem Enablement Specifications

### A. Camera Subsystem (4 + 1 Penta-Camera Array)

The Redmi Note 9 features an extensive 5-camera optical array:
1. **Rear Main**: Samsung S5KGM1SP (48 MP `0.8µm`, $f/1.79$, 6P lens, 4-in-1 $1.6µm$ Super Pixel binning).
2. **Rear Ultra-Wide**: Samsung S5K4H7 (8 MP, $1.12µm$, $f/2.2$, $118^\circ$ field-of-view).
3. **Rear Macro**: GalaxyCore GC02M1 (2 MP, $1.75µm$, $f/2.4$, $2\text{cm}-10\text{cm}$ fixed autofocus).
4. **Rear Depth**: OmniVision OV2180 (2 MP, $1.75µm$, $f/2.4$).
5. **Front Selfie**: OmniVision OV13B10 (13 MP, $1.12µm$, $f/2.25$).

#### Actuators & Voice Coil Motors (VCM)
In `merlin.dts`, lens autofocus actuators are configured across three I2C addresses:
- Dongwoon `DW9800WAF`
- Dongwoon `DW9714VAF`
- Coretronic `CN3927AF`

#### Native Sailfish OS Bring-up Strategy:
- **AudioFlinger Unblocker**: On Android 11/12 bases, `cameraserver` and `minimediaservice` block indefinitely waiting for `media.audio_flinger` IPC service. Sailfish uses PulseAudio, not AudioFlinger. We must include **`audiosystem-passthrough-dummy-af`** in `patterns-sailfish-device-adaptation-merlinx.inc` to stub out this lookup, preventing camera deadlock.
- **Pipeline Config (`/etc/gst-droid/gstdroidcodec.conf`)**:
  ```ini
  [decoders]
  video/hevc=1
  video/avc=0

  [decoder-quirks]
  video/mp4v-es=use-codec-supplied-height;use-codec-supplied-width
  video/avc=use-codec-supplied-height;use-codec-supplied-width
  ```
- **Primary Camera ID Mapping**:
  - `ID 0`: Back Main 48 MP
  - `ID 1`: Front 13 MP
  - `ID 2`: Back Ultra-Wide 8 MP

---

### B. Fingerprint Sensor (Goodix GF3208 / GF5216)

#### Hardware Wiring:
- **Device Node**: `/dev/goodix_fp` (major 498, minor 0).
- **Secure World (TEE)**: `/dev/teei_fp` (major 503, minor 0) connected to Microtrust Mobicore/TEEI.
- **DTS Node (`&goodix_fp`)**:
  - `pinctrl-0 = <&fingerprint_default>`
  - `pinctrl-1 = <&fingerprint_reset_high>`
  - `pinctrl-2 = <&fingerprint_reset_low>`
  - `pinctrl-3 = <&fingerprint_spi_cs_low>`
  - `pinctrl-4 = <&fingerprint_spi_cs_high>`

#### Native Sailfish OS Bring-up Strategy:
- **Udev Rule (`/etc/udev/rules.d/60-goodix.rules`)**:
  ```udev
  KERNEL=="goodix_fp", OWNER="system", GROUP="system", MODE="0660"
  KERNEL=="teei_fp", OWNER="system", GROUP="system", MODE="0660"
  ```
- **Packaging**:
  - Include `sailfish-fpd-community` (developed by `piggz`).
  - Provide `sailfish-devicelock-fpd` which interfaces via `android.hardware.biometrics.fingerprint@2.1::IBiometricsFingerprint`.

---

### C. Consumer IR Blaster (MTK IRTX)

#### Hardware Wiring:
- **Device Node**: `/dev/irtx` (major 488, minor 0).
- **Platform Device**: `&irtx_pwm` on GPIO 12 with a 38 kHz modulated carrier wave.

#### Native Sailfish OS Bring-up Strategy:
- **Udev Rule (`/etc/udev/rules.d/60-irtx.rules`)**:
  ```udev
  KERNEL=="irtx", OWNER="root", GROUP="users", MODE="0666"
  ```
- **Application Compatibility**: Userland apps (`harbour-irremote` or standard Linux LIRC tools) can directly open `/dev/irtx` and issue `ioctl(fd, IRTX_IOC_SEND, &pulse_buffer)` without needing Android HIDL overhead.

---

### D. Flashlight / Torch

#### Hardware Wiring:
- **Driver**: `flashlights_led191`.
- **Sysfs Interface**: `/sys/class/flashlight_core/flashlight/flashlight_strobe` and `flashlight_current`.

#### Native Sailfish OS Bring-up Strategy:
- **Symlink / Udev Rule**:
  Create an event-driven systemd service or udev rule linking to standard Sailfish OS torch node:
  ```bash
  # Turn ON torch:
  echo 20 > /sys/class/flashlight_core/flashlight/flashlight_current
  echo 1 > /sys/class/flashlight_core/flashlight/flashlight_strobe

  # Turn OFF torch:
  echo 0 > /sys/class/flashlight_core/flashlight/flashlight_strobe
  ```
- **Package**: `jolla-settings-system-flashlight`.

---

### E. Battery Management & 18W Fast Charging

#### Hardware Wiring:
- **Fuel Gauge**: MediaTek MT6358 PMIC gauge (`/sys/class/power_supply/battery` and `bms`).
- **Parallel Fast Charger**: Qualcomm SMB1351 secondary charger IC located on I2C-7 at address `0x55` (`smb1351-charger@55`).
- **Battery Capacity**: 5020 mAh (typ) Li-Polymer.
- **Fast Charging**: 18W fast charging with input parameters `ta_ac_charger_current = 2050000` (2.05A) and `hvdcp_charger_current = 3000000` (3.0A).
- **Reverse OTG Power Bank**: `CONFIG_MTK_REVERSE_CHG_ENABLE=y`.

#### Native Sailfish OS Bring-up Strategy:
- **MCE Blacklist Fix (`/etc/mce/99-ignore.ini`)**:
  As proven on MT6768 `halium-mimameid`, MediaTek exposes auxiliary power supply nodes (`cw-bat`, `charger`) which cause MCE to rapidly toggle between charging and discharging states. We deploy:
  ```ini
  [BatteryUDevDeviceBlacklist]
  cw-bat=true
  charger=true
  ```
  This ensures MCE strictly tracks the real `/sys/class/power_supply/battery` node.

---

### F. Thermal Management (28 Thermal Zones & Autonomous Governor)

#### Hardware Topology:
- 28 thermal zones monitoring AP clusters, GPU Mali-G52, PMIC, Battery, RF Power Amplifier, and Charging ICs.
- 108 cooling devices (`cooling_device0` to `cooling_device107`) controlling CPU core clock gating, GPU throttling, and charging current capping.
- **Thresholds**: Hot throttling starts at 85°C; emergency thermal shutdown triggers at 117°C (CPU) and 60°C (Battery).

#### Native Sailfish OS Bring-up Strategy:
- Thermal regulation is managed entirely in the Linux kernel by MediaTek drivers (`mtktscpu`, `mtktsbattery`, `thermal-cpufreq`). No complex userspace daemon is required; Sailfish OS runs securely and stably without overheating.

---

### G. Wi-Fi & Bluetooth (MT6631 Talbot Connectivity Core)

#### Wi-Fi Enablement:
- **Kernel Module**: `wlan_drv_gen4m.ko`.
- **MediaTek WMT Trigger**: The Wi-Fi adapter is activated via the Wireless Management Task:
  ```bash
  # Wait for NVRAM properties:
  while [ "$(getprop vendor.service.nvram_init)" != "Ready" ]; do sleep 0.2; done
  # Enable Wi-Fi client mode:
  echo S > /dev/wmtWifi
  setprop wifi.interface wlan0
  ```
- **Systemd Service**: Managed by `wlan-module-load.service`.

#### Bluetooth 5.0 LE Enablement:
- **Kernel Driver**: `bt_drv_connac1x.ko` and BlueZ 5 HCI.
- **MAC Address Extraction**: MediaTek stores the factory BT MAC in NVRAM. We run `droid-get-bt-address.sh` on boot:
  ```bash
  hexdump -s 0 -n 6 -ve '/1 "%02X:"' /mnt/vendor/nvdata/APCFG/APRDEB/BT_Addr | sed "s/:$//g" > /var/lib/bluetooth/board-address
  ```
- **Service**: `bluebinder.service` starts BlueZ against `/dev/ttyMT2` / `stp_uart`.

---

### H. Cellular Telephony, Dual SIM & VoLTE

#### RIL Interface:
- **Radio Interface Version**: Pinned to `1.6` (matching `android.hardware.radio@1.6` on Android 12 / LineageOS 23.2).
- **Slots**: Dual SIM Dual Standby (DSDS) via `slot1` and `slot2`.
- **Plugin**: `ofono-binder-plugin` with `ofono-binder-plugin-ext-mtk`.
- **Technologies**: Explicitly pinned to `gsm,umts,lte` (modem is 4G Cat-7; prevents false 5G NR registration drops).

#### VoLTE & Bearer Routing:
- Supervised by `init.volte.rc` in `droid-hal`:
  - `volte_md_status`, `volte_imsm_93`, `volte_stack`, `volte_ua`, `volte_imcb`.
- IMS dedicated bearer `ccmni0` with MTU 1300 routed over table `1002`.
- USIM AKA authentication over `/dev/socket/volte_imsa1`.

---

### I. GNSS / GPS Positioning

- **Daemon**: `mnld` (PID 891) + `mtk_agpsd` (PID 1057).
- **Assistance**: OMA SUPL 2.0 with TLS to `supl.google.com:7275` across GPS, GLONASS, BeiDou, and Galileo.
- **Integration**:
  - Hybris Path: `geoclue-provider-hybris` patched with `>= NetworkManager::ReadyState` (preventing karatep's captive portal assistance failure).
  - Native Path: `mtk-nmea-bridge` reading literal NMEA sentences from `@mtk_mnl2hal` directly into `/dev/ttyGPS`.

---

## 4. First-Boot Deliverables Checklist

- [x] Full hardware mapping extracted from live handset and kernel device tree (`merlin.dts`).
- [x] Verified MediaTek MT6768 adaptation patterns from Volla X23 (`halium-mimameid`) studied and integrated.
- [x] Kernel defconfig maximal overrides applied.
- [ ] Droid-config sparse files (`binder.conf`, `wlan-module-load.service`, `droid-get-bt-address.sh`, `99-ignore.ini`) staged in `droid-config-merlinx`.
- [ ] Droid-HAL RPM packages compiled in Platform SDK.
- [ ] Installable Sailfish OS rootfs kickstart image created.
