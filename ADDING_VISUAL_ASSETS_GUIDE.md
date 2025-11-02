# 🎨 ADDING VISUAL ASSETS TO THE GAME - STEP BY STEP

This guide will help you make all the organized Kenney assets **VISIBLE** in your game!

---

## 🎯 WHAT YOU'LL SEE AFTER FOLLOWING THIS GUIDE:

- 🍎 Fruit collectibles (apples, oranges, bananas)
- 📦 Breakable crates
- 🌴 Jungle environment (trees, rocks, flowers)
- 🚩 Checkpoints
- ✨ Much better atmosphere!

---

## 📦 STEP 1: CREATE FRUIT COLLECTIBLE SCENES

### **A. Create Apple Collectible**

1. **In Godot:** Right-click `objects/collectibles/` → New Scene
2. **Root Node:** Area3D (name it "FruitApple")
3. **Add Children:**
   ```
   FruitApple (Area3D)
   ├─ MeshInstance3D
   │  └─ Set Mesh: Load models/collectibles/fruits/apple.glb
   ├─ CollisionShape3D
   │  └─ Shape: SphereShape3D (radius: 0.5)
   └─ GPUParticles3D (optional)
      └─ Amount: 10
      └─ Lifetime: 1.0
   ```

4. **Attach Script:** `scripts/fruit.gd`

5. **In Inspector (FruitApple):**
   - Connect signal `body_entered` to itself → `_on_body_entered()`

6. **Save Scene:** `objects/collectibles/fruit_apple.tscn`

### **B. Repeat for Other Fruits:**
- `fruit_orange.tscn` → uses `orange.glb`
- `fruit_banana.tscn` → uses `banana.glb`
- `fruit_cherry.tscn` → uses `cherry.glb`

**Quick Tip:** Duplicate `fruit_apple.tscn` and just change the mesh!

---

## 📦 STEP 2: CREATE BREAKABLE CRATE SCENES

### **A. Create Wooden Crate**

1. **In Godot:** Right-click `objects/obstacles/` → New Scene
2. **Root Node:** StaticBody3D (name it "Crate")
3. **Add Children:**
   ```
   Crate (StaticBody3D)
   ├─ MeshInstance3D
   │  └─ Set Mesh: Load models/obstacles/crate.glb
   └─ CollisionShape3D
      └─ Shape: BoxShape3D (size: 1x1x1)
   ```

4. **Attach Script:** `scripts/crate.gd`

5. **In Inspector (Crate):**
   - `Contains Fruit`: Check ✓
   - `Fruit Count`: 3
   - `Points`: 25

6. **Save Scene:** `objects/obstacles/crate.tscn`

### **B. Metal Crate Variant:**
- Duplicate `crate.tscn` → `crate_metal.tscn`
- Change mesh to `models/obstacles/crate_metal.glb`
- Set `Health`: 2 (takes 2 hits)

---

## 🌴 STEP 3: ADD JUNGLE ENVIRONMENT TO MAIN SCENE

### **Open:** `scenes/main.tscn`

### **Add Decorations:**

1. **Right-click root node** → Add Child Node → Node3D (name: "Environment")

2. **Add Trees:**
   - Add Node3D as child of Environment (name: "Trees")
   - Add MeshInstance3D children:
     ```
     Trees/
     ├─ Tree1 (MeshInstance3D)
     │  └─ Mesh: models/environment/jungle/tree_palm.glb
     │  └─ Position: (-5, 0, -5)
     ├─ Tree2
     │  └─ Mesh: models/environment/jungle/tree_oak.glb
     │  └─ Position: (8, 0, -8)
     └─ Tree3
        └─ Mesh: models/environment/jungle/tree_default.glb
        └─ Position: (-3, 0, 10)
     ```

3. **Add Rocks:**
   - Add Node3D as child of Environment (name: "Rocks")
   - Add MeshInstance3D children:
     ```
     Rocks/
     ├─ Rock1 → models/environment/jungle/rock_largeA.glb
     ├─ Rock2 → models/environment/jungle/rock_largeB.glb
     └─ Rock3 → models/environment/jungle/rock_smallA.glb
     ```
   - Scatter them around the level naturally

4. **Add Flowers & Plants:**
   - Add Node3D (name: "Flora")
   - Add flowers: `flower_redA.glb`, `flower_yellowB.glb`, etc.
   - Add grass patches: `grass.glb`, `grass_large.glb`
   - Add mushrooms: `mushroom_red.glb`

5. **Add Bushes:**
   - Use `plant_bush.glb` for ground cover

---

## 🍎 STEP 4: REPLACE COINS WITH FRUITS

