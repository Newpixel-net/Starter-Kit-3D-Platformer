# 🧪 ENEMY SYSTEM TEST VERIFICATION

This document provides a comprehensive checklist for testing the enemy system implementation.

## ✅ Pre-Test Verification

### Files Present
All required files should exist on the branch:

- ✅ **Animation Resources** (5 files):
  - `models/enemy/Idle.res` (18 KB)
  - `models/enemy/attack.res` (55 KB)
  - `models/enemy/death.res` (55 KB)
  - `models/enemy/hit.res` (24 KB)
  - `models/enemy/walk.res` (35 KB)

- ✅ **Scene Files**:
  - `objects/enemy.tscn` - Enemy scene with all components
  - `scenes/levels/level_01_jungle.tscn` - Test level with enemy instance

- ✅ **Scripts**:
  - `scripts/enemy.gd` - Complete AI system (350+ lines)
  - `scripts/player.gd` - Updated with `take_damage()` function

- ✅ **Documentation**:
  - `ENEMY_SYSTEM_COMPLETE.md` - Full technical documentation
  - `QUICK_START.md` - Quick start guide
  - `TEST_VERIFICATION.md` - This file

---

## 🎮 Test Setup in Godot

### 1. Open the Project
1. Launch Godot 4.x
2. Open the Starter-Kit-3D-Platformer project
3. Wait for import to complete (30-60 seconds)

### 2. Verify Animation Resources
The .res files should be properly imported:

**How to Check:**
```
1. Open Godot FileSystem panel
2. Navigate to models/enemy/
3. Verify all 5 .res files are present (not just .fbx.import)
4. If missing, reimport: right-click each .fbx file → Reimport
```

### 3. Open Enemy Scene
**Test the enemy scene directly:**

```
1. In FileSystem: objects/enemy.tscn → Right-click → "Open Scene"
2. In Scene tree, select Character → AnimationPlayer
3. In Animation panel (bottom), verify dropdown shows:
   - attack
   - death
   - hit
   - idle
   - walk
4. Play each animation to verify they work
```

**Expected Result:** All 5 animations should play smoothly without errors.

---

## 🧪 In-Game Testing

### Test 1: Enemy Spawns in Level
**What to test:** Enemy appears and functions in the game level.

**Steps:**
1. Open `scenes/levels/level_01_jungle.tscn`
2. Press F6 to run the level
3. Look for the enemy on Platform2 (to the right of spawn)

**Expected Result:**
- ✅ Enemy appears on the second platform
- ✅ Enemy plays idle animation
- ✅ No errors in console
- ✅ Console shows: `🤖 Enemy spawned at (5, 1, -3)`

**Location:** The enemy is at position (5, 1, -3), which is on Platform2

---

### Test 2: Idle State
**What to test:** Enemy plays idle animation when player is far away.

**Steps:**
1. Run the level (F6)
2. Keep player away from the enemy (distance > 5 units)
3. Observe the enemy

**Expected Result:**
- ✅ Enemy stands still
- ✅ Idle animation plays continuously
- ✅ No movement

---

### Test 3: Patrol Behavior
**What to test:** Enemy patrols back and forth on the platform.

**Steps:**
1. Run the level (F6)
2. Stay far from the enemy (outside detection range)
3. Watch the enemy for 10-15 seconds

**Expected Result:**
- ✅ Enemy walks left and right
- ✅ Walk animation plays during movement
- ✅ Enemy pauses at patrol endpoints
- ✅ Patrol distance: ~3 units each direction
- ✅ Console shows patrol messages

**Troubleshooting:** If enemy doesn't patrol, check `PatrolTimer` in enemy.tscn.

---

### Test 4: Detection & Chase
**What to test:** Enemy detects and chases the player.

**Steps:**
1. Run the level (F6)
2. Move player close to enemy (within 5 units)
3. Observe enemy behavior

**Expected Result:**
- ✅ Enemy turns toward player
- ✅ Walk animation plays
- ✅ Enemy chases player at chase_speed (4.0)
- ✅ Console shows: `👀 Player detected!`

**Detection Range:** 5 units (sphere around enemy)

---

### Test 5: Attack Behavior
**What to test:** Enemy attacks when player is close.

**Steps:**
1. Run the level (F6)
2. Move player very close to enemy (within 1.5 units)
3. Stand still near enemy

**Expected Result:**
- ✅ Attack animation plays
- ✅ Player takes damage
- ✅ Console shows: `⚔️ Attacking player!`
- ✅ Console shows: `💥 Player took 1 damage!`
- ✅ Player dies (current implementation: any damage = death)
- ✅ Attack cooldown: 1.5 seconds between attacks

**Attack Range:** 1.5 units

---

### Test 6: Player Damages Enemy (Spin Attack)
**What to test:** Player can damage enemy with spin attack.

**Steps:**
1. Run the level (F6)
2. Move close to enemy
3. Press **[Shift]** to perform spin attack
4. Hit the enemy during spin

