local UMG_MainUIRoleHP_C = _G.NRCViewBase:Extend("UMG_MainUIRoleHP_C")
local PlayerModuleEvent = require("NewRoco.Modules.Core.PlayerModule.PlayerModuleEvent")
local TemperatureEnum = require("NewRoco.Modules.Core.Scene.Component.Temperature.TemperatureEnum")
local MainUIModuleEvent = require("NewRoco.Modules.System.MainUI.MainUIModuleEvent")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")

function UMG_MainUIRoleHP_C:Initialize(Initializer)
end

function UMG_MainUIRoleHP_C:OnConstruct()
  self.items = {}
  self:OnAddEventListener()
  NRCEventCenter:RegisterEvent("UMG_MainUIRoleHP_C", self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
  _G.NRCEventCenter:RegisterEvent("UMG_MainUIRoleHP_C", self, SceneEvent.OnPlayerDead, self.OnPlayerDead)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  self.tempHP = localPlayer.serverData.attrs.hp_temporary or 0
  local hp = localPlayer.serverData.attrs.hp + self.tempHP
  self.maxhp = math.max(localPlayer.serverData.attrs.hp_max, hp)
  self.realMaxHp = self.maxhp
  self.oldMaxHp = self.maxhp
  self.hp = hp
  self.oldHp = 0
  self.realHp = 0
  self.IsHalfInjure = false
  self.bt = 0
  self.preBt = 0
  self.audio = _G.NRCAudioManager:PlaySound2DAuto(40008009, "UMG_MainUIRoleHP_C")
  _G.NRCAudioManager:SetStateByName("Temperature", "No", "UMG_MainUIRoleHP_C")
  self:SetCount(hp, self.tempHP)
  self:PlayAnimation(self.close)
end

function UMG_MainUIRoleHP_C:OnDestruct()
  self:OnRemoveEventListener()
  _G.NRCAudioManager:ReleaseSession(self.audio, true)
  self.audio = -1
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.OnPlayerDead, self.OnPlayerDead)
  NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerTeleportFinish, self.OnPlayerTeleportFinish)
end

function UMG_MainUIRoleHP_C:OnPlayerDead()
  _G.NRCAudioManager:SetStateByName("Temperature", "No", "UMG_MainUIRoleHP_C")
end

function UMG_MainUIRoleHP_C:OnEnable()
end

function UMG_MainUIRoleHP_C:OnDisable()
end

function UMG_MainUIRoleHP_C:OnAddEventListener()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE, self.HPChange)
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE, self.HPMaxChange)
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_BODY_TEMP_CHANGED, self.OnBodyTempChange)
    localPlayer:AddEventListener(self, PlayerModuleEvent.ON_BODY_TEMP_STATE_CHANGED, self.OnBodyTempStateChanged)
  end
  _G.NRCEventCenter:RegisterEvent("UMG_Ability_Slot_Throw_C", self, SceneEvent.PlayerBornFinish, self.RefreshHP)
  self:RegisterEvent(self, MainUIModuleEvent.SetUiAlpha, self.ChangBG)
  self:RegisterEvent(self, MainUIModuleEvent.PlayHalfInjureFinishEvent, self.OnPlayHalfInjureFinishEvent)
end

function UMG_MainUIRoleHP_C:OnRemoveEventListener()
  self:UnRegisterEvent(self, MainUIModuleEvent.SetUiAlpha, self.ChangBG)
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if localPlayer then
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ROLE_HP_CHANGE, self.HPChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_ROLE_HP_MAX_CHANGE, self.HPMaxChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_BODY_TEMP_CHANGED, self.OnBodyTempChange)
    localPlayer:RemoveEventListener(self, PlayerModuleEvent.ON_BODY_TEMP_STATE_CHANGED, self.OnBodyTempStateChanged)
  end
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.PlayerBornFinish, self.RefreshHP)
end

function UMG_MainUIRoleHP_C:RefreshHP()
  local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  local tempHP = localPlayer.serverData.attrs.hp_temporary or 0
  local hp = localPlayer.serverData.attrs.hp + tempHP
  self:SetCount(hp, tempHP)
end

function UMG_MainUIRoleHP_C:HPChange(count, tempHP)
  Log.Debug("UMG_MainUIRoleHP_C:HPChange", count)
  self:SetCount(count, tempHP)
end

function UMG_MainUIRoleHP_C:HPMaxChange(count, tempHP, realMaxHp)
  Log.Debug("UMG_MainUIRoleHP_C:HPMaxChange", count)
  self.oldMaxHp = self.maxhp
  self.realMaxHp = realMaxHp
  self.tempHP = tempHP or 0
  self.maxhp = count
  self:SetCount(count, self.tempHP)
  self.oldMaxHp = self.maxhp
end

function UMG_MainUIRoleHP_C:OnPlayerTeleportFinish()
  self:OnRemoveEventListener()
  self:OnAddEventListener()
end

