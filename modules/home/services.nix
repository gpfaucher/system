{ ... }:

{
  # KDE Plasma handles services natively via System Settings:
  # - Display configuration (kscreen)
  # - Night Color (blue light filter)
  # - Power management and screen locking
  # - Window tiling (Plasma 6 native tiling or KWin scripts)
  # EasyEffects: installed system-wide in audio.nix
  # Safe for output effects (EQ, compression) with Bluetooth headsets.
  # Avoid input effects with BT — they confuse WirePlumber's autoswitch.
  # If BT mic routing breaks, add the BT loopback to EasyEffects' blocklist.
}