**Expected Result:**
- ✅ Enemy plays hit animation
- ✅ Enemy knocked back slightly
- ✅ Enemy health decreases by 1
- ✅ Console shows: `💥 Enemy hit! Health: X/3`
- ✅ After 3 hits: Enemy plays death animation

---

### Test 7: Enemy Death
**What to test:** Enemy dies after taking 3 damage.

**Steps:**
1. Run the level (F6)
2. Spin attack the enemy 3 times
3. Observe the third hit

**Expected Result:**
- ✅ After 3rd hit: Death animation plays
- ✅ Console shows: `💀 Enemy died!`
- ✅ Enemy is removed from scene after 2 seconds
- ✅ No errors when enemy is removed

---

### Test 8: Player Out of Range
**What to test:** Enemy returns to patrol when player leaves.

**Steps:**
1. Run the level (F6)
2. Get close to trigger chase
3. Move player far away (> 5 units)
4. Wait 1-2 seconds

**Expected Result:**
- ✅ Enemy stops chasing
- ✅ Enemy returns to patrol behavior
- ✅ Console shows: `❌ Player lost`

---

## 🐛 Common Issues & Solutions

### Issue: Enemy doesn't appear
**Solution:**
- Check that `objects/enemy.tscn` is properly saved
- Verify enemy instance in `level_01_jungle.tscn`
- Check console for errors

### Issue: Animations don't play
**Solution:**
- Verify all 5 .res files exist in `models/enemy/`
- Check AnimationPlayer in enemy.tscn has animations loaded
- Reimport .fbx files if needed

### Issue: Enemy doesn't chase
**Solution:**
- Player must be in "player" group (check player.gd line 43)
- Check DetectionArea radius is 5.0
- Verify detection_range in enemy.gd is 5.0

### Issue: Player doesn't take damage
**Solution:**
- Verify player.gd has `take_damage()` function (line 328)
- Check AttackArea collision mask includes layer 1
- Verify attack_timer cooldown is working

### Issue: Spin attack doesn't damage enemy
**Solution:**
- Check enemy is on collision layer 4
- Verify player spin attack area detects layer 4
- Check enemy.gd `take_damage()` function exists

---

## 📊 Test Results Checklist

Use this checklist to track your testing:

- [ ] ✅ All .res files imported correctly
- [ ] ✅ Enemy scene animations playable
- [ ] ✅ Enemy spawns in level
- [ ] ✅ Idle state works
- [ ] ✅ Patrol behavior works
- [ ] ✅ Detection/chase works
- [ ] ✅ Attack behavior works
- [ ] ✅ Player takes damage
- [ ] ✅ Spin attack damages enemy
- [ ] ✅ Hit animation plays
- [ ] ✅ Enemy dies after 3 hits
- [ ] ✅ Death animation plays
- [ ] ✅ Enemy removed after death
- [ ] ✅ Chase ends when player leaves range
- [ ] ✅ No console errors

---

## 🎯 Performance Verification

### Expected Console Output (No Errors)

When running the level, you should see:

```
🤖 Enemy spawned at (5, 1, -3)
👀 Player detected!
⚔️ Attacking player!
💥 Player took 1 damage!
💀 Player died!
```

Or when damaging enemy:

```
💥 Enemy hit! Health: 2/3
💥 Enemy hit! Health: 1/3
💥 Enemy hit! Health: 0/3
💀 Enemy died!
```

### No Errors Expected

The console should NOT show:
- ❌ "res file not found"
- ❌ "Animation not found"
- ❌ "Cannot call method on null instance"
- ❌ "Invalid get index"

---

## 📝 Additional Testing Ideas

### Advanced Tests (Optional)

1. **Multiple Enemies:**
   - Add 2-3 more enemy instances to the level
   - Test that they work independently

2. **Different Platforms:**
   - Move enemy to different platforms
   - Test edge detection and falling

3. **Player Jump Attack:**
   - Test if enemy detects player jumping over it
   - Verify chase works in 3D space

4. **Combat Flow:**
   - Attack enemy once, run away
   - Verify enemy returns to patrol
   - Return and finish killing enemy

---

## 🎉 Success Criteria

The enemy system is **fully functional** if:

✅ All 14 checklist items pass
✅ No console errors during gameplay
✅ All 6 AI states work correctly
✅ Player and enemy damage systems work
✅ Animations play smoothly

---

## 📚 Next Steps After Testing

Once all tests pass:

1. **Expand Enemy Types:**
   - Create variations (fast enemy, tank enemy, ranged enemy)
   - Adjust stats in enemy.tscn inspector

2. **Add More Features:**
   - Health bars above enemies
   - Different attack patterns
   - Sound effects for attacks/death

3. **Level Design:**
   - Add more enemies to existing levels
   - Create enemy-focused platforming challenges

4. **Polish:**
   - Add particle effects for attacks
   - Add death effects (fade out, explosion, etc.)
   - Add knockback on player hit

---

**Testing completed by:** _________________
**Date:** _________________
**Test result:** ✅ PASS / ❌ FAIL
**Notes:**

---

For detailed technical information, see `ENEMY_SYSTEM_COMPLETE.md`
For quick start guide, see `QUICK_START.md`
