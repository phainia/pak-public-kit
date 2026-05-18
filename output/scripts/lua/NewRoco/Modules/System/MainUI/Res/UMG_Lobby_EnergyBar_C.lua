local BattleConst = require("NewRoco.Modules.Core.Battle.Common.BattleConst")
local SceneEvent = require("NewRoco.Modules.Core.Scene.Common.SceneEvent")
local UMG_Lobby_EnergyBar_C = _G.NRCViewBase:Extend("UMG_Lobby_EnergyBar_C")

function UMG_Lobby_EnergyBar_C:Initialize(Initializer)
end

function UMG_Lobby_EnergyBar_C:OnConstruct()
  self.Tracks = {}
  self.EnergyView:Setup()
  self.EnergyNotify = nil
  local Energy = self:GetEnergy()
  local Player = _G.NRCModuleManager:DoCmd(PlayerModuleCmd.GET_LOCAL_PLAYER)
  if Player and Player.cachedAddEnergy then
    local Notify = Player.cachedAddEnergy
    self.EnergyView:SetSlots(Energy - Notify.real_add_val)
  else
    self.EnergyView:SetSlots(Energy)
  end
  _G.NRCEventCenter:RegisterEvent("UMG_Lobby_EnergyBar_C", self, SceneEvent.ON_PLAY_ADD_ENERGY_FX, self.OnPlayAddFx)
end

function UMG_Lobby_EnergyBar_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, SceneEvent.ON_PLAY_ADD_ENERGY_FX, self.OnPlayAddFx)
  for Index, Widget in ipairs(self.Tracks) do
    Widget:RemoveFromParent()
  end
  table.clear(self.Tracks)
end

function UMG_Lobby_EnergyBar_C:OnPlayAddFx(notify)
  Log.Error("Will play add energy fx")
  if not notify then
    return
  end
  self.EnergyNotify = notify
  if 0 == notify.config_add_val then
    return
  end
  self:LoadPanelRes(BattleConst.UI.UMG_Battle_EnergyTrack, 255, self.EnergyTrackLoadSucc)
end

function UMG_Lobby_EnergyBar_C:EnergyTrackLoadSucc(resRequest, TrackClass)
  if not self.EnergyNotify then
    return
  end
  local LobbyMain = self:GetCanvas()
  if not LobbyMain then
    return
  end
  local ParentCanvas = LobbyMain.VisibleContents
  if not TrackClass then
    return
  end
  for i = 1, self.EnergyNotify.config_add_val do
    local TrackWidget = UE4.UWidgetBlueprintLibrary.Create(LobbyMain, TrackClass)
    table.insert(self.Tracks, TrackWidget)
  end
  local EndPos = UE4.USlateBlueprintLibrary.GetLocalTopLeft(self:GetCachedGeometry())
  for Index, Widget in ipairs(self.Tracks) do
    ParentCanvas:AddChildToCanvas(Widget)
    Widget:GeneralFly(UE4.FVector2D(300, 300), EndPos, self, self.CheckFinish)
  end
end

function UMG_Lobby_EnergyBar_C:CheckFinish()
  for Index, Widget in ipairs(self.Tracks) do
    if not Widget.isFinished then
      return
    end
  end
  self:UpdateBar()
end

function UMG_Lobby_EnergyBar_C:GetCanvas()
  local MainUIModule = _G.NRCModuleManager:GetModule("MainUIModule")
  if not MainUIModule then
    return nil
  end
  if MainUIModule:HasPanel("LobbyMain") then
    local panel = MainUIModule:GetPanel("LobbyMain")
    if panel and panel.enableView then
      return panel
    else
      return nil
    end
  else
    return nil
  end
end

function UMG_Lobby_EnergyBar_C:UpdateBar()
  self.EnergyView:SetEnergy(self:GetEnergy())
end

function UMG_Lobby_EnergyBar_C:GetEnergy()
  local PlayerInfo = _G.DataModelMgr.PlayerDataModel.playerInfo
  local BriefInfo = PlayerInfo and PlayerInfo.brief_info
  local VItemInfo = BriefInfo and BriefInfo.vitem_info
  local VItemList = VItemInfo and VItemInfo.vitem_list
  local EnergyIndex = _G.ProtoEnum.VisualItem.VI_ENERGY + 1
  local Energy = VItemList and VItemList[EnergyIndex] or 0
  return Energy or 0
end

return UMG_Lobby_EnergyBar_C
