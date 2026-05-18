local DebugModuleData = _G.NRCData:Extend("DebugModuleData")

function DebugModuleData:Ctor()
  NRCData.Ctor(self)
  self.ShortcutKeyList = {}
  self:SetShortcutKeyList()
  self.Instruction = {}
  self.UseType = {}
  self.Order = {}
  self.GMItemDataList = {}
  self:LoadDataFromExcel()
  self.TabDataCache = {}
  self.DungeonTypes = {
    "A1",
    "A2",
    "B1"
  }
end

function DebugModuleData:SetShortcutKeyList()
  self:AddShortcutKeyList("\233\154\143\230\156\186\231\178\190\231\129\181PvP", "left ctrl", "w")
  self:AddShortcutKeyList("\232\191\155\233\153\132\232\191\145\230\136\152\230\150\151", "Right ctrl", "q")
  self:AddShortcutKeyList("\229\188\186\229\136\182\231\166\187\229\188\128\230\136\152\230\150\151", "1", "e")
  self:AddShortcutKeyList("PVP\229\140\185\233\133\141", "Num 1", "2")
end

function DebugModuleData:AddShortcutKeyList(ShortcutKeyName, ...)
  table.insert(self.ShortcutKeyList, {
    {ShortcutKeyName},
    {
      ...
    }
  })
end

function DebugModuleData:GetShortcutKey()
  return self.ShortcutKeyList
end

function DebugModuleData:GetInstruction()
  local Instruction = {
    [1] = {
      name = "\229\133\168\233\131\168",
      NewInstruction = "\232\129\140\232\131\189\229\143\130\230\149\176"
    },
    [2] = {
      name = "\231\168\139\229\186\143",
      NewInstruction = "\232\129\140\232\131\189\229\143\130\230\149\176"
    },
    [3] = {
      name = "\231\173\150\229\136\146",
      NewInstruction = "\232\129\140\232\131\189\229\143\130\230\149\176"
    },
    [4] = {
      name = "\230\181\139\232\175\149",
      NewInstruction = "\232\129\140\232\131\189\229\143\130\230\149\176"
    },
    [5] = {
      name = "\231\190\142\230\156\175",
      NewInstruction = "\232\129\140\232\131\189\229\143\130\230\149\176"
    }
  }
  table.insert(self.Instruction, Instruction)
  return self.Instruction
end

function DebugModuleData:GetUseType()
  local UseType = {
    [1] = {
      name = "\229\133\168\233\131\168",
      NewInstruction = "\228\189\191\231\148\168\229\143\130\230\149\176"
    },
    [2] = {
      name = "\228\184\180\230\151\182",
      NewInstruction = "\228\189\191\231\148\168\229\143\130\230\149\176"
    },
    [3] = {
      name = "\229\133\172\231\148\168",
      NewInstruction = "\228\189\191\231\148\168\229\143\130\230\149\176"
    }
  }
  table.insert(self.UseType, UseType)
  return self.UseType
end

