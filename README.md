# Sailfish OS for Xiaomi Redmi Note 9 (merlinx)

Hardware adaptation port of Sailfish OS 5.1 (Pispala) to the Xiaomi Redmi Note 9 (`merlin` / `merlin_in` / `merlinx`) based on LineageOS 23.2 (Android 16 base) and Mer-Hybris HADK.

## Specifications
* **SoC:** MediaTek Helio G85 (MT6768 / MT6769Z)
* **CPU:** 8-core (2x 2.0 GHz Cortex-A75 & 6x 1.8 GHz Cortex-A55)
* **GPU:** ARM Mali-G52 MC2
* **Architecture:** 64-bit (`aarch64`)
* **Base Android:** LineageOS 23.2 (`hybris-23.2` / Android 16.0.0_r4)
* **Sailfish OS Version:** 5.1.0.11 (Pispala)

## Repositories in this Organization
* [`merlinx-port`](https://github.com/sailfish-on-merlinx/merlinx-port): Port workspace, build scripts, local manifests, documentation.
* [`droid-config-merlinx`](https://github.com/sailfish-on-merlinx/droid-config-merlinx): Sailfish OS configuration rpm package and sparse overlays.
* [`droid-hal-merlinx`](https://github.com/sailfish-on-merlinx/droid-hal-merlinx): Hardware Abstraction Layer RPM packaging.
* [`droid-hal-version-merlinx`](https://github.com/sailfish-on-merlinx/droid-hal-version-merlinx): Adaptation version package.
* [`merlinx-patches`](https://github.com/sailfish-on-merlinx/merlinx-patches): Hardware patches.
* [`hybris-boot`](https://github.com/sailfish-on-merlinx/hybris-boot): `a16` branch fork with `fixup-mountpoints` for `merlinx`.
* [`merlinx-backup`](https://github.com/sailfish-on-merlinx/merlinx-backup) (Private): Verified golden hardware partition dumps.

## Building
Follow the Hardware Adaptation Development Kit (HADK) guide along with `hadk-faq` and `hadk-hot`.
