local Base = require("NewRoco.Modules.Core.Scene.Component.ActorComponent")
local ENUM_TELEPORT_LOCK_TYPE = require("NewRoco.Modules.Core.Scene.Component.RoleHP.TeleportLockEnum")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local BattleUIModuleCmd = require("NewRoco.Modules.System.BattleUI.BattleUIModuleCmd")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local TeleportComponent = Base:Extend("TeleportComponent")

function TeleportComponent:Ctor()
end

function TeleportComponent:Attach(owner)
  Base.Attach(self, owner)
  self._lockList = {}
  self._cachedNotify = nil
  self._confirmUI = nil
  self._callbackList = {}
  self._callbackStamp = {}
  WeakTable(self._callbackList)
  WeakTable(self._callbackStamp)
  _G.ZoneServer:AddProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_REVIVE_TELEPORT_NOTIFY, self.CacheTeleportNotify)
end

function TeleportComponent:DeAttach()
  Base.DeAttach(self)
  self._lockList = {}
  self._cachedNotify = nil
  if self._confirmUI then
    self._confirmUI._hasConfirm = true
    self._confirmUI:FinishConfirm()
  end
  self._confirmUI = nil
  self._callbackList = {}
  self._callbackStamp = {}
  _G.ZoneServer:RemoveProtocolListener(self, ProtoCMD.ZoneSvrCmd.ZONE_SCENE_REVIVE_TELEPORT_NOTIFY, self.CacheTeleportNotify)
end

function TeleportComponent:OnReConnect()
end

function TeleportComponent:LockTeleport(LockType)
  Log.Trace("TeleportComponent:LockTeleport ", LockType)
  table.insert(self._lockList, LockType)
end

function TeleportComponent:UnLockTeleport(LockType)
  Log.Trace("TeleportComponent:UnLockTeleport ", LockType)
  local size = #self._lockList
  for i = size, 1, -1 do
    if self._lockList[i] == LockType then
      table.remove(self._lockList, i)
      break
    end
  end
  self:TryTeleport()
end

function TeleportComponent:BindCallback(Stamp, Caller, Callback)
  self._callbackList[Callback] = Caller
  self._callbackStamp[Callback] = Stamp
  Log.Debug("BindCallback")
  Log.Dump(self._callbackList)
end

function TeleportComponent:GetCachedNotify()
  return self._cachedNotify
end

function TeleportComponent:CacheTeleportNotify(notify)
  Log.Debug("TeleportComponent:CacheTeleportNotify")
  Log.Dump(notify, 4, "TeleportComponent")
  if GlobalConfig.EnableDeahTeleport then
    if self.owner.inputComponent then
      self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
    end
    return
  end
  if self._confirmUI then
    Log.Error("\230\173\187\228\186\161\233\128\154\231\159\165\230\156\170\229\164\132\231\144\134\229\174\140\230\136\144\239\188\140\230\148\182\229\136\176\230\150\176\233\128\154\231\159\165\239\188\140\229\176\134\232\191\155\232\161\140\228\184\162\229\188\131\239\188\129")
    return
  end
  if self._cachedNotify ~= nil then
    Log.Warning("\229\183\178\229\173\152\229\156\168TeleportNotify\231\188\147\229\173\152\239\188\140\229\176\134\232\191\155\232\161\140\232\166\134\231\155\150\239\188\129")
  end
  self._cachedNotify = notify
  self:TryTeleport()
end

function TeleportComponent:TryTeleport()
  Log.Debug("TeleportComponent:TryTeleport")
  if #self._lockList > 0 then
    Log.Debug("TeleportComponent:TeleportLocked")
    Log.Dump(self._lockList, 3, "TeleportComponent")
    return
  end
  if self._cachedNotify == nil then
    Log.Debug("TeleportComponent:NoTeleportNotify")
    if self.owner.inputComponent then
      self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
    end
    if #self._callbackList > 0 then
      Log.Warning("\230\156\170\230\148\182\229\136\176\228\188\160\233\128\129Notify\239\188\140\228\189\134\230\156\137\230\168\161\229\157\151\228\190\157\232\181\150\228\188\160\233\128\129Callback\239\188\129\230\163\128\230\159\165\230\168\161\229\157\151\233\128\187\232\190\145\230\136\150\231\161\174\232\174\164\230\152\175\229\144\166Notify\228\184\162\229\140\133")
    end
    return
  end
  Log.Debug("TeleportComponent:CanTeleport")
  self:SendDeathEvent()
  NRCModeManager:DoCmd(TipsModuleCmd.Tips_ShowConfirmTeleportTips, self)
