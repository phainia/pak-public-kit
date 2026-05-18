local DebugHelper = require("Libs.Debugger.LuaPanda.Debug.DebugHelper")
print("\n" .. string.rep("=", 70))
print("               DebugHelper \229\191\171\233\128\159\229\133\165\233\151\168\231\164\186\228\190\139")
print(string.rep("=", 70) .. "\n")
print("\227\128\144\231\164\186\228\190\139 1\227\128\145\229\159\186\230\156\172\230\151\165\229\191\151\232\190\147\229\135\186")
print(string.rep("-", 70))
DebugHelper.LogInfo("\232\191\153\230\152\175\228\184\128\230\157\161\230\153\174\233\128\154\228\191\161\230\129\175")
DebugHelper.LogWarning("\232\191\153\230\152\175\228\184\128\230\157\161\232\173\166\229\145\138\228\191\161\230\129\175")
DebugHelper.LogError("\232\191\153\230\152\175\228\184\128\230\157\161\233\148\153\232\175\175\228\191\161\230\129\175")
DebugHelper.Log("\231\142\169\229\174\182\228\191\161\230\129\175:", "Robin", "\231\173\137\231\186\167:", 50, "\233\135\145\229\184\129:", 10000)
print("")
print("\227\128\144\231\164\186\228\190\139 2\227\128\145\230\137\147\229\141\176\229\164\141\230\157\130\230\149\176\230\141\174\231\187\147\230\158\132")
print(string.rep("-", 70))
local player_data = {
  id = 10001,
  name = "Robin",
  level = 60,
  vip = true,
  gold = 999999,
  stats = {
    hp = 1000,
    mp = 500,
    attack = 150,
    defense = 80
  },
  inventory = {
    weapons = {
      "\231\165\158\229\137\145",
      "\233\173\148\230\157\150",
      "\229\188\147\231\174\173"
    },
    armors = {
      "\229\164\180\231\155\148",
      "\232\131\184\231\148\178",
      "\230\138\164\232\133\191"
    },
    items = {
      {
        id = 1001,
        name = "\231\148\159\229\145\189\232\141\175\230\176\180",
        count = 99
      },
      {
        id = 1002,
        name = "\230\179\149\229\138\155\232\141\175\230\176\180",
        count = 50
      }
    }
  }
}
DebugHelper.PrintTable(player_data, "\231\142\169\229\174\182\229\174\140\230\149\180\230\149\176\230\141\174")
DebugHelper.PrintTable(player_data.stats, "\231\142\169\229\174\182\229\177\158\230\128\167")
DebugHelper.PrintTable(player_data.inventory.weapons, "\230\173\166\229\153\168\229\136\151\232\161\168")
print("")
print("\227\128\144\231\164\186\228\190\139 3\227\128\145\230\128\167\232\131\189\230\181\139\233\135\143")
print(string.rep("-", 70))
local fibonacci = function(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end
DebugHelper.MeasureTime(function()
  local result = fibonacci(20)
  print("fibonacci(20) =", result)
end, "\230\150\144\230\179\162\233\130\163\229\165\145\230\149\176\229\136\151\232\174\161\231\174\151")
DebugHelper.StartTimer("\230\149\176\230\141\174\229\164\132\231\144\134")
local sum = 0
for i = 1, 100000 do
  sum = sum + math.sqrt(i)
end
local elapsed = DebugHelper.StopTimer("\230\149\176\230\141\174\229\164\132\231\144\134")
print(string.format("\232\174\161\231\174\151\231\187\147\230\158\156: %.2f, \232\128\151\230\151\182: %.3f ms", sum, elapsed))
print("")
print("\227\128\144\231\164\186\228\190\139 4\227\128\145\229\143\152\233\135\143\231\155\145\230\142\167")
print(string.rep("-", 70))
local player_hp = 100
local enemy_hp = 80
DebugHelper.Watch("\231\142\169\229\174\182HP", function()
  return player_hp
end)
DebugHelper.Watch("\230\149\140\228\186\186HP", function()
  return enemy_hp
end)
print("\229\136\157\229\167\139\231\138\182\230\128\129:")
DebugHelper.PrintWatches()
print("\n\230\136\152\230\150\151\229\155\158\229\144\136 1:")
player_hp = player_hp - 15
enemy_hp = enemy_hp - 20
DebugHelper.PrintWatches()
print("\n\230\136\152\230\150\151\229\155\158\229\144\136 2:")
player_hp = player_hp - 10
enemy_hp = enemy_hp - 25
DebugHelper.PrintWatches()
DebugHelper.Unwatch("\231\142\169\229\174\182HP")
DebugHelper.Unwatch("\230\149\140\228\186\186HP")
print("")
print("\227\128\144\231\164\186\228\190\139 5\227\128\145\232\176\131\231\148\168\229\160\134\230\160\136\232\183\159\232\184\170")
print(string.rep("-", 70))

local function deep_function_level3()
  DebugHelper.PrintCallStack(10)
end

local function deep_function_level2()
  deep_function_level3()
end

local function deep_function_level1()
  deep_function_level2()
end

deep_function_level1()
print("")
print("\227\128\144\231\164\186\228\190\139 6\227\128\145\231\177\187\229\158\139\230\163\128\230\159\165\229\146\140\232\161\168\230\175\148\232\190\131")
print(string.rep("-", 70))
DebugHelper.CheckType(123, "\230\149\180\230\149\176")
DebugHelper.CheckType("Hello", "\229\173\151\231\172\166\228\184\178")
DebugHelper.CheckType({a = 1, b = 2}, "\232\161\168")
local config_old = {
  sound = 0.8,
  music = 0.6,
  quality = "high"
}
local config_new = {
  sound = 0.8,
  music = 0.9,
  graphics = "ultra"
}
DebugHelper.CompareTables(config_old, config_new, "\230\151\167\233\133\141\231\189\174", "\230\150\176\233\133\141\231\189\174")
print("")
print("\227\128\144\231\164\186\228\190\139 7\227\128\145\230\150\173\232\168\128\230\163\128\230\159\165")
print(string.rep("-", 70))

local function divide(a, b)
  DebugHelper.AssertNotNil(a, "\232\162\171\233\153\164\230\149\176\228\184\141\232\131\189\228\184\186nil")
  DebugHelper.AssertNotNil(b, "\233\153\164\230\149\176\228\184\141\232\131\189\228\184\186nil")
  DebugHelper.Assert(0 ~= b, "\233\153\164\230\149\176\228\184\141\232\131\189\228\184\1860")
  return a / b
end

local result = divide(10, 2)
DebugHelper.Log("10 / 2 =", result)
print("")
print("\227\128\144\231\164\186\228\190\139 8\227\128\145\229\134\133\229\173\152\231\155\145\230\142\167")
print(string.rep("-", 70))
DebugHelper.PrintMemoryUsage()
local big_data = {}
for i = 1, 10000 do
  big_data[i] = {
    id = i,
    data = string.rep("x", 100)
  }
end
DebugHelper.PrintMemoryUsage()
big_data = nil
DebugHelper.ForceGC()
print("")
print("\227\128\144\231\164\186\228\190\139 9\227\128\145\233\133\141\231\189\174\232\176\131\230\149\180")
print(string.rep("-", 70))
local current_level = DebugHelper.GetConfig("logLevel")
print("\229\189\147\229\137\141\230\151\165\229\191\151\231\186\167\229\136\171:", current_level)
DebugHelper.SetLogLevel(DebugHelper.LogLevel.WARNING)
DebugHelper.LogDebug("\232\191\153\230\157\161\228\184\141\228\188\154\230\152\190\231\164\186")
DebugHelper.LogInfo("\232\191\153\230\157\161\228\185\159\228\184\141\228\188\154\230\152\190\231\164\186")
DebugHelper.LogWarning("\232\191\153\230\157\161\228\188\154\230\152\190\231\164\186")
DebugHelper.LogError("\232\191\153\230\157\161\228\185\159\228\188\154\230\152\190\231\164\186")
DebugHelper.SetLogLevel(DebugHelper.LogLevel.DEBUG)
DebugHelper.SetConfig("maxTableDepth", 10)
print("")
print("\227\128\144\231\164\186\228\190\139 10\227\128\145\231\187\188\229\144\136\229\186\148\231\148\168 - \230\168\161\230\139\159\230\138\128\232\131\189\231\179\187\231\187\159")
print(string.rep("-", 70))

local function cast_skill(caster, target, skill)
  DebugHelper.LogInfo("========== \230\138\128\232\131\189\233\135\138\230\148\190 ==========")
  DebugHelper.PrintTable(skill, "\230\138\128\232\131\189\228\191\161\230\129\175")
  DebugHelper.AssertNotNil(caster, "\233\135\138\230\148\190\232\128\133\228\184\141\232\131\189\228\184\186\231\169\186")
  DebugHelper.AssertNotNil(target, "\231\155\174\230\160\135\228\184\141\232\131\189\228\184\186\231\169\186")
  DebugHelper.AssertNotNil(skill, "\230\138\128\232\131\189\228\184\141\232\131\189\228\184\186\231\169\186")
  if caster.mp < skill.cost then
    DebugHelper.LogError("\230\179\149\229\138\155\229\128\188\228\184\141\232\182\179!")
    return false
  end
  caster.mp = caster.mp - skill.cost
  DebugHelper.LogInfo(string.format("\230\182\136\232\128\151\230\179\149\229\138\155: %d, \229\137\169\228\189\153: %d", skill.cost, caster.mp))
  local damage = DebugHelper.MeasureTime(function()
    local base_damage = skill.damage
    local critical = math.random() > 0.7
    if critical then
      DebugHelper.LogWarning("\230\154\180\229\135\187!")
      base_damage = base_damage * 2
    end
    return base_damage
  end, "\228\188\164\229\174\179\232\174\161\231\174\151")
  target.hp = math.max(0, target.hp - damage)
  DebugHelper.LogInfo(string.format("\233\128\160\230\136\144 %d \231\130\185\228\188\164\229\174\179, \231\155\174\230\160\135\229\137\169\228\189\153\231\148\159\229\145\189: %d", damage, target.hp))
  if target.hp <= 0 then
    DebugHelper.LogWarning("\231\155\174\230\160\135\229\183\178\232\162\171\229\135\187\232\180\165!")
  end
  return true
end

local mage = {
  name = "\230\179\149\229\184\136",
  hp = 500,
  mp = 200
}
local monster = {name = "\229\183\168\233\190\153", hp = 1000}
local fireball = {
  name = "\231\129\171\231\144\131\230\156\175",
  damage = 150,
  cost = 50
}
cast_skill(mage, monster, fireball)
print("")
print(string.rep("=", 70))
print("\240\159\142\137 \229\191\171\233\128\159\229\133\165\233\151\168\231\164\186\228\190\139\229\174\140\230\136\144!")
print("")
print("\229\184\184\231\148\168\229\138\159\232\131\189\230\128\187\231\187\147:")
print("  1. DebugHelper.Log(...)           - \232\190\147\229\135\186\230\151\165\229\191\151")
print("  2. DebugHelper.PrintTable(t)      - \230\137\147\229\141\176\232\161\168\230\160\188")
print("  3. DebugHelper.MeasureTime(fn)    - \230\181\139\233\135\143\230\128\167\232\131\189")
print("  4. DebugHelper.Watch(name, fn)    - \231\155\145\230\142\167\229\143\152\233\135\143")
print("  5. DebugHelper.PrintCallStack()   - \230\137\147\229\141\176\229\160\134\230\160\136")
print("  6. DebugHelper.Assert(cond, msg)  - \230\150\173\232\168\128\230\163\128\230\159\165")
print("  7. DebugHelper.PrintMemoryUsage() - \229\134\133\229\173\152\231\155\145\230\142\167")
print("")
print("\230\155\180\229\164\154\231\164\186\228\190\139\232\175\183\230\159\165\231\156\139:")
print("  - LuaPandaTest.lua (\229\174\140\230\149\180\230\181\139\232\175\149\229\165\151\228\187\182)")
print("  - \228\189\191\231\148\168\230\140\135\229\141\151.md (\232\175\166\231\187\134\230\150\135\230\161\163)")
print(string.rep("=", 70) .. "\n")
return true
