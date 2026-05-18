local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local ENUM_PLAYER_DATA_EVENT = require("Data.Global.PlayerDataEvent")
local ENUM_TELEPORT_LOCK_TYPE = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local SceneUtils = require("NewRoco.Modules.Core.Scene.Common.SceneUtils")
local RoleHPComponent = Base:Extend("RoleHPComponent")

function RoleHPComponent:Ctor()
  self._curRoleHP = 0
  self._maxVRoleHP = 0
  self._curHalfInjure = 0
  self._locRoleHP = 0
  self._localHalfInjure = 0
  self._customDeathPerformTime = -1
  self._DeathReason = 0
  self.DeadAnimName = "NormalDead"
end

function RoleHPComponent:Attach(owner)
  Base.Attach(self, owner)
  self._curRoleHP = (self.owner.serverData.attrs.hp or 0) + (self.owner.serverData.attrs.hp_temporary or 0)
  self._locRoleHP = self._curRoleHP
  self._curHalfInjure = self.owner.serverData.attrs.half_injure or 0
  self._localHalfInjure = self._curHalfInjure
  self._maxVRoleHP = self.owner.serverData.attrs.hp_max
  self._uiMax = self._maxVRoleHP
  self._customDeathPerformTime = -1
  self.inAddMax = false
  self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, self._curRoleHP, self.owner.serverData.attrs.hp_temporary or 0)
  self.delayFunction = nil
  self._cacheDieNotify = false
end

function RoleHPComponent:DeAttach()
  Base.DeAttach(self)
  if self.delayFunction then
    DelayManager:CancelDelay(self.delayFunction)
  end
end

function RoleHPComponent:Update(deltaTime)
  local debug = false
  if debug then
    local safe = NRCModuleManager:DoCmd(AreaAndZoneModuleCmd.IsSafeZone)
    local LOG = "RoleHP: " .. self._curRoleHP .. "  / " .. self._maxVRoleHP
    if safe then
      UE4.UKismetSystemLibrary.PrintString(self.owner.viewObj, LOG .. " safe", true, false, UE4.FLinearColor(1, 0, 0.5, 1), deltaTime / 2)
    else
      UE4.UKismetSystemLibrary.PrintString(self.owner.viewObj, LOG, true, false, UE4.FLinearColor(1, 0, 0.5, 1), deltaTime / 2)
    end
  end
end

function RoleHPComponent:OnReConnect()
  if 0 == self._locRoleHP and self._locRoleHP ~= self._curRoleHP then
    self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
  end
  self._curRoleHP = (self.owner.serverData.attrs.hp or 0) + (self.owner.serverData.attrs.hp_temporary or 0)
  self._maxVRoleHP = self.owner.serverData.attrs.hp_max
  self._locRoleHP = self._curRoleHP
  self._curHalfInjure = self.owner.serverData.attrs.half_injure or 0
  self._localHalfInjure = self._curHalfInjure
  self._uiMax = self._maxVRoleHP
  self._customDeathPerformTime = -1
  self._cacheDieNotify = false
  self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE, self._maxVRoleHP, self.owner.serverData.attrs.hp_temporary, self.owner.serverData.attrs.hp_max)
  self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, self._curRoleHP, self.owner.serverData.attrs.hp_temporary or 0)
end

function RoleHPComponent:ReduceAllRoleHP(reason)
  if nil == reason or 0 == reason then
    Log.Error("\230\151\160\230\149\136\230\137\163\232\161\128\229\142\159\229\155\160\239\188\129\239\188\129\239\188\129")
    return
  end
  if nil == self.owner.serverData.attrs.hp then
    return
  end
  if GlobalConfig.UseLocalRoleHp then
    if self.owner.inputComponent then
      self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
    end
    return
  end
  Log.Debug("RoleHPComponent:ReduceAllRoleHP")
  if self.owner.serverData.attrs.hp > 0 then
    self._DeathReason = reason
    self:SendReduceMessage(self.owner.serverData.attrs.hp, reason)
  end
  self._customDeathPerformTime = -1
end

function RoleHPComponent:ReduceRoleHP(ReduceValue, reason, HasHalfInjure)
  if nil == reason or 0 == reason then
    Log.Error("\230\151\160\230\149\136\230\137\163\232\161\128\229\142\159\229\155\160\239\188\129\239\188\129\239\188\129")
    return
  end
  HasHalfInjure = HasHalfInjure or false
  if nil == self.owner.serverData.attrs.hp then
    return
  end
  if GlobalConfig.UseLocalRoleHp then
    return
  end
  Log.DebugFunc(function()
    return "RoleHPComponent:ReduceRoleHP " .. ReduceValue .. " HalfInjure " .. (HasHalfInjure and "1" or "0") .. " reason is " .. reason
  end)
  ReduceValue = math.floor(ReduceValue)
  if ReduceValue <= 0 and not HasHalfInjure then
    return
  end
  if ReduceValue < self.owner.serverData.attrs.hp then
    self._DeathReason = reason
    self:SendReduceMessage(ReduceValue, reason, HasHalfInjure)
  else
    self:ReduceAllRoleHP(reason)
  end
  self._customDeathPerformTime = -1
