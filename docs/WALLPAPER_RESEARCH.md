# Research: Desktop Aesthetic - Wallpaper vs Theme First

**Issue ID**: system-epp  
**Created**: 2026-01-24  
**Status**: Complete Research  
**Labels**: knowledge, reference, theming  

---

## Quick Summary

**Question**: Should you choose wallpaper first or theme first for a cohesive desktop aesthetic?

**Answer**: **HYBRID THEME-FIRST APPROACH**
- Keep Gruvbox Dark Medium (current theme) as the authority
- Optionally add wallust for accent color extraction
- Find portrait-aspect wallpapers for DP-2 monitor
- Keep solid #282828 on ultrawide

**Why**: Gruvbox is intentional, well-optimized, and already integrated. Adding wallpaper should complement it, not replace it.

---

## Your Current Setup

| Component | Value |
|-----------|-------|
| Theme | Gruvbox Dark Medium (Stylix) |
| Font | Monaspace Neon |
| WM | River (Wayland) |
| Monitor 1 (Primary) | 3440x1440 ultrawide (HDMI-A-1) |
| Monitor 2 (Secondary) | 2560x1440 portrait (DP-2, rotated 90°) |
| Laptop Display | 3840x2400 (eDP-1, 2.0 scale) |
| Current Background | Solid #282828 (Gruvbox bg0) via swaybg |

---

## Three Decision Paths

### 1. Theme-First (Current - RECOMMENDED)
**Philosophy**: Theme drives aesthetic, find wallpapers that match

**Approach**:
- Keep Gruvbox as authority
- Find wallpapers in warm earth tones
- Manual curation process
- No code changes initially

**Pros**:
- Simple, low complexity
- Gruvbox consistency maintained
- Optimized for terminal work
- Intentional aesthetic choices

**Cons**:
- Manual wallpaper selection work
- Limited to complementary wallpapers
- Requires careful color matching

**When to choose**: If you like Gruvbox as-is and want occasional visual variety

---

### 2. Wallpaper-First (Alternative)
**Philosophy**: Wallpaper drives aesthetic, theme adapts to image

**Tools**: wallust (modern Rust implementation)

**Approach**:
- Use wallust to generate theme from wallpaper
- Theme changes when wallpaper changes
- Full automation via Kanshi profiles

**Pros**:
- Fully cohesive aesthetic
- Single source of truth (wallpaper)
- Unique per-wallpaper themes
- Modern approach

**Cons**:
- Moderate complexity
- Gruvbox investment lost
- Theme changes constantly
- Less control over palette

**When to choose**: If you want wallpaper to drive entire aesthetic and accept theme changes

---

### 3. Hybrid (BEST BALANCE)
**Philosophy**: Keep theme base, use wallpaper for visual interest + optional accent colors

**Approach**:
- Gruvbox Dark Medium = authoritative base
- wallust extracts only accent colors (optional)
- Wallpaper complements theme
- Kanshi integrates both

**Pros**:
- Best of both worlds
- Gruvbox consistency + wallpaper interest
- Flexible and scalable
- Minimal initial complexity

**Cons**:
- Requires both theme + wallpaper considerations
- Moderate implementation if automated

**When to choose**: For balanced, professional aesthetic with room to grow

---

## Tool Comparison

| Tool | Type | Language | Speed | Flexibility | Learning Curve | Notes |
|------|------|----------|-------|-------------|-----------------|-------|
| **wallust** | Palette Generator | Rust | Fast ⚡⚡⚡ | Good | Easy | Modern, Wayland-native, recommended |
| **pywal** | Palette Generator | Python | Fast ⚡⚡ | Excellent | Medium | Classic, large ecosystem, customizable |
| **matugen** | Material Design 3 | ? | Fast ⚡⚡⚡ | Limited | Easy | Modern aesthetic, not ideal for Gruvbox |
| **Stylix Built-in** | Scheme Generator | Nix | Slow ⚡ | Limited | Easy | Already integrated, less powerful |

### Recommendation
**wallust** if you go with wallpaper-first or hybrid automation. Already have all infrastructure via Stylix for theme-first.

---

## The Multi-Monitor Challenge

### The Problem
Your setup has conflicting aspect ratios:
- **Ultrawide (3440x1440)**: 2.39:1 aspect ratio
  - Very few native wallpapers exist
  - Most images distort when stretched
  
- **Portrait (2560x1440)**: 0.56:1 aspect ratio (essentially 9:16)
  - Requires custom composition
  - Different aesthetic than landscape
  
