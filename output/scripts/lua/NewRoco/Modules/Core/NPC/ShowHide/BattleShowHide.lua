local ShowHideBase = require("NewRoco.Modules.Core.NPC.ShowHide.ShowHideBase")
local BattleModuleCmd = require("NewRoco.Modules.Core.Battle.BattleModuleCmd")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local SceneModuleCmd = require("NewRoco.Modules.Core.Scene.SceneModuleCmd")
local Base = ShowHideBase
local BattleShowHide = Base:Extend("BattleShowHide")

function BattleShowHide:Ctor()
  Base.Ctor(self)
  self.IsBattle = false
  self.center = nil
  self.battle_radius = nil
  self.onlookers = {}
end

function BattleShowHide:GetReason()
  return 1
end

function BattleShowHide:StartHide()
  self.IsBattle = _G.NRCModuleManager:DoCmd(BattleModuleCmd.IsInBattle)
  if self.IsBattle then
    self.center = _G.NRCModuleManager:DoCmd(BattleModuleCmd.GetBattleFieldCenterPos)
    self.battle_radius = _G.NRCModuleManager:DoCmd(BattleModuleCmd.GetBattleFieldRadius)
    if self.center and self.battle_radius then
      self.sqrRadius = self.battle_radius * self.battle_radius
      self:RegisterExternalCheckerForBattle()
      self:CollectOnlookers()
      return true
    end
  end
  return false
end

function BattleShowHide:CheckShouldHide(npc, incomeWhenBattle)
  if not (self.IsBattle and self.center) or not self.battle_radius then
    return false
  end
  if not npc then
    return false
  end
  if not npc.config then
    return false
  end
  if 1 == npc.config.dont_hide_in_battle then
    return false
  end
  local viewObj = npc.viewObj
  if not UE.UObject.IsValid(viewObj) then
    return false
  end
  local npcPos = viewObj:Abs_K2_GetActorLocation()
  if not npcPos then
    Log.Error("CheckShouldHide\229\156\168\232\142\183\229\143\150Location\231\154\132\230\151\182\229\128\153\231\169\186\228\186\134!!!!!!!!!!!!!")
    if npc.serverData and npc.serverData.base then
      Log.Error("\230\156\137\233\151\174\233\162\152\231\154\132NPC\230\152\175: ", npc.serverData.base.name, npc.serverData.base.actor_id)
    end
    if viewObj and viewObj.GetFullName then
      Log.Error("\229\175\185\229\186\148\231\154\132\229\144\141\229\173\151\230\152\175: ", viewObj:GetFullName())
    end
    return false
  end
  local disSqr = UE4.FVector.DistSquared(self.center, npcPos)
  local isOnlooker = self:IsOnlooker(npc:GetServerId())
  local isPlayerPet = npc:IsAThrownPet()
  local skipRangeCheck = npc._battleHardCheck or incomeWhenBattle or isOnlooker or isPlayerPet or false
  if not skipRangeCheck then
    if disSqr >= self.sqrRadius then
      return false
    end
    if not _G.NRCModuleManager:DoCmd(BattleModuleCmd.CheckNpcInHideRange, viewObj) then
      return false
    end
  end
  if viewObj.OnEnterBattle then
    viewObj:OnEnterBattle(self.center, self.battle_radius, skipRangeCheck and 0 or disSqr)
  end
  return false
end

function BattleShowHide:EndHide()
  Base.EndHide(self)
end

function BattleShowHide:StartShow()
  self:UnregisterExternalCheckerForBattle()
  self.IsBattle = false
  self.center = nil
  self.battle_radius = nil
  return true
end

function BattleShowHide:CheckShouldShow(npc)
  local viewObj = npc.viewObj
  if viewObj and viewObj.OnLeaveBattle then
    viewObj:OnLeaveBattle()
  else
    Log.Error("BattleShowHide:CheckShouldShow ViewObj is InValid", npc:DebugNPCNameAndID())
    npc:SetVisibleForBattleReason(true)
  end
  return false
end

function BattleShowHide:EndShow()
  Base.EndShow(self)
end

function BattleShowHide:ShouldPauseTick()
  return false
end

function BattleShowHide:ShouldPauseFind()
  return true
end

function BattleShowHide:RegisterExternalCheckerForBattle()
  if not self.isCreateBattleArea then
    local blockingParam = _G.NRCModuleManager:DoCmd(SceneModuleCmd.RegisterBlockingArea, 1001, self.center, self.battle_radius, true, PriorityEnum.Passive_Battle_Nav)
    blockingParam.overlap_caller = self
    blockingParam.overlap_callback = self.CheckShouldHide
    self.isCreateBattleArea = true
  end
end

function BattleShowHide:UnregisterExternalCheckerForBattle()
  if self.isCreateBattleArea then
    _G.NRCModuleManager:DoCmd(SceneModuleCmd.UnregisterBlockingArea, 1001)
    self.isCreateBattleArea = false
  end
end

function BattleShowHide:IsBattleCreateArea(id)
  return 1001 == id
end

function BattleShowHide:CollectOnlookers()
  table.clear(self.onlookers)
  local initInfo = BattleUtils.GetBattleInitInfo()
  if initInfo then
    if initInfo.onlooker_a and "table" == type(initInfo.onlooker_a) then
      for _, v in ipairs(initInfo.onlooker_a) do
        table.insert(self.onlookers, v.npc_obj_id)
      end
    end
    if initInfo.onlooker_b and "table" == type(initInfo.onlooker_b) then
      for _, v in ipairs(initInfo.onlooker_b) do
        table.insert(self.onlookers, v.npc_obj_id)
      end
    end
  end
end

function BattleShowHide:IsOnlooker(serverId)
  return table.contains(self.onlookers, serverId)
end

return BattleShowHide
