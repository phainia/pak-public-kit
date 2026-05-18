local JsonUtils = require("Common.JsonUtils")
local DebugTabScenePublic = require("NewRoco.Modules.System.Debug.Tabs.DebugTabScenePublic")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
PSODungeonTest = {}
local L_Bigworld_01_Release = "/Game/ArtRes/Level/Game/BigWorld/L_Bigworld_01_Release/L_Bigworld_01_Release"

function PSODungeonTest:AddDefaultDungeon()
  self.DungeonsInfo = {
    Speed = {x = 2000, y = 3000},
    ["210103"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Action02/Dungeon_A1_Action02_MainRelease",
      bound_min = {
        x = -8320,
        y = 850,
        z = -8640
      },
      bound_max = {
        x = 1680,
        y = 8850,
        z = 7360
      }
    },
    ["210101"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Battle01/Dungeon_A1_Battle01_MainRelease",
      bound_min = {
        x = -12240,
        y = -4240,
        z = -10259
      },
      bound_max = {
        x = 17760,
        y = 5760,
        z = 9741
      }
    },
    ["210102"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Battle02/Dungeon_A1_Battle02_MainRelease",
      bound_min = {
        x = -10890,
        y = -1330,
        z = -5030
      },
      bound_max = {
        x = 19110,
        y = 5670,
        z = 4970
      }
    },
    ["210105"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Battle03/Dungeon_A1_Battle03_MainRelease",
      bound_min = {
        x = -7990,
        y = -12535,
        z = -10060
      },
      bound_max = {
        x = 10010,
        y = -2535,
        z = 2940
      }
    },
    ["210107"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Battle05/Dungeon_A1_Battle05_MainRelease",
      bound_min = {
        x = -2230,
        y = -2480,
        z = -3590
      },
      bound_max = {
        x = 10770,
        y = 2520,
        z = 4410
      }
    },
    ["210108"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Battle06/Dungeon_A1_Battle06_Release",
      bound_min = {
        x = -12627,
        y = -15249,
        z = -14985
      },
      bound_max = {
        x = 17373,
        y = 14751,
        z = 15015
      }
    },
    ["210115"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_FlyFlyFly/Dungeon_A1_FlyFlyFlyRelease",
      bound_min = {
        x = -25380,
        y = -12250,
        z = -26890
      },
      bound_max = {
        x = 24620,
        y = 37750,
        z = 23110
      }
    },
    ["210113"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Portal/Dungeon_A1_Portal_Release",
      bound_min = {
        x = -81641,
        y = -12767,
        z = -31540
      },
      bound_max = {
        x = 68359,
        y = 17233,
        z = 18460
      }
    },
    ["210110"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Stone01/Dungeon_A1_Stone01_Release",
      bound_min = {
        x = -3051,
        y = -2864,
        z = -2514
      },
      bound_max = {
        x = 11949,
        y = 5136,
        z = 27486
      }
    },
    ["210109"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Stone02/Dungeon_A1_Stone02_Release",
      bound_min = {
        x = -14171,
        y = 4124,
        z = -6473
      },
      bound_max = {
        x = 5829,
        y = 14124,
        z = 3527
      }
    },
    ["210112"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_SuiShiFengchang/Dungeon_A1_SuiShiFengChang_Release",
      bound_min = {
        x = -18869,
        y = -6238,
        z = -32615
      },
      bound_max = {
        x = 16131,
        y = 18762,
        z = 12385
      }
    },
    ["210104"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_TorchTreasure02/Dungeon_A1_TorchTreasure02_MainRelease",
      bound_min = {
        x = 10340,
        y = 1390,
        z = -8130
      },
      bound_max = {
        x = 22340,
        y = 9390,
        z = 9870
      }
    },
    ["210114"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_TreasureChest/Dungeon_A1_TreasureChest_Release",
      bound_min = {
        x = -7980,
        y = -1630,
        z = -7280
      },
      bound_max = {
        x = 7020,
        y = 6370,
        z = 7720
      }
    },
    ["210133"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_WarmHouse/Dungeon_A1_WarmHouse_Release",
      bound_min = {
        x = 3100,
        y = -1040,
        z = -9710
      },
      bound_max = {
        x = 28100,
        y = 8960,
        z = 10290
      }
    },
    ["210111"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A1_Waterlevel01/Dungeon_A1_Waterlevel01_Release",
      bound_min = {
        x = -11376,
        y = 3303,
        z = -8716
      },
      bound_max = {
        x = 13624,
        y = 13303,
        z = 11284
      }
    },
    ["210120"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_BattleICE/Dungeon_A2_BattleIce_Release",
      bound_min = {
        x = -4316,
        y = -3370,
        z = -8181
      },
      bound_max = {
        x = 15684,
        y = 8630,
        z = 6819
      }
    },
    ["210121"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_BattleSand/Dungeon_A2_BattleSand_Release",
      bound_min = {
        x = -8007,
        y = -2340,
        z = -5288
      },
      bound_max = {
        x = 11993,
        y = 5660,
        z = 4712
      }
    },
    ["210136"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_ElvenChest/Dungeon_A2_ElvenChest_Release",
      bound_min = {
        x = -9307,
        y = -8119,
        z = -9771
      },
      bound_max = {
        x = 10693,
        y = 11881,
        z = 10229
      }
    },
    ["210130"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_FakePortal/Dungeon_A2_FakePortal_Release",
      bound_min = {
        x = -19108,
        y = -25437,
        z = -24118
      },
      bound_max = {
        x = 30892,
        y = 24563,
        z = 115882
      }
    },
    ["210139"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_FindXiaoye/Dungeon_A2_FindXiaoye_MainRelease",
      bound_min = {
        x = -4530,
        y = -130,
        z = -7700
      },
      bound_max = {
        x = 2470,
        y = 1870,
        z = 2300
      }
    },
    ["210144"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_FollowDirec/Dungeon_A2_FollowDirec_MainRelease",
      bound_min = {
        x = -13907,
        y = -1179,
        z = -9522
      },
      bound_max = {
        x = 6093,
        y = 18821,
        z = 10478
      }
    },
    ["210142"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_HiddenInWater/Dungeon_A2_HiddenInWater_Release",
      bound_min = {
        x = -8526,
        y = -6928,
        z = -5895
      },
      bound_max = {
        x = 11474,
        y = 13072,
        z = 14105
      }
    },
    ["210123"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_MineTreasure/Dungeon_A2_MineTreasure_Release",
      bound_min = {
        x = -8632,
        y = -4013,
        z = -17780
      },
      bound_max = {
        x = 6368,
        y = 10987,
        z = -2780
      }
    },
    ["210140"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_Pipe/Dungeon_A2_Pipe_Release",
      bound_min = {
        x = -5250,
        y = -1870,
        z = -5650
      },
      bound_max = {
        x = 4750,
        y = 28130,
        z = 4350
      }
    },
    ["210148"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_RailTreasure02/Dungeon_A2_RailTreasure02_Release",
      bound_min = {
        x = -7478,
        y = -8243,
        z = -7683
      },
      bound_max = {
        x = 7522,
        y = 6757,
        z = 7317
      }
    },
    ["210149"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_RailTreasure03/Dungeon_A2_RailTreasure03_Release",
      bound_min = {
        x = -7478,
        y = -8243,
        z = -7683
      },
      bound_max = {
        x = 7522,
        y = 6757,
        z = 7317
      }
    },
    ["210137"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_RailTreasure/Dungeon_A2_RailTreasure_Release",
      bound_min = {
        x = -7478,
        y = -8243,
        z = -7683
      },
      bound_max = {
        x = 7522,
        y = 6757,
        z = 7317
      }
    },
    ["210124"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_StealBattle/Dungeon_A2_StealBattle_MainRelease",
      bound_min = {
        x = -12694,
        y = -15249,
        z = -14981
      },
      bound_max = {
        x = 17306,
        y = 14751,
        z = 15019
      }
    },
    ["210135"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_StreetHouse02/Dungeon_A2_StreetHouse02_Release",
      bound_min = {
        x = -5627,
        y = -935,
        z = -3755
      },
      bound_max = {
        x = 2373,
        y = 2065,
        z = 4245
      }
    },
    ["210134"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_StreetTreasure/Dungeon_A2_StreetTreasure_Release",
      bound_min = {
        x = 7636,
        y = 3088,
        z = -4662
      },
      bound_max = {
        x = 15636,
        y = 8088,
        z = 3338
      }
    },
    ["210132"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_Sudoku/Dungeon_A2_Sudoku_Release",
      bound_min = {
        x = -10797,
        y = -830,
        z = -13831
      },
      bound_max = {
        x = 9203,
        y = 7170,
        z = 6169
      }
    },
    ["210118"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_WeatherBattle/Dungeon_A2_WeatherBattle_Release",
      bound_min = {
        x = -10074,
        y = -5948,
        z = -13618
      },
      bound_max = {
        x = 9926,
        y = 9052,
        z = 16382
      }
    },
    ["210131"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/Dungeon_A2_WindMill/Dungeon_A2_WindMill_MainRelease",
      bound_min = {
        x = -12630,
        y = -14917,
        z = -15021
      },
      bound_max = {
        x = 17370,
        y = 15083,
        z = 14979
      }
    },
    ["120106"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/LMP_Dungeon_FengMianShengSuo_01/LMP_Dungeon_FengMianShengSuo_01_Release",
      bound_min = {
        x = -37670,
        y = -17345,
        z = -34040
      },
      bound_max = {
        x = 12330,
        y = 12655,
        z = 25960
      }
    },
    ["210106"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/LM_Dungeon_A1_Battle04/LM_Dungeon_A1_Battle04_Release",
      bound_min = {
        x = -8290,
        y = -3110,
        z = -6100
      },
      bound_max = {
        x = 16710,
        y = 4890,
        z = 3900
      }
    },
    ["210143"] = {
      level = "/Game/ArtRes/Level/Game/Dungeon/L_Plot_A1_TQ05_Lab_LM/L_Plot_A1_TQ05_Lab_LM_MainRelease",
      bound_min = {
        x = -5600,
        y = -850,
        z = -4070
      },
      bound_max = {
        x = 4400,
        y = 4150,
        z = 5930
      }
    }
  }