- **Laptop (3840x2400 @2.0 scale)**: 16:10 aspect ratio
  - Can use any wallpaper, scales up
  - May not match other monitors

### Recommended Solution: Hybrid Monitor Approach

**Ultrawide (HDMI-A-1)**: Keep Solid #282828
- Reason: No suitable 3440x1440 wallpapers exist
- Benefit: Clean, professional look
- Fallback: Always stable appearance
- No file management needed

**Portrait (DP-2)**: Use 9:16 Portrait Wallpaper
- Reason: Natural aspect ratio fit
- Benefit: Visually interesting
- Sources: Vertical images, rotated landscapes, abstract
- Management: wpaperd per-monitor daemon

**Laptop (eDP-1)**: Use Portrait Wallpaper when alone
- Reason: When not in multi-monitor setup
- Benefit: Consistent aesthetic
- Flexibility: Can differ from portrait monitor

### Why This Works
1. **Aspect ratio**: Each monitor gets appropriate composition
2. **Simplicity**: Only manage 1-2 wallpapers, not pairs
3. **Professional**: Ultrawide stays clean and focused
4. **Scalable**: Can expand to automation later

---

## Wallpaper Curation for Gruvbox

### Gruvbox Color Palette

```
Dark Mode (Your Current):
┌─────────────────────────────────────────────┐
│ Background: #282828 (Very dark gray/brown)  │
│ Foreground: #ebdbb2 (Warm light gray)       │
│                                             │
│ Accent Colors:                              │
│ Red:       #fb4934 (Warm red-orange)        │
│ Orange:    #fe8019                          │
│ Yellow:    #fabd2f (Warm yellow)            │
│ Green:     #b8bb26 (Olive green)            │
│ Cyan:      #8ec07c                          │
│ Blue:      #83a598 (Muted teal/blue-green)  │
│ Magenta:   #d3869b                          │
│ Brown:     #d65d0e                          │
└─────────────────────────────────────────────┘

Aesthetic: Warm, earthy, high contrast, terminal-friendly
Philosophy: Optimized for long coding sessions
```

### Compatible Wallpaper Styles

✅ **Perfect Match**:
- Warm autumn forests (oranges, browns, golds)
- Sunset/sunrise scenes (warm golden light)
- Dark moody landscapes (forests, mountains at night)
- Vintage/warm film aesthetic (fade, grain, warmth)
- Abstract geometric in earth tones (modern, clean)
- Dark night sky with stars (cool but dark)

❌ **Avoid**:
- Neon/cyberpunk colors (clash with warm palette)
- Cool blue/cyan dominant images (conflict with teal)
- Oversaturated/highly vivid colors (too busy)
- Very bright scenes (high contrast with dark bg)

### Best Wallpaper Sources

1. **r/unixporn** - Real Setups
   - Search: "gruvbox"
   - Best for: Seeing actual desktop combinations
   - Benefit: Community feedback and inspiration
   - URL: https://www.reddit.com/r/unixporn/

2. **GitHub gruvbox-wallpapers Repos**
   - Search: "gruvbox-wallpapers"
   - Best for: Pre-curated compatible images
   - Benefit: Already color-matched
   - Quality: High, tested with theme

3. **AI Generation** - Custom Sizes
   - Tools: Stable Diffusion, Midjourney, DALL-E 3
   - Best for: Ultrawide and portrait sizes
   - Benefit: Infinite variety, custom aspect ratios
   - Cost: Free (Stable Diffusion) or paid (others)

4. **Nature Photography**
   - Style: Autumn, forests, dark landscapes
   - Best for: Realistic, natural aesthetic
   - Sources: Unsplash, Pexels, Pixabay
   - Challenge: Finding correct aspect ratios

5. **Minimal/Abstract Design**
   - Style: Geometric, subtle gradients, earth tones
   - Best for: Professional, clean look
   - Sources: MinimalWallpapers, Designer portfolios
   - Benefit: Works well at any scale

### AI Prompt Templates

For **portrait 2560x1440 vertical (9:16)**:
```
"Warm abstract geometric design with earth tones,
minimal style, modern, 2560x1440 vertical,
warm whites and browns with orange accent colors"
```

Alternative:
```
"Dark moody forest vertical composition, autumn tones,
abstract and mysterious, vertical 9:16 format,
warm browns, golds, and rust colors"
```

