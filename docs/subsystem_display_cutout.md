# Display Subsystem: Left Punch-Hole Cutout & Rounded Corners Architecture

## 1. Hardware Overview & Display Metrics

The Xiaomi Redmi Note 9 (`merlinx`) features a 6.53-inch IPS LCD panel with a punch-hole camera cutout located at the **top-left corner**.

* **Resolution:** 1080 × 2340 pixels (FHD+)
* **Aspect Ratio:** 19.5:9
* **Pixel Density:** ~395 PPI (Device Density: 440 dpi, scale factor: 2.75×)
* **Physical Panel Dimensions:** 68 mm × 147 mm
* **Cutout Location:** Top-Left (OmniVision OV13B10 front sensor)

---

## 2. Low-Level Android Surface & Geometry Diagnostics

Extracted directly from the running Android HAL via `dumpsys display`:

```text
DisplayDeviceInfo{"Built-in Screen": uniqueId="local:0", 1080 x 2340, modeId 1, density 440, 394.716 x 394.716 dpi}
Cutout: DisplayCutout{
    insets: Rect(0, 100 - 0, 0)
    waterfall: Insets{left=0, top=0, right=0, bottom=0}
    boundingRect: {Bounds=[Rect(0, 0 - 0, 0), Rect(0, 0 - 133, 100), Rect(0, 0 - 0, 0), Rect(0, 0 - 0, 0)]}
    cutoutSpec: "M -947,0 H -1080 V 100 H -947 V 0 Z@right"
}
RoundedCorners: {
    TopLeft:     radius=106, center=Point(106, 106)
    TopRight:    radius=106, center=Point(974, 106)
    BottomRight: radius=103, center=Point(977, 2237)
    BottomLeft:  radius=103, center=Point(103, 2237)
}
```

### Key Cutout Dimensions
* **Cutout Bounding Box:** `x = 0`, `y = 0`, `width = 133 px`, `height = 100 px`
* **Safe Top Inset:** `100 px`
* **Corner Radius:** `106 px` (top corners), `103 px` (bottom corners)

---

## 3. Native Sailfish OS & Silica Integration

Sailfish OS (starting with SFOS 4.x/5.x) provides built-in dconf support in Silica and Lipstick to account for hardware cutouts and rounded display corners without needing third-party UI hacks (like `nocentralclock`).

### A. Vendor Configuration File
Configured via `/etc/dconf/db/vendor.d/lipstick-cutout.txt`:

```ini
[desktop/sailfish/silica]
cutouts = [[0, 0, 133, 100]]
rounded_corners = [[106, 106, 106], [-106, 106, 106], [103, -103, 103], [-103, -103, 103]]
```

When compiled into `/etc/dconf/db/vendor` via `dconf update` at rootfs generation or package post-install:
1. **Status Bar Layout in Lipstick:**
   * Lipstick's `StatusBar` item checks `/desktop/sailfish/silica/cutouts`.
   * For a left punch hole (`x = 0, width = 133`), Lipstick automatically applies an offset to the left-aligned elements (operator name, active call indicators, and notification icons), pushing them to `x > 133 + Theme.horizontalPageMargin`.
   * The central clock and right-aligned system indicators (battery level, Wi-Fi, cellular signal, profile) remain unaffected and cleanly separated.
2. **Silica Page Headers:**
   * `PageHeader` components automatically pad content vertically by the cutout inset (`100 px`) in portrait mode, guaranteeing that header titles and back-navigation buttons are never occluded by the camera hole.
3. **Rounded Corner Clipping:**
   * Lipstick applies four rounded-corner quadrant masks matching the hardware radii (106px top, 103px bottom), eliminating raw jagged edges at screen boundaries.

---

## 4. Compositor & Display Environment Defaults

Staged in `droid-config-merlinx` under `/var/lib/environment/compositor/droid-hal-device.conf`:

```sh
# Hardware Composer & Physical Geometry for Redmi Note 9
EGL_PLATFORM=hwcomposer
QT_QPA_PLATFORM=hwcomposer
QT_QPA_EGLFS_PHYSICAL_WIDTH=68
QT_QPA_EGLFS_PHYSICAL_HEIGHT=147
LIPSTICK_OPTIONS="-plugin evdevtouch -plugin evdevkeyboard"
```

* `QT_QPA_EGLFS_PHYSICAL_WIDTH=68` and `QT_QPA_EGLFS_PHYSICAL_HEIGHT=147` allow Qt to calculate the exact physical DPI (395 PPI), enabling Silica's dynamic pixel ratio (`theme_pixel_ratio = 1.75`) to scale icons and fonts with pixel-perfect clarity.
