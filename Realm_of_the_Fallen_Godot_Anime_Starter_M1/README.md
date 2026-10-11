# REALM OF THE FALLEN — THE AWAKENING
### Milestone 1 · Fallen Radiance · Android-first dark anime fantasy RPG

**Engine:** Godot 4.7.x (standard/GDScript build)  
**Target:** Android, third-person portrait, Vulkan Mobile renderer  
**Dependencies:** none — no plugins, API keys, CDN files or paid assets  
**Status:** Working-project starter **source**, not a finished anime character or a released game. See `docs/KNOWN_LIMITATIONS.md`.

## Start on your Android phone

1. Install the official **Godot Engine 4** Android editor from https://godotengine.org/download/android/ .
2. Unzip **the entire repository/project ZIP**, keeping all folders together.
3. Open Godot → **Import** → select the extracted `project.godot`.
4. Choose **Edit**, let resources import, then press **▶ Run Project**.
5. The game opens in portrait. Walk toward the glowing gateway.

If you see a black screen, inspect Godot's **Output** and **Debugger** tabs. Some phones may not support Vulkan Mobile; see troubleshooting below.

## What's here

- Dark fantasy graveyard: 3D painted ground and stone textures, 275 instanced paving stones, ~1,250 grass tufts, multi-mesh forest canopy, weathered gravestones, ruined colonnades, lit torches and a cyan runic gate.
- Atmospheric sky, height/depth fog, filmic tone mapping, bloom/glow, soft moonlight and one real-time shadow-casting moon.
- Procedural *temporary* Wanderer body with metallic armor, silver hair, blue eyes, coat pieces, sword, breathing and walk animation, visual strike arc.
- Real CharacterBody3D walking, camera follow/orbit, stamina sprint, dodge, guard, mobile joystick and action buttons.
- Mobile HUD with life/stamina meters, objective, compass display and an interactive quality toggle.
- A gate arrival message. Save/quests, enemy AI and loot are **not** part of milestone 1.

**Important:** The starting character is a code-built placeholder. Your polished image reference is *2D concept art*, not a rigged mesh. When your Tripo GLB is ready, replace the `Visual_ReplaceableWithRiggedGLB` node in `scripts/hero.gd` with the imported model and AnimationTree.

## Controls

| Android | Desktop preview |
|---|---|
| Left joystick | W A S D |
| Push joystick fully | Shift (sprint) |
| Swipe unused right/center view | Hold right mouse + drag |
| Attack preview | J |
| Dodge | Space |
| Hold Guard | Hold K |
| Quality button | Quality button |

Other button fingers work while joystick is active. Attack is an **effect preview** — there are no enemies yet.

## Mobile graphics

**HIGH:** 2048-pixel directional shadow map, one real-time shadow caster, atmospheric depth fog, filmic tonemapping, glow, toon-shaded hair/clothing, instanced contact shadows, emissive soul-flames, anti-aliased 3D meshes and instanced landscape props.

**ECO:** quality button disables dynamic shadows and glow, and lowers 3D render scale to 77%. Both modes keep the same geometry. Start in HIGH on a modern Samsung; use ECO if the device warms up or frame rate drops.

Godot **Mobile** has no SSAO, SDFGI or volumetric fog. These visual effects deliberately use supported depth fog, hand-crafted art materials and inexpensive emissive surfaces.

## Github upload

Create repository `realm-of-the-fallen-rebirth` if you haven't already. Upload the contents of the **unpacked project folder** to its root, including `project.godot`, `scenes`, `scripts`, `assets`, `shaders`, and `docs`. **Do not** upload the ZIP as the sole repo file or Godot will not be able to import it directly. GitHub Pages does not run native Godot projects; run inside Godot, then export an Android APK.

## Troubleshooting

- **Vulkan not supported / Mobile renderer fails:** Try a device with Vulkan support. Do not silently change to Compatibility if you need current glow visual fidelity; we can provide an alternate Compatibility preset later.
- **Slow first import:** Let Godot build `.godot/` editor cache. This is local and should not be checked into Git.
- **Frame rate:** Use ECO, reduce device resolution, close background apps and test in an exported APK rather than treating Android editor performance as release performance.
- **Missing files:** Keep all four scripts and every texture alongside project.godot. Don't open just main.tscn alone.

## Next milestone

Replace procedural character with the rigged Tripo GLB and add authentic idle/run animations, solve third-person camera collision and build one polished goblin encounter.

© Original Realm of the Fallen prototype art direction. All project textures in this starter were authored programmatically for this project. No proprietary game models embedded.

## Character generation references

Original concept PNG references are in `assets/reference/`: `wanderer_tpose_no_cape.png`, `separate_cape.png`, `separate_sword.png`. These are **not 3D meshes** and are excluded from the playable scene. Use them for Tripo generation/Blender later.
