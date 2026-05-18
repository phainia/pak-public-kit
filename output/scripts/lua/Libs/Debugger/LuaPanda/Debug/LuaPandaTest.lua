local LuaPandaTest = {}
local DebugHelper = require("Libs.Debugger.LuaPanda.Debug.DebugHelper")

function LuaPandaTest.TestLog()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 1: \229\159\186\230\156\172\230\151\165\229\191\151\229\138\159\232\131\189")
  print(string.rep("=", 60))
  DebugHelper.LogInfo("\232\191\153\230\152\175\228\184\128\230\157\161\228\191\161\230\129\175\230\151\165\229\191\151")
  DebugHelper.LogWarning("\232\191\153\230\152\175\228\184\128\230\157\161\232\173\166\229\145\138\230\151\165\229\191\151")
  DebugHelper.LogError("\232\191\153\230\152\175\228\184\128\230\157\161\233\148\153\232\175\175\230\151\165\229\191\151")
  DebugHelper.LogDebug("\232\191\153\230\152\175\228\184\128\230\157\161\232\176\131\232\175\149\230\151\165\229\191\151")
  DebugHelper.Log("\229\164\154\229\143\130\230\149\176\230\181\139\232\175\149:", 123, true, nil, "end")
  print("\226\156\147 \230\151\165\229\191\151\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestTable()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 2: \232\161\168\230\160\188\230\137\147\229\141\176")
  print(string.rep("=", 60))
  local simple_table = {
    name = "\230\181\139\232\175\149\231\142\169\229\174\182",
    level = 50,
    gold = 10000,
    vip = true
  }
  DebugHelper.PrintTable(simple_table, "\231\174\128\229\141\149\232\161\168\230\160\188")
  local array = {
    10,
    20,
    30,
    40,
    50
  }
  DebugHelper.PrintTable(array, "\230\149\176\231\187\132")
  local nested_table = {
    player = {
      name = "Robin",
      level = 60,
      inventory = {
        weapon = "\231\165\158\229\137\145",
        armor = "\231\155\148\231\148\178",
        items = {
          1001,
          1002,
          1003
        }
      }
    },
    config = {sound = 0.8, music = 0.6}
  }
  DebugHelper.PrintTable(nested_table, "\229\181\140\229\165\151\232\161\168\230\160\188")
  DebugHelper.PrintTableSimple(simple_table, "\231\174\128\229\141\149\230\137\147\229\141\176")
  print("\226\156\147 \232\161\168\230\160\188\230\137\147\229\141\176\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestCallStack()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 3: \232\176\131\231\148\168\229\160\134\230\160\136")
  print(string.rep("=", 60))
  
  local function level3()
    DebugHelper.PrintCallStack()
  end
  
  local function level2()
    level3()
  end
  
  local function level1()
    level2()
  end
  
  level1()
  local stack_str = DebugHelper.GetCallStackString(5)
  DebugHelper.Log("\229\160\134\230\160\136\229\173\151\231\172\166\228\184\178:", stack_str)
  print("\226\156\147 \232\176\131\231\148\168\229\160\134\230\160\136\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestPerformance()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 4: \230\128\167\232\131\189\230\181\139\233\135\143")
  print(string.rep("=", 60))
  DebugHelper.MeasureTime(function()
    local sum = 0
    for i = 1, 10000 do
      sum = sum + i
    end
    return sum
  end, "\230\177\130\229\146\140\232\191\144\231\174\151")
  DebugHelper.StartTimer("\229\164\141\230\157\130\232\174\161\231\174\151")
  local result = 0
  for i = 1, 50000 do
    result = result + math.sqrt(i)
  end
  DebugHelper.StopTimer("\229\164\141\230\157\130\232\174\161\231\174\151")
  print("\226\156\147 \230\128\167\232\131\189\230\181\139\233\135\143\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestWatch()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 5: \229\143\152\233\135\143\231\155\145\230\142\167")
  print(string.rep("=", 60))
  local player_health = 100
  local player_mana = 50
  DebugHelper.Watch("\231\142\169\229\174\182\231\148\159\229\145\189", function()
    return player_health
  end)
  DebugHelper.Watch("\231\142\169\229\174\182\230\179\149\229\138\155", function()
    return player_mana
  end)
  DebugHelper.PrintWatches()
  player_health = 80
  player_mana = 30
  DebugHelper.PrintWatches()
  DebugHelper.Unwatch("\231\142\169\229\174\182\231\148\159\229\145\189")
  DebugHelper.Unwatch("\231\142\169\229\174\182\230\179\149\229\138\155")
  print("\226\156\147 \229\143\152\233\135\143\231\155\145\230\142\167\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestMemory()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 6: \229\134\133\229\173\152\229\136\134\230\158\144")
  print(string.rep("=", 60))
  DebugHelper.PrintMemoryUsage()
  local garbage = {}
  for i = 1, 1000 do
    garbage[i] = {
      data = string.rep("x", 100)
    }
  end
  DebugHelper.PrintMemoryUsage()
  garbage = nil
  DebugHelper.ForceGC()
  print("\226\156\147 \229\134\133\229\173\152\229\136\134\230\158\144\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestAssert()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 7: \230\150\173\232\168\128\229\138\159\232\131\189")
  print(string.rep("=", 60))
  DebugHelper.Assert(true, "\232\191\153\228\184\170\230\150\173\232\168\128\229\186\148\232\175\165\233\128\154\232\191\135")
  DebugHelper.AssertEqual(10, 10, "\231\155\184\231\173\137\230\150\173\232\168\128\229\186\148\232\175\165\233\128\154\232\191\135")
  DebugHelper.AssertNotNil("not nil", "\233\157\158\231\169\186\230\150\173\232\168\128\229\186\148\232\175\165\233\128\154\232\191\135")
  print("\226\156\147 \230\137\128\230\156\137\230\150\173\232\168\128\233\131\189\233\128\154\232\191\135\228\186\134")
  print("\226\156\147 \230\150\173\232\168\128\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestUtils()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 8: \229\183\165\229\133\183\229\135\189\230\149\176")
  print(string.rep("=", 60))
  DebugHelper.CheckType(123, "\230\149\176\229\173\151\229\143\152\233\135\143")
  DebugHelper.CheckType("hello", "\229\173\151\231\172\166\228\184\178\229\143\152\233\135\143")
  DebugHelper.CheckType({a = 1, b = 2}, "\232\161\168\229\143\152\233\135\143")
  DebugHelper.CheckType(function()
  end, "\229\135\189\230\149\176\229\143\152\233\135\143")
  local table1 = {
    a = 1,
    b = 2,
    c = 3
  }
  local table2 = {
    a = 1,
    b = 5,
    d = 4
  }
  DebugHelper.CompareTables(table1, table2, "\232\161\1681", "\232\161\1682")
  print("\226\156\147 \229\183\165\229\133\183\229\135\189\230\149\176\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestConfig()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 9: \233\133\141\231\189\174\231\174\161\231\144\134")
  print(string.rep("=", 60))
  local current_log_level = DebugHelper.GetConfig("logLevel")
  DebugHelper.Log("\229\189\147\229\137\141\230\151\165\229\191\151\231\186\167\229\136\171:", current_log_level)
  DebugHelper.SetLogLevel(DebugHelper.LogLevel.WARNING)
  DebugHelper.LogDebug("\232\191\153\230\157\161\232\176\131\232\175\149\230\151\165\229\191\151\228\184\141\229\186\148\232\175\165\230\152\190\231\164\186")
  DebugHelper.LogWarning("\232\191\153\230\157\161\232\173\166\229\145\138\230\151\165\229\191\151\229\186\148\232\175\165\230\152\190\231\164\186")
  DebugHelper.SetLogLevel(DebugHelper.LogLevel.DEBUG)
  DebugHelper.LogDebug("\231\142\176\229\156\168\232\176\131\232\175\149\230\151\165\229\191\151\229\143\136\229\143\175\228\187\165\230\152\190\231\164\186\228\186\134")
  DebugHelper.Disable()
  DebugHelper.Log("\232\191\153\230\157\161\230\151\165\229\191\151\228\184\141\229\186\148\232\175\165\230\152\190\231\164\186")
  DebugHelper.Enable()
  DebugHelper.Log("\232\176\131\232\175\149\229\138\159\232\131\189\229\183\178\233\135\141\230\150\176\229\144\175\231\148\168")
  print("\226\156\147 \233\133\141\231\189\174\231\174\161\231\144\134\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.TestRealWorldExample()
  print("\n" .. string.rep("=", 60))
  print("\230\181\139\232\175\149 10: \229\174\158\233\153\133\228\189\191\231\148\168\229\156\186\230\153\175\231\164\186\228\190\139")
  print(string.rep("=", 60))
  
  local function simulate_battle(player, enemy)
    DebugHelper.LogInfo("\230\136\152\230\150\151\229\188\128\229\167\139!")
    DebugHelper.PrintTable(player, "\231\142\169\229\174\182\228\191\161\230\129\175")
    DebugHelper.PrintTable(enemy, "\230\149\140\228\186\186\228\191\161\230\129\175")
    DebugHelper.Watch("\231\142\169\229\174\182HP", function()
      return player.hp
    end)
    DebugHelper.Watch("\230\149\140\228\186\186HP", function()
      return enemy.hp
    end)
    local round = 1
    while player.hp > 0 and enemy.hp > 0 do
      DebugHelper.LogInfo(string.format("--- \231\172\172 %d \229\155\158\229\144\136 ---", round))
      local damage = math.random(player.attack_min, player.attack_max)
      enemy.hp = enemy.hp - damage
      DebugHelper.LogInfo(string.format("\231\142\169\229\174\182\233\128\160\230\136\144 %d \231\130\185\228\188\164\229\174\179", damage))
      if enemy.hp <= 0 then
        DebugHelper.LogInfo("\230\149\140\228\186\186\232\162\171\229\135\187\232\180\165!")
        break
      end
      damage = math.random(enemy.attack_min, enemy.attack_max)
      player.hp = player.hp - damage
      DebugHelper.LogWarning(string.format("\230\149\140\228\186\186\233\128\160\230\136\144 %d \231\130\185\228\188\164\229\174\179", damage))
      if player.hp <= 0 then
        DebugHelper.LogError("\231\142\169\229\174\182\230\136\152\232\180\165!")
        break
      end
      DebugHelper.PrintWatches()
      round = round + 1
      if round > 10 then
        DebugHelper.LogWarning("\230\136\152\230\150\151\232\182\133\232\191\13510\229\155\158\229\144\136\239\188\140\229\188\186\229\136\182\231\187\147\230\157\159")
        break
      end
    end
    DebugHelper.Unwatch("\231\142\169\229\174\182HP")
    DebugHelper.Unwatch("\230\149\140\228\186\186HP")
    DebugHelper.LogInfo("\230\136\152\230\150\151\231\187\147\230\157\159!")
  end
  
  local player = {
    name = "\229\139\135\232\128\133",
    hp = 100,
    attack_min = 15,
    attack_max = 25
  }
  local enemy = {
    name = "\229\147\165\229\184\131\230\158\151",
    hp = 80,
    attack_min = 10,
    attack_max = 20
  }
  DebugHelper.MeasureTime(function()
    simulate_battle(player, enemy)
  end, "\230\136\152\230\150\151\231\179\187\231\187\159")
  print("\226\156\147 \229\174\158\233\153\133\229\156\186\230\153\175\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

function LuaPandaTest.RunAll()
  print("\n")
  print(string.rep("=", 60))
  print("       LuaPanda DebugHelper \229\174\140\230\149\180\230\181\139\232\175\149\229\165\151\228\187\182")
  print(string.rep("=", 60))
  print("\n")
  local tests = {
    {
      name = "\229\159\186\230\156\172\230\151\165\229\191\151",
      func = LuaPandaTest.TestLog
    },
    {
      name = "\232\161\168\230\160\188\230\137\147\229\141\176",
      func = LuaPandaTest.TestTable
    },
    {
      name = "\232\176\131\231\148\168\229\160\134\230\160\136",
      func = LuaPandaTest.TestCallStack
    },
    {
      name = "\230\128\167\232\131\189\230\181\139\233\135\143",
      func = LuaPandaTest.TestPerformance
    },
    {
      name = "\229\143\152\233\135\143\231\155\145\230\142\167",
      func = LuaPandaTest.TestWatch
    },
    {
      name = "\229\134\133\229\173\152\229\136\134\230\158\144",
      func = LuaPandaTest.TestMemory
    },
    {
      name = "\230\150\173\232\168\128\229\138\159\232\131\189",
      func = LuaPandaTest.TestAssert
    },
    {
      name = "\229\183\165\229\133\183\229\135\189\230\149\176",
      func = LuaPandaTest.TestUtils
    },
    {
      name = "\233\133\141\231\189\174\231\174\161\231\144\134",
      func = LuaPandaTest.TestConfig
    },
    {
      name = "\229\174\158\233\153\133\229\156\186\230\153\175",
      func = LuaPandaTest.TestRealWorldExample
    }
  }
  local passed = 0
  local failed = 0
  for i, test in ipairs(tests) do
    local ok, err = pcall(test.func)
    if ok then
      passed = passed + 1
    else
      failed = failed + 1
      print(string.format("\226\156\151 \230\181\139\232\175\149 '%s' \229\164\177\232\180\165: %s", test.name, tostring(err)))
    end
  end
  print("\n" .. string.rep("=", 60))
  print(string.format("\230\181\139\232\175\149\229\174\140\230\136\144: %d \233\128\154\232\191\135, %d \229\164\177\232\180\165", passed, failed))
  print(string.rep("=", 60) .. "\n")
  if 0 == failed then
    print("\240\159\142\137 \230\137\128\230\156\137\230\181\139\232\175\149\233\128\154\232\191\135!")
  end
end

function LuaPandaTest.RunQuick()
  print("\n\229\191\171\233\128\159\230\181\139\232\175\149\230\168\161\229\188\143\n")
  LuaPandaTest.TestLog()
  LuaPandaTest.TestTable()
  LuaPandaTest.TestPerformance()
  print("\226\156\147 \229\191\171\233\128\159\230\181\139\232\175\149\229\174\140\230\136\144\n")
end

return LuaPandaTest