end

function PSODungeonTest:ReadFromJson(file)
  local config = JsonUtils.LoadSaved(file)
  if not config then
    Log.Warning("Failed to load TeleportCachePSO config file")
    self:AddDefaultDungeon()
    return
  end
  self.DungeonsInfo = config
end

function PSODungeonTest:InitPlayer(enable)
  self.player = _G.NRCModuleManager:DoCmd(_G.PlayerModuleCmd.GET_LOCAL_PLAYER)
  if not self.player or not self.player.ueController then
    Log.Error("Failed to get local player")
    return
  end
  self.player:SetViewVisible(true, true)
  self.player.ueController.PlayerCameraManager.bEnableMainUICamera = true
  self.StartRunPos = self.player:GetActorLocation()
end

function PSODungeonTest:DisableOcclusion()
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.AllowPrecomputedVisibility 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSoftwareOcclusion 1")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.Mobile.AllowSDOC 0")
  UE4.UKismetSystemLibrary.ExecuteConsoleCommand(UE4Helper.GetCurrentWorld(), "r.HZBOcclusion 0")
end

function PSODungeonTest:Start()
  if self.DungeonsInfo == nil then
    self:ReadFromJson("PSO_Dungeon")
  end
  if not self.DungeonsInfo then
    return
  end
  self:DisableOcclusion()
  _G.UpdateManager:Register(self)
  local Speed = self.DungeonsInfo.Speed
  self.DungeonsInfo.Speed = nil
  self:Scan_Next_Dungeon()
