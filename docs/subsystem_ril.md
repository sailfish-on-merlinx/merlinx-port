# Telephony & RIL Subsystem Specification (merlinx)

> [!NOTE]
> Detailed technical specification of the Radio Interface Layer (RIL), baseband architecture, SIM slot configuration, and cellular networking for the **Xiaomi Redmi Note 9 (`merlinx`)**. All private device identifiers have been scrubbed.

---

## 1. Modem Architecture & Kernel Interface
* **Modem Type:** MediaTek Helio G85 Integrated LTE Cat-7 (DL) / Cat-13 (UL) Modem.
* **Firmware Partition:** `md1img` (`/dev/block/mmcblk0p39`, 64 MB).
* **Architecture Mode:** `ro.vendor.mtk_ril_mode: c6m_1rild` (single unified RIL daemon controlling both SIM slots).
* **Kernel CCCI Driver:** MediaTek Cross-Core Communication Interface (`/dev/ccci_fs`, `/dev/ccci_md1*`).
* **Modem State Property:** `[vendor.ril.md_status_from_ccci]: [ready]`.

---

## 2. Network Interfaces & Bearers
The MediaTek modem provisions dedicated network interfaces (`ccmni` series) in the Linux network namespace:
* `ccmni0`: **IMS Dedicated Bearer**
  * Protocol: IPv4v6
  * MTU: 1300 bytes
  * Functions: VoLTE SIP signaling, RTP voice packets, Emergency IMS calling.
* `ccmni1`: **Default Internet & General Bearer**
  * Protocol: IPv4v6
  * MTU: 1300 bytes
  * Functions: High-priority data, Web traffic, SUPL AGPS assisted positioning.
* `ccmni2` through `ccmni20`: Available for secondary SIM data, MMS, Tethering, and Dedicated APNs.

---

## 3. Dual SIM Configuration
* **Dual SIM Mode:** Dual SIM Dual Standby (DSDS) via Slot 0 and Slot 1.
* **Supported Technologies:**
  * 2G: GSM/GPRS/EDGE (850, 900, 1800, 1900 MHz)
  * 3G: WCDMA / HSPA+ (Bands 1, 2, 4, 5, 8)
  * 4G: LTE FDD (Bands 1, 2, 3, 4, 5, 7, 8, 20, 28) and LTE TDD (Bands 38, 40, 41)
* **VoPS Status:** Supported (`mVopsSupport = 2, mEmcBearerSupport = 3`), Voice over LTE (VoLTE) fully capable.

---

## 4. HAL Interfaces Exposed
* **Standard AOSP Radio HIDL:**
  * `android.hardware.radio@1.6::IRadio/slot1`
  * `android.hardware.radio@1.6::IRadio/slot2`
  * `android.hardware.radio@1.6::IRadio/imsAospSlot1`
  * `android.hardware.radio@1.6::IRadio/imsAospSlot2`
  * `android.hardware.radio.config@1.3::IRadioConfig/default`
* **MediaTek Vendor Radio HIDL:**
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/mtkSlot1`
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/mtkSlot2`
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/imsSlot1`
  * `vendor.mediatek.hardware.mtkradioex@3.0::IMtkRadioEx/imsSlot2`

---

## 5. Sailfish OS Integration Architecture
1. **Ofono RIL Binder Plugin (`ofono-ril`):**
   * Configured via `/etc/ofono/ril_subscription.conf`.
   * Maps slot 1 to `/slot1` and slot 2 to `/slot2` of `android.hardware.radio@1.6::IRadio`.
2. **Data Call Management (`connman` + `ofono`):**
   * Connection manager activates context over `ccmni1` interface.
   * DNS resolvers automatically set via connman from DHCP/RIL response.
3. **VoLTE Calling (`telephony-ims` / `droid-ril-ims`):**
   * `ccmni0` bearer handled through IMS dynamic service.
