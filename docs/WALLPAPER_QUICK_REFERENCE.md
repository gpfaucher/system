# Wallpaper vs Theme: Quick Reference Card

## 🎯 TL;DR
**Keep Gruvbox. Find portrait wallpapers. Stay flexible.**

- **Approach**: Hybrid theme-first
- **Ultrawide**: Solid #282828
- **Portrait (DP-2)**: 9:16 wallpaper
- **Tool**: wpaperd (when ready)
- **Optional**: wallust for accents

---

## 📊 Decision Path
```
Like Gruvbox? YES
  ↓
Want automation? LATER
  ↓
Use Hybrid Theme-First
  ↓
Phase 1: Manual testing (no code)
Phase 2: wpaperd declarative (optional)
Phase 3: wallust automation (optional)
```

---

## 🖼️ Wallpaper Sources (Gruvbox-compatible)

| Source | Cost | Best For | Search |
|--------|------|----------|--------|
| r/unixporn | Free | Real setups | "gruvbox" |
| GitHub | Free | Pre-curated | "gruvbox-wallpapers" |
| Unsplash | Free | Nature | "autumn forest dark" |
| AI | Free/Paid | Custom | Stable Diffusion prompt |
| MinimalWallpapers | Free | Abstract | earth tones |

### AI Prompt for Portrait (2560x1440)
```
Warm abstract geometric design with earth tones,
minimal style, modern, 2560x1440 vertical,
warm whites and browns with orange accent
```

---

## ✅ Perfect Match Styles
- Warm autumn forests
- Sunset/sunrise (golden light)
- Dark moody landscapes
- Abstract geometric (earth tones)
- Dark night sky with stars

## ❌ Avoid
- Neon/cyberpunk
- Cool blues
- Oversaturated images

---

## 🛠️ Implementation Timeline

| Phase | Time | Action | Code? |
|-------|------|--------|-------|
| 0 | ✓ Done | Research | No |
| 1 | 30 min | Download & test | No |
| 2 | 1 hr | Add wpaperd | Yes |
| 3 | 2-3 hr | Add wallust | Yes |
| 4 | Var | AI generation | Optional |

---

## 📝 Code (Phase 2: wpaperd)

```nix
services.wpaperd = {
  enable = true;
  settings = {
    "DP-2" = {
      path = "/home/gabriel/wallpapers/portrait.jpg";
      mode = "center";
    };
    "HDMI-A-1" = {
      path = "/dev/null";  # Stay solid
    };
  };
};
```

Add to Kanshi profile.exec:
```nix
"${pkgs.wpaperd}/bin/wpaperd reload"
```

---

## 📁 Directory Structure
```
~/.wallpapers/
├── portrait-gruvbox.jpg      (primary)
├── portrait-variant-1.jpg
├── portrait-variant-2.jpg
└── README.md                 (notes)
```

---

## 🎨 Gruvbox Palette Reference

| Element | Color | Hex |
|---------|-------|-----|
| Background | Very dark brown | #282828 |
| Foreground | Warm light gray | #ebdbb2 |
| Red | Warm red-orange | #fb4934 |
| Yellow | Warm yellow | #fabd2f |
| Blue | Muted teal | #83a598 |
| Green | Olive | #b8bb26 |

---

## 🚀 Next Steps

**This week:**
1. ✓ Read this research
2. [ ] Create ~/wallpapers/
3. [ ] Search r/unixporn "gruvbox"

**Next 1-2 days:**
1. [ ] Find 3-5 portrait candidates
2. [ ] Test: `swaybg -i ~/wallpapers/test.jpg`
3. [ ] Pick favorites

**Later (optional):**
1. [ ] Add wpaperd to config
2. [ ] Test with Kanshi profiles
3. [ ] Consider wallust

---

## 🔗 Key Links

- **wallust**: https://github.com/stallmanifold/wallust
- **wpaperd**: https://github.com/danyspin97/wpaperd
- **r/unixporn**: https://reddit.com/r/unixporn/
- **Gruvbox**: https://github.com/morhetz/gruvbox

---

## ✨ Why This Works

1. **Gruvbox wins** - intentionally designed for terminal work
2. **Walltust optional** - grows when you want it
3. **Aspect ratios work** - ultrawide solid + portrait image fits naturally
4. **Zero pressure** - stay with solid color forever if happy
5. **Professional look** - clean ultrawide + visual interest on secondary

---

**Status**: Ready to implement Phase 1 (manual testing)  
**Complexity**: Low → Low-Medium (optional, phased)  
**Time to basic setup**: 30 minutes  
**Full automation**: 1-2 hours (optional)