end

function RoleHPComponent:GetLocalRoleHP()
  return self._locRoleHP
end

function RoleHPComponent:GetRoleHP()
  return self._curRoleHP
end

function RoleHPComponent:GetMaxVRoleHP()
  return self._maxVRoleHP
end

function RoleHPComponent:SetCustomDeathPerformTime(time)
  self._customDeathPerformTime = time
end

function RoleHPComponent:OnDataChange(AttrTag)
  local newRoleHp = self.owner.serverData.attrs.hp + (self.owner.serverData.attrs.hp_temporary or 0)
  local newHalfInjure = self.owner.serverData.attrs.half_injure or 0
  local shouldPlayFX = AttrTag ~= ProtoEnum.AttrPresentTag.ENUM.None
  if self._curRoleHP ~= newRoleHp or self._curHalfInjure ~= newHalfInjure or self._locRoleHP ~= newRoleHp then
    Log.Debug("RoleHPComponent:\230\148\182\229\136\176\231\154\132\229\144\140\230\173\165\232\161\128\233\135\143\228\184\186\239\188\154" .. self.owner.serverData.attrs.hp .. "  \230\156\172\229\156\176\232\161\128\233\135\143\228\184\186\239\188\154" .. self._locRoleHP)
    Log.Debug("RoleHPComponent:\230\148\182\229\136\176\231\154\132\229\141\138\228\188\164\228\184\186\239\188\154" .. self.owner.serverData.attrs.half_injure .. "  \230\156\172\229\156\176\229\141\138\228\188\164\228\184\186\239\188\154" .. self._localHalfInjure)
    local preHpWithInjure = self._curRoleHP
    if 1 == self._curHalfInjure then
      preHpWithInjure = preHpWithInjure - 0.5
    end
    local newHpWithInjure = newRoleHp
    if 1 == newHalfInjure then
      newHpWithInjure = newHpWithInjure - 0.5
    end
    self._curHalfInjure = newHalfInjure
    self._localHalfInjure = self._curHalfInjure
    if preHpWithInjure < newHpWithInjure then
      if shouldPlayFX and newRoleHp <= self._maxVRoleHP and not self.inAddMax then
        self.owner:PlayAddRoleHpEffect(AttrTag)
      else
        self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, newRoleHp, self.owner.serverData.attrs.hp_temporary or 0)
      end
      self._locRoleHP = newRoleHp
      Log.Debug("RoleHPComponent:\230\148\182\229\136\176\229\138\160\232\161\128\239\188\140\229\144\140\230\173\165\230\156\172\229\156\176\232\161\128\233\135\143\239\188\154" .. self._locRoleHP)
      if self.owner.isLocal and self.owner.teleportComponent and self.owner.teleportComponent._confirmUI then
        Log.Debug("TeleportComponent:\231\148\159\229\145\189\229\183\178\230\129\162\229\164\141\239\188\140\231\167\187\233\153\164UI")
        self.owner.teleportComponent._confirmUI._hasConfirm = true
        self.owner.teleportComponent._confirmUI:FinishConfirm()
      end
    else
      if preHpWithInjure > newHpWithInjure and not self.inAddMax and not self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_BATTLE) then
        self.owner:PlayReduceRoleHpEffect()
      end
      if newRoleHp < 0 then
        newRoleHp = 0
      end
      self._locRoleHP = newRoleHp
      self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE, newRoleHp, self.owner.serverData.attrs.hp_temporary or 0)
    end
    self._curRoleHP = newRoleHp
    if 0 ~= self._curRoleHP and 0 ~= self._locRoleHP then
      self._DeathReason = 0
    end
    Log.Debug("RoleHPComponent: \231\188\147\229\173\152\231\154\132\229\143\151\229\135\187\229\142\159\229\155\160  " .. self._DeathReason)
    self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_CHANGE_RAW, newRoleHp)
  end
end

function RoleHPComponent:OnHPMaxChange(bTemperal)
  local newRoleHpMax = self.owner.serverData.attrs.hp_max
  if bTemperal then
    newRoleHpMax = math.max(self.owner.serverData.attrs.hp_max, self.owner.serverData.attrs.hp_temporary + self.owner.serverData.attrs.hp)
  end
  local bHaveTempData
  bHaveTempData = self.owner.serverData.attrs.hp_temporary and self.owner.serverData.attrs.hp_temporary > 0
  if self._maxVRoleHP ~= newRoleHpMax then
    if newRoleHpMax > self._maxVRoleHP then
      if bHaveTempData then
        self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE, newRoleHpMax, self.owner.serverData.attrs.hp_temporary, self.owner.serverData.attrs.hp_max)
        self._uiMax = self.newRoleHpMax
      else
        self.owner:PlayAddRoleHpMaxEffect()
        self.inAddMax = true
      end
    else
      self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE, newRoleHpMax, self.owner.serverData.attrs.hp_temporary, self.owner.serverData.attrs.hp_max)
      self._uiMax = self.newRoleHpMax
    end
    self._maxVRoleHP = newRoleHpMax
    self.owner:SendEvent(PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE_RAW, newRoleHpMax)
  end