function DebugModuleData:GetOrder()
  local Order = {
    [1] = {
      name = "\229\133\168\233\131\168",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [2] = {
      name = "\228\184\170\228\186\186\229\177\158\230\128\167",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [3] = {
      name = "\232\142\183\229\190\151\231\137\169\229\147\129",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [4] = {
      name = "\232\142\183\229\143\150\230\138\128\232\131\189",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [5] = {
      name = "\232\142\183\229\190\151\231\178\190\231\129\181",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [6] = {
      name = "\231\178\190\231\129\181\229\177\158\230\128\167",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [7] = {
      name = "\229\156\176\229\155\190\228\188\160\233\128\129",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [8] = {
      name = "\228\187\187\229\138\161",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [9] = {
      name = "\229\142\134\229\143\178",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    },
    [10] = {
      name = "\232\180\166\229\143\183\231\138\182\230\128\129",
      NewInstruction = "\230\179\155\231\148\168\230\140\135\228\187\164"
    }
  }
  table.insert(self.Order, Order)
  return self.Order
end

function DebugModuleData:GetSecondUIType()
  local UIType = {
    [1] = {
      Typename = "Email",
      Index = {1, 2},
      Cmd = _G.EmailModuleCmd.OpenMainPanel
    },
    [2] = {
      Typename = "AlchemicalCreations",
      Cmd = _G.AlchemyModuleCmd.OpenAlchemyPanel
    },
    [3] = {
      Typename = "ArdourUpPanel",
      Cmd = _G.AlchemyModuleCmd.OpenArdourPanel
    },
    [4] = {
      Typename = "RecoverTimeUpPanel",
      Cmd = _G.AlchemyModuleCmd.OpenRecoverTimeUpPanel
    },
    [5] = {
      Typename = "RecoverUpPanel",
      Cmd = _G.AlchemyModuleCmd.OpenRecoverUpPanel
    },
    [6] = {
      Typename = "MagicNourish",
      Cmd = _G.CampingModuleCmd.OpenMagicNourishTemp
    },
    [7] = {
      Typename = "TeamConfiguration",
      Cmd = _G.PetUIModuleCmd.OpenPetTeamPanel
    },
    [8] = {
      Typename = "TaskPanel",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.TaskModuleCmd.OpenNewTaskPanel
    },
    [9] = {
      Typename = "Bag",
      Index = {
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8
      },
      Cmd = _G.BagModuleCmd.OpenBagMainPanel
    },
    [10] = {
      Typename = "Conversation",
      Cmd = _G.FriendModuleCmd.OpenChatMainPanel
    },
    [11] = {
      Typename = "PetReport",
      Cmd = _G.PetUIModuleCmd.OpenPetReportPanel
    },
    [12] = {
      Typename = "MagicManual",
      Index = {1, 2},
      Cmd = _G.MagicManualModuleCmd.OpenMagicManual
    },
    [13] = {
      Typename = "Compass",
      Cmd = _G.MainUIModuleCmd.OpenPanelLobbyMainInner
    },
    [14] = {
      Typename = "BattlePass",
      Index = {1, 2},
      Cmd = _G.BattlePassModuleCmd.OpenBattlePass
    },
    [15] = {
      Typename = "PVP",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.BattleUIModuleCmd.OpenPVPMatch
    },
    [16] = {
      Typename = "Map",
      Index = {1, 2},
      Cmd = _G.BigMapModuleCmd.OpenWorldMap
    },
    [17] = {
      Typename = "Setting",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.SystemSettingModuleCmd.OpenMainPanel
    },
    [18] = {
      Typename = "TeachingManual",
      Index = {
        1,
        2,
        3,
        4
      },
      Cmd = _G.TeachingManualModuleCmd.OpenMainPanel
    },
    [19] = {
      Typename = "NPCShop",
      Cmd = _G.NPCShopUIModuleCmd.FinishNPCActionOpenShop
    },
    [20] = {
      Typename = "AppearancePanel",
      Cmd = _G.NPCShopUIModuleCmd.FinishNPCActionOpenShop
    },
    [21] = {
      Typename = "TravelMap",
      Cmd = _G.TravelModuleCmd.OpenTravelMainMapPanel
    },
    [22] = {
      Typename = "PetWarehouse",
      Cmd = _G.PetUIModuleCmd.OpenPetwarehousePanel
    },
    [23] = {
      Typename = "PvPPetTeam",
      Cmd = _G.PetUIModuleCmd.OpenPvPPetTeamPanel
    },
    [24] = {
      Typename = "FriendPanel",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.FriendModuleCmd.OpenMainPanel
    },
    [25] = {
      Typename = "HandBookCover",
      Cmd = _G.HandbookModuleCmd.OpenHandbookCover
    },
    [26] = {
      Typename = "HandBook",
      Index = {1, 2},
      Cmd = _G.HandbookModuleCmd.OpenHandbookPanel
    },
    [27] = {
      Typename = "Shop",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.ShopModuleCmd.OpenMainPanel
    },
    [28] = {
      Typename = "LevelUpUI",
      Index = {
        1,
        2,
        3
      },
      Cmd = _G.LevelUpUIModuleCmd.RequestOpenLevelPanel
    },
    [29] = {
      Typename = "StudentCard",
      Index = {1, 2},
      Cmd = _G.FriendModuleCmd.OpenStudentCardPanel
    },
    [30] = {Typename = "Appearance"},
    [31] = {Typename = "Beauty"},
    [32] = {
      Typename = "PetPanel",
      Index = {
        1,
        2,
        3,
        4
      },
      Cmd = _G.PetUIModuleCmd.OpenPanelPetMain
    }
  }
  return UIType
end

function DebugModuleData:GetTableMaxIndex(table)
  local maxIndex = 1
  for i, val in pairs(table) do
    if type(i) == "number" and i > maxIndex then
      maxIndex = i
    end
  end
  return maxIndex
end

function DebugModuleData:LoadDataFromExcel()
  local GMGroupDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_GROUP_CONF):GetAllDatas()
  local GMCommandDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_COMMAND_CONF):GetAllDatas()
  local GMCommandDataMap = {}
  local maxCommandIndex = self:GetTableMaxIndex(GMCommandDataConf)
  for i = 1, maxCommandIndex do
    local CommandConf = GMCommandDataConf[i]
    if CommandConf then
      local gmgroup = CommandConf.gm_group
      gmgroup = string.lower(gmgroup)
      if not GMCommandDataMap[gmgroup] then
        GMCommandDataMap[gmgroup] = {}
      end
      table.insert(GMCommandDataMap[gmgroup], CommandConf)
    end
  end
  self.GMCommandDataMap = GMCommandDataMap
  local GMGroupDataMap = {}
  local maxGroupIndex = self:GetTableMaxIndex(GMGroupDataConf)
  for i = 1, maxGroupIndex do
    local GroupConf = GMGroupDataConf[i]
    if GroupConf then
      local tabID = GroupConf.tab_id
      if not GMGroupDataMap[tabID] then
        GMGroupDataMap[tabID] = {}
      end
      local ExecFunc, isGMCommandFlag = self:InitExecFuncFromCommandGroup(GroupConf.gm_group)
      if isGMCommandFlag then
        table.insert(GMGroupDataMap[tabID], {
          button_name = GroupConf.button_name,
          ExecFunc = ExecFunc,
          GMCommandGroupName = GroupConf.gm_group
        })
      else
        table.insert(GMGroupDataMap[tabID], {
          button_name = GroupConf.button_name,
          ExecFunc = ExecFunc
        })
      end
    end
  end
  self.GMGroupDataMap = GMGroupDataMap
  local GMMainTabDataConf, maxMainTabIndex = self:GetMainTabConf()
  self.GMMainTabName_IDMap = {}
  for i = 1, maxMainTabIndex do
    local MainTabConf = GMMainTabDataConf[i]
    if MainTabConf and MainTabConf.lua_filename then
      local FilePath, LuaClassName = string.match(MainTabConf.lua_filename, "(.-)%.([^%.]+)$")
      self.GMMainTabName_IDMap[LuaClassName] = MainTabConf.id
    end
  end
  local GMSubTabDataConf, maxSubTabIndex = self:GetSubTabConf()
  self.GMSubTabName_IDMap = {}
  for i = 1, maxSubTabIndex do
    local SubTabConf = GMSubTabDataConf[i]
    if SubTabConf and SubTabConf.lua_filename then
      local FilePath, LuaClassName = string.match(SubTabConf.lua_filename, "(.-)%.([^%.]+)$")
      self.GMSubTabName_IDMap[LuaClassName] = SubTabConf.id
    end
  end
end

function DebugModuleData:GetGMGroupDataMap()
  return self.GMGroupDataMap
end

function DebugModuleData:GetGMCommandDataMap()
  return self.GMCommandDataMap
end

function DebugModuleData:InsertGMItemData(GMItemData)
  table.insert(self.GMItemDataList, GMItemData)
end

function DebugModuleData:RemoveGMItemData(GMItemData)
  for i = #self.GMItemDataList, 1, -1 do
    if self.GMItemDataList[i] == GMItemData then
      table.remove(self.GMItemDataList, i)
      break
    end
  end
end

function DebugModuleData:GetGMItemData()
  return self.GMItemDataList
end

function DebugModuleData:ClearGMItemData()
  self.hasBuildGMItemData = nil
  self.GMItemDataList = {}
end

function DebugModuleData:SetGMItemDataFinishFlag()
  self.hasBuildGMItemData = true
end

function DebugModuleData:InitExecFuncFromCommandGroup(CommandGroup)
  local GMCommandDataMap = self.GMCommandDataMap
  local Commands = {}
  CommandGroup = string.lower(CommandGroup)
  if GMCommandDataMap[CommandGroup] then
    for i, CommandConf in ipairs(GMCommandDataMap[CommandGroup]) do
      table.insert(Commands, CommandConf.gm_command)
    end
  end
  local hasGMCommandFlag = false
  local CommandFuncTable = {}
  for i, Command in ipairs(Commands) do
    if self:CheckGMCommandIfIsPath(Command) == true then
      local FilePath, funcName = string.match(Command, "(.-)%.([^%.]+)$")
      local LuaFile = require(FilePath)
      if LuaFile then
        local CommandFunc = LuaFile[funcName]
        if CommandFunc then
          table.insert(CommandFuncTable, CommandFunc)
        else
          Log.Debug("\232\175\165\230\140\135\228\187\164\229\175\185\229\186\148\231\154\132lua\230\150\135\228\187\182\228\184\141\229\173\152\229\156\168\231\155\184\229\186\148\231\154\132\230\137\167\232\161\140\229\135\189\230\149\176")
        end
      else
        Log.Error("\230\140\135\228\187\164\233\148\153\232\175\175\239\188\140\228\184\141\229\173\152\229\156\168\232\175\165Lua\233\161\181\231\173\190\229\175\185\229\186\148\231\154\132\230\150\135\228\187\182")
      end
    else
      hasGMCommandFlag = true
      
      local function CommandFunc()
        self:ExecuteGMCommand(Command)
      end
      
      if CommandFunc then
        table.insert(CommandFuncTable, CommandFunc)
      end
    end
  end
  
  local function ExecFunc(...)
    if CommandFuncTable then
      for i, func in ipairs(CommandFuncTable) do
        func(...)
      end
    end
  end
  
  return ExecFunc, hasGMCommandFlag
end

function DebugModuleData:ExecuteGMCommand(CommandGroup)
  local ExecResult = CommandGroup
  local GMCommandDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_COMMAND_CONF):GetAllDatas()
  local commandParts = {}
  for part in string.gmatch(CommandGroup, "%S+") do
    table.insert(commandParts, part)
  end
  local gm = commandParts[1]
  if "gm" ~= gm then
    ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154gm\230\140\135\228\187\164\230\160\188\229\188\143\228\184\141\229\175\185\239\188\140\229\186\148\228\187\165gm\229\188\128\229\164\180"
    return
  end
  local gmcommand = commandParts[1] .. " " .. commandParts[2]
  local params = {}
  local GMGroupDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_GROUP_CONF):GetAllDatas()
  local maxGroupIndex = self:GetTableMaxIndex(GMGroupDataConf)
  local buttonName = ""
  for i = 1, maxGroupIndex do
    if GMGroupDataConf[i] and GMGroupDataConf[i].gm_group == gmcommand then
      buttonName = GMGroupDataConf[i].button_name
    end
  end
  table.insert(params, buttonName)
  local debugPanel = NRCModuleManager:DoCmd(DebugModuleCmd.GetGMPanel)
  if debugPanel then
    table.insert(params, debugPanel)
  end
  for i = 3, #commandParts do
    local num = tonumber(commandParts[i])
    if num then
      table.insert(params, num)
    else
      table.insert(params, commandParts[i])
    end
  end
  local Commands = {}
  local maxCommandIndex = self:GetTableMaxIndex(GMCommandDataConf)
  for i = 1, maxCommandIndex do
    local CommandConf = GMCommandDataConf[i]
    if CommandConf then
      local str1 = string.lower(CommandConf.gm_group)
      local str2 = string.lower(gmcommand)
      if str1 == str2 then
        table.insert(Commands, CommandConf.gm_command)
      end
    end
  end
  if #Commands > 0 then
    for i, Command in ipairs(Commands) do
      if self:CheckGMCommandIfIsPathAndExec(Command) ~= false then
        local FilePath, funcName = string.match(Command, "(.-)%.([^%.]+)$")
        local LuaFile = require(FilePath)
        if LuaFile then
          local CommandFunc = LuaFile[funcName]
          if CommandFunc then
            CommandFunc(LuaFile, table.unpack(params))
            ExecResult = ExecResult .. " \230\137\167\232\161\140\230\136\144\229\138\159"
          else
            ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\232\175\165\230\140\135\228\187\164\228\184\141\229\173\152\229\156\168\231\155\184\229\186\148\231\154\132\230\137\167\232\161\140\229\135\189\230\149\176"
          end
        else
          ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\230\140\135\228\187\164\233\148\153\232\175\175\239\188\140\228\184\141\229\173\152\229\156\168\232\175\165Lua\233\161\181\231\173\190\229\175\185\229\186\148\231\154\132\230\150\135\228\187\182"
        end
      else
      end
    end
  else
    ExecResult = ExecResult .. " \230\137\167\232\161\140\229\164\177\232\180\165\239\188\154\228\184\141\229\173\152\229\156\168gm\230\140\135\228\187\164\229\175\185\229\186\148\231\154\132\229\135\189\230\149\176"
  end
  return ExecResult
end

function DebugModuleData:CheckGMCommandIfIsPath(command)
  local commandParts = {}
  for part in string.gmatch(command, "%S+") do
    table.insert(commandParts, part)
  end
  if "gm" == commandParts[1] then
    return false
  else
    return true
  end
end

function DebugModuleData:CheckGMCommandIfIsPathAndExec(command)
  local commandParts = {}
  for part in string.gmatch(command, "%S+") do
    table.insert(commandParts, part)
  end
  if "gm" == commandParts[1] then
    self:ExecuteGMCommand(command)
    return false
  else
    return true
  end
end

function DebugModuleData:GetMainTabConf()
  if self.GMMainTabDataConf and self.maxMainTabIndex then
    return self.GMMainTabDataConf, self.maxMainTabIndex
  end
  self.GMMainTabDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_MAINTAB_CONF):GetAllDatas()
  self.maxMainTabIndex = self:GetTableMaxIndex(self.GMMainTabDataConf)
  return self.GMMainTabDataConf, self.maxMainTabIndex
end

function DebugModuleData:GetSubTabConf()
  if self.GMSubTabDataConf and self.maxSubTabIndex then
    return self.GMSubTabDataConf, self.maxSubTabIndex
  end
  self.GMSubTabDataConf = _G.DataConfigManager:GetTable(DataConfigManager.ConfigTableId.GM_SUBTAB_CONF):GetAllDatas()
  self.maxSubTabIndex = self:GetTableMaxIndex(self.GMSubTabDataConf)
  return self.GMSubTabDataConf, self.maxSubTabIndex
end

function DebugModuleData:GetGMMainTabName_IDMap()
  return self.GMMainTabName_IDMap
end

function DebugModuleData:GetGMSubTabName_IDMap()
  return self.GMSubTabName_IDMap
end

function DebugModuleData:GetTabDataFromCache(InPath)
  if self.TabDataCache == nil then
    self.TabDataCache = {}
  end
  if _G.GlobalConfig.bUseDebugTabCache then
    if self.TabDataCache[InPath] == nil then
      self.TabDataCache[InPath] = reload(InPath)()
    end
    return self.TabDataCache[InPath]
  else
    return reload(InPath)()
  end
end

function DebugModuleData:ClearTabDataFromCache()
  self.TabDataCache = {}
end

function DebugModuleData:TryClearTabCache()
  for key, Value in pairs(self.TabDataCache) do
    if Value.needRefresh then
      self.TabDataCache[key] = nil
    end
  end
end

return DebugModuleData