### **In main.tscn:**

1. **Find existing coin objects**
2. **Delete them** (or hide them)
3. **Add fruit objects instead:**
   - Drag `objects/collectibles/fruit_apple.tscn` into scene
   - Place fruits where coins were
   - **Position fruits throughout the level**
   - Mix different fruit types for variety!

**Pro Tip:** Place 15-20 fruits for testing (so you can test the 100-fruit extra life mechanic without collecting 100!)

---

## 📦 STEP 5: ADD BREAKABLE CRATES

### **In main.tscn:**

1. **Drag `objects/obstacles/crate.tscn`** into scene
2. **Place crates strategically:**
   - On platforms
   - Blocking paths
   - In clusters (3-4 crates together)
   - Some with fruits inside

3. **Test spin attack:**
   - Run game (F5)
   - Approach crate
   - Press **Shift** or **X**
   - Watch it explode! 💥

---

## 🎨 STEP 6: ENHANCE VISUAL ATMOSPHERE

### **A. Adjust Lighting:**
1. Select `DirectionalLight3D` in scene
2. **Color:** Slight warm orange (#FFE4B5) for jungle sunlight
3. **Energy:** 1.2 (brighter)
4. **Shadows:** Enabled

### **B. Add Ambient Light:**
1. Select `WorldEnvironment`
2. **Environment > Ambient Light:**
   - Mode: Sky
   - Sky Contribution: 0.3
   - Color: Slight green tint (#E8F5E9)

### **C. Add Fog (Optional):**
1. **Environment > Volumetric Fog:**
   - Enable: ✓
   - Density: 0.01
   - Sky Affect: 0.5
   - Creates depth and jungle atmosphere!

---

## 🚀 STEP 7: TEST YOUR ENHANCED GAME!

### **Press F5 and you should now see:**

- ✅ **Fruits** replacing coins
- ✅ **Breakable crates** you can spin-attack
- ✅ **Trees, rocks, flowers** decorating the level
- ✅ **Jungle atmosphere** with lighting
- ✅ **HUD showing fruit counter** (🍎 0/100)

### **Test Checklist:**
- [ ] Walk around - see trees and rocks
- [ ] Collect fruit - hear sound, see HUD update
- [ ] Spin attack crate - watch it explode
- [ ] Collect 100 fruits - gain extra life!
- [ ] Check HUD - lives, fruits, timer, score all work

---

## 🎯 QUICK WIN: MINIMAL VISIBLE CHANGES

**If you're short on time, do THIS minimum:**

1. ✅ **Replace 10 coins with fruits** (mix of apple/orange/banana)
2. ✅ **Add 5 crates** to break
3. ✅ **Add 3 palm trees** for jungle feel
4. ✅ **Add 2-3 large rocks**
5. ✅ **Test spin attack on crates**

**Time: ~10 minutes**
**Result: Visible, playable improvements!**

---

## 🔧 TROUBLESHOOTING

### **"I don't see the fruit models!"**
- Check `models/collectibles/fruits/` has `.glb` files
- In Godot, FileSystem tab, click refresh (F5)
- Reimport assets if needed

### **"Fruits don't collect!"**
- Make sure fruit scene has `Area3D` as root
- Check `body_entered` signal is connected
- Ensure `scripts/fruit.gd` is attached

### **"Crates don't break!"**
- Verify `scripts/crate.gd` is attached
- Check crate has `StaticBody3D` as root
- Make sure player has spin attack (Shift/X)

### **"Game looks the same!"**
- You need to **add objects to the scene manually**
- Just organizing assets doesn't make them appear
- Follow Step 3-5 above to place them!

---

## 📊 EXPECTED RESULT

### **BEFORE (What You See Now):**
- Basic platforms
- Simple coins
- No environment
- Bland atmosphere

### **AFTER (What You'll See):**
- 🍎 Fruit collectibles (apples, oranges, bananas)
- 📦 Breakable crates (with explosion effects!)
- 🌴 Jungle environment (trees, rocks, flowers)
- ✨ Rich, vibrant atmosphere
- 🎮 Working spin attack on crates
- 💯 100-fruit extra life mechanic

---

## 🎉 NEXT STEPS AFTER THIS:

Once you have visible content, we can add:
- 🚩 Checkpoints (using `checkpoint.glb`)
- 👾 Enemies with patrol AI
- 🎯 Spike hazards
- 🏁 Level goal/finish line
- 🎨 More polish and effects

---

**Let me know when you've added the visual assets and I'll continue building more features!**

Or if you need help with any specific step, just ask! 🚀