end

function TeleportComponent:BindUMG(UMG_Confirm)
  if UMG_Confirm then
    self._confirmUI = UMG_Confirm
    self._confirmUI:SetNotify(self._cachedNotify)
    self._cachedNotify = nil
    self:OnBlackShown()
  end
end

function TeleportComponent:UnBindUMG()
  self._confirmUI = nil
end

function TeleportComponent:SendDeathEvent()
  Log.Debug("TeleportComponent:\229\143\145\233\128\129\230\173\187\228\186\161\228\186\139\228\187\182\239\188\140\229\136\183\233\187\145\229\177\143")
  self.owner:OnDead()
  self.owner:SendEvent(PlayerModuleEvent.ON_PLAYER_DEAD)
  _G.NRCEventCenter:DispatchEvent(SceneEvent.OnPlayerDead)
  _G.NRCModuleManager:DoCmd(_G.MainUIModuleCmd.CloseCompass, false)
  _G.NRCModuleManager:DoCmd(TipsModuleCmd.Dialog_DisableShouldCloseDialog)
end

function TeleportComponent:OnBlackShown()
  self:StampTrigger(ENUM_TELEPORT_LOCK_TYPE.CallbackStamp.ON_BLACK_SHOWN)
  self._confirmUI.TeleportPanel:SetVisibility(UE4.ESlateVisibility.Hidden)
  self._confirmUI:PlayAnimation(self._confirmUI.TweenIn)
end

function TeleportComponent:OnBlackEnd()
  Log.Debug("TeleportComponent:\229\133\179\233\151\173\233\187\145\229\177\143\239\188\140\230\137\147\229\188\128\228\188\160\233\128\129\231\149\140\233\157\162")
  self:StampTrigger(ENUM_TELEPORT_LOCK_TYPE.CallbackStamp.ON_TELEPORT_UI_SHOWN)
  self._confirmUI.TeleportPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  if self.owner.viewObj then
    local AnimInstance = self.owner.viewObj.Mesh:GetAnimInstance()
    if AnimInstance then
      AnimInstance:StopSlotAnimation(0)
      AnimInstance:Montage_Stop(0)
    end
  end
  if self.owner.inputComponent then
    self.owner.inputComponent:SetInputEnable(self, true, "DeathPerform")
  end
end

function TeleportComponent:StampTrigger(Stamp)
  for key, v in pairs(self._callbackStamp) do
    if v == Stamp then
      if self._callbackList[key] then
        key(self._callbackList[key])
        Log.Debug("StampTriggerCallback")
        table.removeKey(self._callbackList, key)
      else
        Log.Error("callback\229\173\152\229\156\168\228\189\134caller\232\162\171GC!!!")
      end
      table.removeKey(self._callbackStamp, key)
    end
  end
end

function TeleportComponent:OnConfirmTeleport()
  Log.Debug("TeleportComponent:send teleport confirm req")
  local req = _G.ProtoMessage:newZoneConfirmReviveReq()
  _G.ZoneServer:SendWithHandler(ProtoCMD.ZoneSvrCmd.ZONE_CONFIRM_REVIVE_REQ, req, self, self.OnConfirmTeleportRSP, true, true)
end

function TeleportComponent:OnConfirmTeleportRSP(rsp)
  Log.Debug("TeleportComponent: teleport confirm req receive rsp. Teleported!!")
  if self._confirmUI then
    self._confirmUI._hasConfirm = true
  end
  if rsp.ret_info.ret_code == ProtoEnum.MOBA_RET.SceneErr.ERR_SCENE_AVATAR_NOT_IN_REVIVING and self._confirmUI then
    self._confirmUI:FinishConfirm()
  end
end

return TeleportComponent