end

function PSODungeonTest:Scan_Next_Dungeon()
  self.DungeonIndex = nil
  for key, value in pairs(self.DungeonsInfo) do
    local dungeon_id = key
    local level = value.level
    local minBound = value.bound_min
    local maxBound = value.bound_max
    self.DungeonIndex = key
    self.DungeonsInfo[key] = nil
    self.DungeonBoundMin = minBound
    self.DungeonBoundMax = maxBound
    self:LoadDungeonLevel(level, dungeon_id)
    break
  end
  if not self.DungeonIndex then
    PSODungeonTest:AutoMoveAnywhereEnd()
    PSODungeonTest:End()
    NRCModeManager:ActiveMode("LocalMode")
    _G.LevelHelper:OpenLevel(L_Bigworld_01_Release)
  end
end

function PSODungeonTest:LoadDungeonLevel(level, dungeon_id)
  NRCEventCenter:RegisterEvent("LoadDungeonLevel", self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnDungeonLoaded)
  NRCModeManager:ActiveMode("LocalMode")
  NRCModuleManager:DoCmd(PlayerModuleCmd.CLEAR_ALL)
  self.player = nil
  LevelHelper:OpenLevel(level)
  Log.Debug("PSODungeonTest:LoadDungeonLevel: OpenLevel ", level, dungeon_id)