function UMG_MainUIRoleHP_C:OnBodyTempChange(bt, diffTime, btFinal, bForceUpdate)
  self.preBt = self.bt
  self.bt = bt
  local diffValue = math.min(math.abs(btFinal - bt), math.abs(btFinal))
  if diffValue > 0 then
    self.perAnmTime = diffTime / (diffValue / 10000 * self.hp)
  else
    self.perAnmTime = 0.01
  end
  if self.preBt >= 0 and self.bt < 0 then
    _G.NRCAudioManager:SetStateByName("Temperature", "Cold", "UMG_MainUIRoleHP_C")
  elseif self.preBt <= 0 and self.bt > 0 then
    _G.NRCAudioManager:SetStateByName("Temperature", "Hot", "UMG_MainUIRoleHP_C")
  elseif math.abs(self.bt - 0) <= 1.0E-6 then
    _G.NRCAudioManager:SetStateByName("Temperature", "No", "UMG_MainUIRoleHP_C")
  end
  self:RefreshItemState(bForceUpdate)
end

function UMG_MainUIRoleHP_C:OnBodyTempStateChanged(state)
  if state == TemperatureEnum.BodyState.HOT then
  else
    if state == TemperatureEnum.BodyState.COLD then
    else
    end
  end
end

function UMG_MainUIRoleHP_C:SetCount(count, tempCount)
  local oldHp = self.hp
  self.oldHp = oldHp
  self.hp = count
  local realHp = count - (tempCount or 0)
  self.realHp = realHp
  if count <= self.maxhp then
    count = self.maxhp
  end
  if count > 2000 then
    local stack = debug.traceback(nil)
    local ErrorMessage = string.format("\229\176\157\232\175\149\229\136\155\229\187\186\232\191\135\229\164\154\232\161\128\233\135\143UI(%d),\232\191\153\228\188\154\229\175\188\232\135\180\229\180\169\230\186\131...", count)
    NRCUtils.LuaFatalError(ErrorMessage, "Umg Exception", stack)
  end
  local itemcount = #self.items
  if count > itemcount then
    local cCount = count - itemcount
    for i = 1, cCount do
      local createitem = UE4.UWidgetBlueprintLibrary.Create(self.HorizontalBox_par, self.UMGMainUIRoleHPItem)
      if createitem and UE.UObject.IsValid(createitem) then
        createitem:SetIndex(i + itemcount)
        self.HorizontalBox_par:AddChild(createitem)
        table.insert(self.items, createitem)
      else
        Log.Error("UMG_MainUIRoleHP_C:SetCount create UMGMainUIRoleHPItem failed")
      end
    end
  end
  self.IsHalfInjure = false
  itemcount = #self.items
  for i = 1, itemcount do
    local item = self.items[i]
    if item:GetHalfInjure() then
      self.IsHalfInjure = true
    end
    if realHp >= i then
      item:UpdateState(self.bt)
      item:SetVisibleState(UE4.ESlateVisibility.Visible, i, oldHp, self.hp, self.oldMaxHp, self.maxhp, self.realMaxHp, false)
    elseif i <= self.hp then
      item:SetVisibleState(UE4.ESlateVisibility.Visible, i, oldHp, self.hp, self.oldMaxHp, self.maxhp, self.realMaxHp, true)
    elseif oldHp >= i then
      item:SetVisibleState(UE4.ESlateVisibility.Collapsed, i, oldHp, self.hp, self.oldMaxHp, self.maxhp, self.realMaxHp, false)
    else
      item:SetHpState()
    end
  end
  self:PlayHalfInjureAnim()
  if oldHp < self.hp then
    self:RefreshItemState(true)
  end
end

function UMG_MainUIRoleHP_C:OnPlayHalfInjureFinishEvent()
  if self.IsHalfInjure then
    self.IsHalfInjure = false
    self:PlayHalfInjureAnim()
  end
end

function UMG_MainUIRoleHP_C:PlayHalfInjureAnim()
  if not self.IsHalfInjure then
    local itemcount = #self.items
    local localPlayer = NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
    Log.Debug("UMG_MainUIRoleHP_C:SetCount", itemcount, localPlayer.serverData.attrs.half_injure, self.realHp)
    if 1 == localPlayer.serverData.attrs.half_injure and self.oldHp > 0 and itemcount >= self.realHp then
      local item = self.items[self.realHp]
      if item then
        item:PlayHalfBredAnim(true)
      end
    end
  end
end

function UMG_MainUIRoleHP_C:RefreshItemState(bForceUpdate)
  local hp = self.hp
  local bt = self.bt
  local preBt = self.preBt
  local perAnmTime = self.perAnmTime
  local itemcount = #self.items
  for i = 1, itemcount do
    local item = self.items[i]
    item:SetHpBt(hp, preBt, bt, perAnmTime, bForceUpdate)
  end
end

function UMG_MainUIRoleHP_C:ChangBG()
  self.HorizontalBox_par:SetVisibility(UE4.ESlateVisibility.Hidden)
end

return UMG_MainUIRoleHP_C
