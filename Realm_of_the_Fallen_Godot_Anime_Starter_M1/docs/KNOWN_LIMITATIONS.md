# Milestone 1 — design / technical notes

## Completed in starter

- Self-contained Godot source scene with GDScript game world, procedural hero, and touch HUD.
- Stylized atmospheric lighting, depth fog, emission + bloom, moonlight directional cascaded shadows, mobile instanced environment.
- Camera follow and orbit, on-screen analog movement, basic collision body, sprint stamina, dodge, guarding, cosmetic attack VFX.
- Small-world bounds keep players near curated scenery.

## Limitations

- The playable mesh is a procedural stand-in, not the matching character in the concept PNG and not production-quality anime facial geometry. Tripo rigged GLB to replace it.
- No real blade hit detection, NPC/enemy AI, quests, inventory, save system or sound yet. They're deferred intentionally.
- The compass text is illustrative, not a true heading tracker; objective is a fixed milestone prompt.
- World is designed for portrait/mobile, with primitive solid-ground collision and boundaries. Props are not yet all individual physics obstacles.
- Current script has not been verified in Godot Android runtime in this environment. Real phone rendering/performance must be tested before assuming gameplay FPS or shader support.
- Dynamic shadows cast by foliage may be expensive on mid-range phones. The HIGH/ECO control offers a simple fallback.
- Some user devices might have GPU/driver incompatibility with Vulkan Mobile; those will need a Compatibility preset.

## Art direction

**Fallen Radiance** — midnight blues, dark teal forests, antique gold inlay, matte slate gravestones, luminous cyan soulflames, warm silver moonlight and a restrained anime edge. Future character models should keep readable eye/hair silhouettes and original angular armour shapes.

## Follow-up priorities

1. Verify Godot 4.7.x import and Android run, fix any specific parser/runtime warnings.
2. Test portrait HUD clipping and multitouch on actual phones.
3. Replace temporary hero with rigged Tripo GLB; establish AnimationTree before extending combat.
4. Add animated goblin, combat damage and enemy tells.
5. Add first interaction checkpoint, victory feedback and save slot.