end

function PSODungeonTest:OnDungeonLoaded()
  NRCEventCenter:UnRegisterEvent(self, NRCGlobalEvent.PostLoadMapWithWorld, self.OnDungeonLoaded)
  _G.DelayManager:DelaySeconds(3, function()
    self:InitPlayer(true)
    DebugTabScenePublic:GhostMode()
    self:GetAllActors()
  end)
end

function PSODungeonTest:IsPosInBounds(pos, bound_min, bound_max)
  return pos.X >= bound_min.x and pos.X <= bound_max.x and pos.Y >= bound_min.y and pos.Y <= bound_max.y and pos.Z >= bound_min.z and pos.Z <= bound_max.z
end

function PSODungeonTest:GetAllActors()
  local StaticMeshActors = UE4.UGameplayStatics.GetAllActorsOfClass(UE4Helper.GetCurrentWorld(), UE4.AStaticMeshActor):ToTable()
  local max_z = -math.huge
  local highest_points = {}
  self.DungeonAllPos = {}
  for id, SMActor in ipairs(StaticMeshActors) do
    local Origin, Extend = SMActor:GetActorBounds()
    local actor_max_z = Origin.Z + Extend.Z
    local actor_min_z = Origin.Z - Extend.Z
    local actorPos = UE4.FVector(tonumber(Origin.X), tonumber(Origin.Y), tonumber(actor_max_z))
    if self:IsPosInBounds(actorPos, self.DungeonBoundMin, self.DungeonBoundMax) then
      Log.DebugFormat("PSODungeonTest:GetAllActors[%d] = %s, Pos = %1f,%.1f,%.1f", id, SMActor:GetName(), actorPos.X, actorPos.Y, actorPos.Z)
      local LandPos = SceneUtils.GetPosInLand(actorPos, 83, 90, Extend.Z * 2)
      if LandPos and self:IsPosInBounds(LandPos, self.DungeonBoundMin, self.DungeonBoundMax) then
        actorPos = LandPos
        Log.DebugFormat("PSODungeonTest:GetAllActors Land Pos[%d]:%.1f,%.1f,%.1f", id, actorPos.X, actorPos.Y, actorPos.Z)
      end
      table.insert(self.DungeonAllPos, actorPos)
    end
  end
  Log.Debug("PSODungeonTest:GetAllActors DungeonAllPos: ", #self.DungeonAllPos)
  self:ScanDungeonPostions(self.DungeonAllPos, 1)
end

function PSODungeonTest:ScanDungeonPostions(All, Index)
  if Index <= 0 then
    return
  end
  if Index > #All then
    self.DungeonAllPos = nil
    self:AutoMoveAnywhereEnd()
    self:Scan_Next_Dungeon()
    return
  end
  local Pos = All[Index]
  self.player:SetActorLocation(Pos)
  if Index >= #All then
    Log.Error("\233\129\141\229\142\134\231\187\147\230\157\159...", Index)
    self.DungeonAllPos = nil
    self:AutoMoveAnywhereEnd()
    self:Scan_Next_Dungeon()
    return
  end
  _G.DelayManager:DelaySeconds(0.5, self.ScanDungeonPostions, self, All, Index + 1)
end

function PSODungeonTest:AutoMoveAnywhereEnd()
  if self.AutoMoveTimer then
    if not self.player then
      self:InitPlayer(false)
    end
    if self.player then
      self.player:SetActorLocation(self.StartRunPos)
      self.player:SetViewVisible(true, true)
    end
    self.AutoMoveTimer:Stop()
    self.AutoMoveTimer = nil
    DebugTabScenePublic:GhostMode()
    Log.Debug("PSODungeonTest.AutoMoveAnywhereEnd:", self.StartRunPos.X, self.StartRunPos.Y, self.StartRunPos.Z)
  end
end

function PSODungeonTest:End()
  _G.UpdateManager:UnRegister(self)
  self.player = nil
  Log.Debug("PSODungeonTest End")
end

Speed = 256

function PSODungeonTest:OnTick(dt)
  if not self.player then
    return
  end
  self.player.ueController.Pawn:AddControllerYawInput(dt * Speed)
end

return PSODungeonTest
