# OpenCode Theming with Gruvbox Colors - Research Summary

## Investigation Overview
**Date**: Jan 24, 2026  
**OpenCode Version**: 1.1.25  
**Terminal Color Support**: truecolor (24-bit) ✓  
**System**: NixOS Linux

---

## Key Findings

### 1. OpenCode Built-in Theme Support

**OpenCode HAS built-in Gruvbox theme!**

According to the official [OpenCode Themes Documentation](https://opencode.ai/docs/themes), OpenCode comes with several built-in themes including:

✅ **`gruvbox`** - Based on the Gruvbox theme (https://github.com/morhetz/gruvbox)

### Other Built-in Themes Available:
- `system` - Adapts to your terminal's background color
- `tokyonight` - Based on Tokyonight theme
- `everforest` - Based on Everforest theme
- `ayu` - Based on Ayu dark theme
- `catppuccin` - Based on Catppuccin theme
- `catppuccin-macchiato` - Catppuccin variant
- `kanagawa` - Based on Kanagawa theme
- `nord` - Based on Nord theme
- `matrix` - Hacker-style green on black
- `one-dark` - Based on Atom One Dark
- Plus more continuously being added

---

## 2. How to Configure OpenCode Theme

### Method 1: Using the Theme Selector (Interactive)

**Keybind**: `<leader>t` (where leader is `Ctrl+X`)

```
Ctrl+X, t  →  Opens theme selection dialog
```

Current keybinds in your config:
- `theme_list`: `"<leader>t"` 
- `leader`: `"ctrl+x"`

### Method 2: Configuration File

Add the theme setting to `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "gruvbox"
}
```

---

## 3. About the "System" Theme

**What it does:**
- Automatically adapts to your terminal's color scheme
- **Generates a custom gray scale** based on your terminal's background color
- **Uses ANSI colors (0-15)** for syntax highlighting and UI elements
- **Preserves terminal defaults** using `"none"` for text and background colors
- Respects your terminal's color palette

**Will it work with Ghostty's Gruvbox theme?**

✅ **YES** - The `system` theme will inherit and respect Ghostty's Gruvbox color scheme because:
1. It uses ANSI colors (0-15) from your terminal's palette
2. Ghostty's Gruvbox theme defines these ANSI colors correctly
3. OpenCode will automatically adapt to the terminal's colors

**However**, using the built-in `gruvbox` theme is more reliable because:
- It has predefined, tested Gruvbox colors
- Consistent appearance across different terminal configurations
- Explicit color definitions rather than relying on terminal palette

---

## 4. Configuration File Location & Format

### Current Config Hierarchy

Themes are loaded from (in order, later overrides earlier):

1. **Built-in themes** - Embedded in the binary (includes `gruvbox`)
2. **User config directory** - `~/.config/opencode/themes/*.json`
3. **Project root directory** - `<project-root>/.opencode/themes/*.json`
4. **Current working directory** - `./.opencode/themes/*.json`

### Where to Add the Theme Setting

**File**: `~/.config/opencode/opencode.json`

**Current content**: The file is symlinked from NixOS Home Manager:
```
~/.config/opencode/opencode.json → /nix/store/.../opencode.json
```

**Managed by**: `modules/home/opencode.nix` in your system flake

### Adding Theme to Your NixOS Config

Since your OpenCode config is managed by Home Manager, add the theme to `modules/home/opencode.nix`:

```nix
# In modules/home/opencode.nix, within the home.file."...opencode.json".text section:
home.file.".config/opencode/opencode.json".text = builtins.toJSON {
  "$schema" = "https://opencode.ai/config.json";
  
  theme = "gruvbox";  # ← Add this line
  
  model = "anthropic/claude-sonnet-4-5";
  small_model = "anthropic/claude-haiku-4-5";
  
  autoupdate = true;
  # ... rest of config
};
```

---

## 5. Custom Theme Support (If Needed)

OpenCode supports creating custom themes in JSON format.

### Create Custom Theme

**Location**: `~/.config/opencode/themes/my-theme.json`

**Format Example**:
```json
{
  "$schema": "https://opencode.ai/theme.json",
  "defs": {
    "gb-bg0": "#282828",
    "gb-fg0": "#fbf1c7",
    "gb-red": "#cc241d",
    "gb-green": "#98971a"
  },
  "theme": {
    "primary": {
      "dark": "gb-red",
      "light": "gb-green"
    },
    "text": "gb-fg0",
    "background": "gb-bg0",
    "syntaxKeyword": "gb-red",
    "syntaxString": "gb-green"
    // ... more color definitions
  }
}
```

**Color Definition Options**:
- Hex colors: `"#ffffff"`
- ANSI colors: `3` (0-255)
- Color references: `"primary"` or custom names like `"gb-red"`
- Dark/light variants: `{"dark": "#000", "light": "#fff"}`
- Terminal defaults: `"none"` (uses terminal's default)

---

## 6. Verification and Testing

### Verify Your Environment

✅ **Truecolor Support**: Already enabled
```bash
echo $COLORTERM
# Output: truecolor
```

✅ **Modern Terminal**: Ghostty supports truecolor by default

✅ **OpenCode Version**: 1.1.25 (supports all themes)

### How to Verify Theme is Applied

1. **Interactive verification**: Press `Ctrl+X, t` to see theme selector
2. **Check current theme**: Look at OpenCode config with:
   ```bash
   opencode debug config | grep theme
   ```
3. **Visual confirmation**: Launch OpenCode and check if gruvbox colors are applied

---

## 7. Terminal Color Inheritance vs Built-in Theme

### Comparison

| Aspect | System Theme | Gruvbox Theme |
|--------|--------------|---------------|
| Inherits from terminal | ✅ Yes | ❌ No (uses built-in) |
| Works with Ghostty Gruvbox | ✅ Yes | ✅ Yes |
| Consistency | ⚠️ Depends on terminal | ✅ Always consistent |
| Customization | Limited | Built-in, good |
| Best for | Custom terminals | Standard Gruvbox |

**Recommendation**: Use the built-in `gruvbox` theme for guaranteed consistency.

---

## 8. Implementation Steps

### Option A: Interactive Change (Immediate)

1. Open OpenCode: `opencode`
2. Press: `Ctrl+X` then `t`
3. Select: `gruvbox` from the list
4. ✓ Theme applied immediately for current session

### Option B: Permanent Change via NixOS Config

1. Edit: `modules/home/opencode.nix`
2. Add `theme = "gruvbox";` to the opencode.json configuration
3. Rebuild: `sudo nixos-rebuild switch --flake .#laptop`
4. Restart OpenCode

### Option C: Direct Manual Edit

1. Edit: `~/.config/opencode/opencode.json` (not recommended - overwritten by NixOS)
2. Add: `"theme": "gruvbox"`
3. Restart OpenCode

---

## 9. Troubleshooting

### Theme Not Appearing

**Check 1**: Verify truecolor support
```bash
echo $COLORTERM
# Should output: truecolor or 24bit
```

**Check 2**: Verify config syntax
```bash
cat ~/.config/opencode/opencode.json | jq .theme
# Should output: "gruvbox"
```

**Check 3**: Check resolved configuration
```bash
opencode debug config | grep -i theme
```

**Check 4**: Clear cache (if needed)
```bash
rm -rf ~/.cache/opencode/
```

### Colors Look Different from Expected

**Likely causes:**
1. Terminal not supporting truecolor → Set `export COLORTERM=truecolor`
2. Terminal padding overriding colors → Not OpenCode issue
3. Terminal font affecting appearance → Adjust terminal settings

---

## 10. Documentation References

**Official OpenCode Theme Docs**:  
https://opencode.ai/docs/themes

**Available Themes Section**:
- Lists all built-in themes
- System theme explanation
- Custom theme creation guide
- JSON format specification

**Config Documentation**:  
https://opencode.ai/docs/config/

---

## Summary

### Quick Answer to Your Question

**To theme OpenCode with Gruvbox colors:**

1. **Built-in Gruvbox theme exists** ✅
2. **Add to config**: `"theme": "gruvbox"` in opencode.json
3. **Or use interactively**: Press `Ctrl+X, t` and select `gruvbox`
4. **System theme also works** if you want to inherit from Ghostty's Gruvbox
5. **No custom theme needed** - use the built-in one

### Configuration Syntax

```json
{
  "$schema": "https://opencode.ai/config.json",
  "theme": "gruvbox",
  "model": "anthropic/claude-sonnet-4-5",
  // ... rest of config
}
```

### NixOS Implementation

Add to `modules/home/opencode.nix` in the `opencode.json` configuration:
```nix
theme = "gruvbox";
```

---

## Next Steps

1. ✅ Update NixOS config with theme setting
2. ✅ Rebuild system: `sudo nixos-rebuild switch --flake .#laptop`
3. ✅ Restart OpenCode and verify theme applied
4. ✅ Optional: Test system theme as alternative if desired