For **ultrawide 3440x1440** (if you decide to use it):
```
"Warm autumn landscape ultrawide panorama,
earthy brown and orange tones, cinematic,
3440x1440 aspect ratio, gruvbox aesthetic"
```

---

## Implementation Roadmap

### Phase 0: Research & Discovery (Current)
**Time**: 1-2 hours
**Actions**:
- [x] Research theme vs wallpaper approaches
- [ ] Explore r/unixporn gruvbox setups (10 min)
- [ ] Browse GitHub gruvbox-wallpapers repos (15 min)
- [ ] Find 3-5 portrait wallpaper candidates (30 min)
- [ ] Create `~/wallpapers/` directory structure (5 min)

### Phase 1: Manual Testing (No Code)
**Time**: 30 minutes
**Actions**:
- [ ] Download 3-5 candidate wallpapers to `~/wallpapers/`
- [ ] Test with swaybg manually: `swaybg -i ~/wallpapers/test.jpg`
- [ ] Evaluate each for Gruvbox color compatibility
- [ ] Select favorite(s)
- [ ] No git/nix changes yet

### Phase 2: Declarative Setup (Optional)
**Time**: 1 hour
**Actions**:
- [ ] Add wpaperd service to NixOS config
- [ ] Configure per-monitor wallpaper paths
- [ ] Integrate with Kanshi display profiles
- [ ] Test profile switching with wallpaper change
- [ ] Commit to git

### Phase 3: Advanced Automation (Future)
**Time**: 2-3 hours
**Actions**:
- [ ] Add wallust for accent color generation
- [ ] Create Stylix theme from wallust output
- [ ] Auto-update theme on wallpaper change
- [ ] Per-profile theme + wallpaper combinations
- [ ] Full automation

### Phase 4: AI Generation (Optional)
**Time**: Variable
**Actions**:
- [ ] Use AI to generate perfect ultrawide wallpaper
- [ ] Generate multiple portrait variations
- [ ] Test color compatibility with Gruvbox
- [ ] Integrate into rotation

---

## NixOS Implementation Code

### Minimal wpaperd Setup (Phase 2)

```nix
# Add to modules/home/theme.nix

services.wpaperd = {
  enable = true;
  systemdTarget = "graphical-session.target";
  settings = {
    # Display portrait wallpaper on DP-2 (portrait monitor)
    "DP-2" = {
      path = "/home/gabriel/wallpapers/portrait-gruvbox.jpg";
      mode = "center";
      scaling = "fit";
    };
    # No wallpaper on HDMI-A-1 (ultrawide stays solid)
    "HDMI-A-1" = {
      path = "/dev/null";  # Fallback to solid color
    };
  };
};
```

### Kanshi Integration (Phase 2)

```nix
# In services.kanshi profile.exec, add:

profile.exec = [
  "${pkgs.libnotify}/bin/notify-send 'Display Profile' 'Dual monitor: Portrait + Ultrawide'"
  "${pkgs.wpaperd}/bin/wpaperd reload"  # Refresh wallpapers per profile
];
```

### Optional wallust Setup (Phase 3)

```nix
# Add to modules/home/theme.nix

programs.wallust = {
  enable = true;
  settings = {
    # Keep Gruvbox base colors, extract accents from wallpaper
    backend = "kde";  # or other backend
    color_space = "lch";  # Better for color accuracy
  };
};

# On wallpaper change, run:
# wallust run /path/to/wallpaper.jpg --scheme dark
```

### Directory Structure

```
~/.wallpapers/
├── portrait-gruvbox.jpg      (Default portrait wallpaper)
├── portrait-variant-1.jpg    (Alternatives)
├── portrait-variant-2.jpg
├── ultrawide-gruvbox.jpg     (If using ultrawide wallpaper)
└── README.md                 (Notes on each image)
```

---

## Decision Tree

```
START: "I want wallpaper + theme to be cohesive"

1. How much do you like Gruvbox?
   Very much / Use for work  → THEME-FIRST (keep it)
   Not sure / Open to change → WALLPAPER-FIRST (let wallpaper decide)

2. (If Theme-First) Do you want automation?
   No / Keep it simple      → Manual selection only
   Maybe later / Flexible   → HYBRID (Phase 1 now, Phase 2+ later)
   Yes / Full automation    → HYBRID (implement all phases)

3. (If Wallpaper-First) How often wallpaper change?
   Rarely / Static          → Manual selection only
   Weekly / Moody           → Semi-automatic with wallust
   Daily / Dynamic          → Full automation with profile switching

4. For multi-monitor setup:
   Ignore aspect ratio      → Single wallpaper stretched (not recommended)
   Match each monitor       → HYBRID MONITOR (Gruvbox ultrawide + portrait wallpaper)
   Simplify management      → Solid color + accent (Phase 0)

RESULT:
→ For your setup: HYBRID THEME-FIRST
  Phase 1: Find portrait wallpapers, test manually
  Phase 2: Add wpaperd, integrate with Kanshi
  Phase 3+: Optional wallust automation
```

