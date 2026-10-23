# Xiaomi Redmi Note 9 (merlinx) - Live Hardware Partition Topology

## Partition Layout (Authoritative live hardware query)
Total Physical eMMC Size: 64 GB / 128 GB (`/dev/block/mmcblk0`)

| Block Device | Partition Name | Size | Filesystem / Role |
| :--- | :--- | :--- | :--- |
| `mmcblk0p1` | `recovery` | 64 MB | Lineage / TWRP Recovery |
| `mmcblk0p2` | `nvram` | 4 MB | Raw modem IMEI & calibration flash |
| `mmcblk0p3` | `protect1` | 8 MB | MTK radio protection 1 |
| `mmcblk0p4` | `protect2` | 10 MB | MTK radio protection 2 |
| `mmcblk0p6` | `seccfg` | 2 MB | Bootloader security configuration |
| `mmcblk0p7` | `sec1` | 2 MB | Security state & RPMB authentication |
| `mmcblk0p10` | `metadata` | 16 MB | Dynamic partition metadata & key master |
| `mmcblk0p11` | `nvcfg` | 32 MB | NVRAM runtime configuration |
| `mmcblk0p12` | `nvdata` | 64 MB | Runtime calibration data (`ext4`) |
| `mmcblk0p13` | `persist` | 48 MB | Sensor calibration, factory data (`ext4`) |
| `mmcblk0p19` | `proinfo` | 3 MB | SKU and serial identifiers |
| `mmcblk0p30` | `lk` | 1 MB | Secondary bootloader (Little Kernel) |
| `mmcblk0p32` | `dtbo` | 8 MB | Device Tree Blob Overlay |
| `mmcblk0p33` | `vbmeta` | 4 KB | Android Verified Boot root |
| `mmcblk0p34` | `boot` | 64 MB | Boot image (Kernel + hybris ramdisk) |
| `mmcblk0p35` | `sspm` | 1 MB | Sensor Processing Module firmware |
| `mmcblk0p36` | `spmfw` | 1 MB | System Power Management firmware |
| `mmcblk0p37` | `tee` | 5 MB | TrustZone OS |
| `mmcblk0p38` | `logo` | 8 MB | Splash screen graphic |
| `mmcblk0p39` | `md1img` | 64 MB | MediaTek modem DSP baseband firmware |
| `mmcblk0p44` | `super` | ~4.5 GB | Retrofitted Dynamic Partitions (`system`, `vendor`, `product`) |
| `mmcblk0p45` | `cache` | 448 MB | Cache partition (`ext4`) |
| `mmcblk0p46` | `userdata` | ~53 GB | User data (`f2fs`/`ext4`) |

## Dynamic Partition Handling
`merlinx` uses Retrofitted Dynamic Partitions. The physical partition `mmcblk0p44` (`super`) contains logical sub-partitions:
* `system`
* `vendor`
* `product`

In Sailfish OS, dynamic partitions are mapped via `parse-android-dynparts` or systemd `dmsetup.service` and excluded from early fstab parsing (`makefstab_skip_entries /system /vendor /product`).