end

function RoleHPComponent:SendReduceMessage(ReduceValue, reason, HasHalfInjure)
  local req = ProtoMessage:newZoneSubRoleHpReq()
  req.sub_val = ReduceValue
  req.sub_reason = reason
  req.has_half_injure = HasHalfInjure
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_SUB_ROLE_HP_REQ, req, self, self.OnReduceRoleHPSubmit, false, false)
  if HasHalfInjure then
    self._localHalfInjure = self._localHalfInjure + 1
  end
  if 2 == self._localHalfInjure then
    self._localHalfInjure = 0
    ReduceValue = ReduceValue + 1
  end
  self._locRoleHP = self._locRoleHP - ReduceValue
  if 0 == self._locRoleHP then
    self:PreDeathPerform()
  end
  if self._locRoleHP < 0 then
    self._locRoleHP = 0
  end
end

function RoleHPComponent:OnReduceRoleHPSubmit(rsp)
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_BUFF_BAN_SUB_ROLE then
    self:OnDataChange(ProtoEnum.AttrPresentTag.ENUM.None)
    Log.Error("\229\174\162\230\136\183\231\171\175\230\137\163\232\161\128\232\162\171\229\144\142\229\143\176\230\139\146\231\187\157\228\186\134\239\188\140\229\155\158\233\128\128\230\156\172\229\156\176\232\161\128\233\135\143 ", self._locRoleHP)
    return
  end
end

function RoleHPComponent:PreDeathPerform(DeathReason)
  Log.Debug("RoleHPComponent:PreDeathPerform")
  _G.NRCAudioManager:PlaySound2DAuto(1150, "roleHPComponent")
  self.owner.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  
  function self.delayFunction()
    self:UnLockTeleport()
  end
  
  Log.Debug("RoleHPComponent:\230\156\172\229\156\176\228\184\138\230\138\165\230\137\163\232\161\128\230\173\187\228\186\161,\230\168\161\229\157\151\232\180\159\232\180\163\232\161\168\230\188\148")
  if self._customDeathPerformTime > 0 then
    DelayManager:DelaySeconds(self._customDeathPerformTime, self.delayFunction)
  else
    self:UnLockTeleport()
  end
end

function RoleHPComponent:DeathPerform(DeathAct)
  local DeathReason = DeathAct.die_reason
  Log.Debug("RoleHPComponent:DeathPerform")
  NRCModuleManager:DoCmd(PlayerModuleCmd.LockTeleport, ENUM_TELEPORT_LOCK_TYPE.LockType.DEATH_PERFORM)
  self._cacheDieNotify = true
  if self.delayFunction then
    Log.Debug("RoleHPComponent:HavePreDeathPerform")
    return
  end
  if self.owner.inputComponent then
    self.owner.inputComponent:SetInputEnable(self, false, "DeathPerform")
  end
  
  function self.delayFunction()
    self:UnLockTeleport()
  end
  
  _G.NRCAudioManager:PlaySound2DAuto(1150, "roleHPComponent")
  self.owner.statusComponent:ApplyStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  if DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_TEMPERATURE and self.owner.statusComponent:HasStatus(ProtoEnum.WorldPlayerStatusType.WPST_LANDED) then
    Log.Debug("RoleHPComponent:\230\184\169\229\186\166\230\173\187\228\186\161")
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    local Montage = self.owner.viewObj:GetAnimComponent():GetAnimSequenceByName(self.DeadAnimName)
    AnimInstance:PlaySlotAnimation(Montage, "DefaultSlot", 0.1, 0.1)
    DelayManager:DelaySeconds(2, self.delayFunction)
  elseif DeathReason == ProtoEnum.ActorDieReason.ACTOR_DIE_REASON_WORLD_COMBAT_ATTACKING then
    local HitDir = UE.FVector(DeathAct.dir.x, DeathAct.dir.y, DeathAct.dir.z)
    self.owner:SendEvent(PlayerModuleEvent.ON_PLAYER_ATTACKED_BY_NPC, 0, HitDir, true, true)
    DelayManager:DelaySeconds(1.5, self.delayFunction)
  else
    self:UnLockTeleport()
  end
end

function RoleHPComponent:UnLockTeleport()
  self.delayFunction = nil
  if self._cacheDieNotify then
    NRCModuleManager:DoCmd(PlayerModuleCmd.UnLockTeleport, ENUM_TELEPORT_LOCK_TYPE.LockType.DEATH_PERFORM)
    self._cacheDieNotify = false
  else
    if self.owner.inputComponent then
      self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
    end
    self.owner.statusComponent:RemoveStatus(ProtoEnum.WorldPlayerStatusType.WPST_DEATH)
  end
end

return RoleHPComponent