---

## Comparison Matrix

| Factor | Theme-First | Wallpaper-First | Hybrid (Rec.) |
|--------|------------|-----------------|--------------|
| **Complexity** | Low | Medium | Low-Medium |
| **Aesthetic Cohesion** | Medium | High | High |
| **Flexibility** | High | Low | High |
| **Maintenance** | Low | Medium | Low-Medium |
| **Learning Curve** | Minimal | Medium | Low |
| **Gruvbox Consistency** | Excellent | Lost | Excellent |
| **Setup Time** | 30 min | 2-3 hrs | 1-2 hrs |
| **Automation Potential** | None | Full | Full |
| **Cost** | Free | Free | Free |

---

## Key Insights

### Why Gruvbox?
Gruvbox is **intentionally designed**:
- Warm earth tones for visual comfort
- High contrast for readability (terminal work)
- Proven across communities (popular for good reason)
- Optimized for long coding sessions
- Already integrated with your Stylix setup

### Why Hybrid?
Hybrid approach **best balances**:
- Gruvbox's intentional design
- Wallpaper's visual variety
- System simplicity
- Scalability to future automation
- Zero forced decisions

### Why Portrait Wallpaper on Secondary Monitor?
- Natural 9:16 aspect ratio
- Ultrawide images are extremely rare (3440x1440)
- Portrait monitor aspect ratio fits vertical compositions
- Clean separation: solid (work focus) + visual interest (secondary)
- Easier to find/generate

---

## Next Steps

### Immediate (This session)
1. Review this research
2. Create `~/wallpapers/` directory
3. Bookmark r/unixporn and gruvbox-wallpapers repos

### Soon (1-2 days)
1. Search r/unixporn for gruvbox setups (inspiration)
2. Browse gruvbox-wallpapers GitHub collections
3. Download 3-5 portrait wallpaper candidates
4. Test with swaybg: `swaybg -i ~/wallpapers/test.jpg`

### Later (when desired)
1. Commit favorites to `~/wallpapers/`
2. Add wpaperd to NixOS config (Phase 2)
3. Consider wallust for accent colors (Phase 3)

### Advanced (optional future)
1. AI generate custom ultrawide wallpaper
2. Automate theme generation from wallpaper
3. Per-profile wallpaper + theme combinations

---

## Resources

### Primary References
- **wallust** (Rust palette generator): https://github.com/stallmanifold/wallust
- **pywal** (Python palette generator): https://github.com/dylanaraps/pywal
- **Gruvbox** (Theme): https://github.com/morhetz/gruvbox
- **wpaperd** (Wallpaper daemon): https://github.com/danyspin97/wpaperd
- **Stylix** (NixOS theming): https://github.com/danth/stylix

### Community Inspiration
- **r/unixporn**: https://www.reddit.com/r/unixporn/ (search "gruvbox")
- **Wallpaper sources**: Unsplash, Pexels, Pixabay, MinimalWallpapers

### Tools
- AI Generation: Stable Diffusion, Midjourney, DALL-E 3
- Image Editing: GIMP, ImageMagick (cropping/resizing)
- Wallpaper Management: wpaperd, swaybg, swww

---

## Summary

**Recommendation**: Keep Gruvbox Dark Medium as your primary aesthetic authority. Find 2-3 portrait wallpapers that complement it (warm earth tones, natural or abstract). Use solid #282828 on ultrawide. Later, optionally add wpaperd for per-monitor management and wallust for accent colors.

**Why**: Balances intentional design, visual interest, system simplicity, and scalability.

**Effort**: 30 minutes for manual testing, 1-2 hours for automation setup (optional).

**Result**: Professional, cohesive desktop aesthetic with Gruvbox consistency and wallpaper variety.

---

**Issue Status**: ✅ COMPLETE  
**Labels**: knowledge, reference, theming  
**Beads ID**: system-epp

