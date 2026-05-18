local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LegendaryBattleModuleEnum = require("NewRoco.Modules.Activity.LegendaryBattle.LegendaryBattleModuleEnum")
local UMG_LegendaryBattle_TeammateItem_C = Base:Extend("UMG_LegendaryBattle_TeammateItem_C")

function UMG_LegendaryBattle_TeammateItem_C:OnConstruct()
end

function UMG_LegendaryBattle_TeammateItem_C:OnDestruct()
end

function UMG_LegendaryBattle_TeammateItem_C:OnItemUpdate(_data, datalist, index)
  local visitorList = _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.GetOnlineVisitorList)
  Log.Dump(_data, 4, "UMG_LegendaryBattle_TeammateItem_C:OnItemUpdate")
  self.uiData = _data
  self.HeadPortrait:SetPath(_data.iconPath)
  local myUin = _G.DataModelMgr.PlayerDataModel:GetPlayerUin()
  if 0 ~= _data.uin then
    self.Switcher:SetActiveWidgetIndex(0)
    self.TextName:SetText(_data.name)
    if 0 == #visitorList then
      self.Switcher_Sort:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.Switcher_Sort:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    end
    if _data.uin == myUin then
      self.Switcher_Sort:SetActiveWidgetIndex(0)
    else
      self.Switcher_Sort:SetActiveWidgetIndex(1)
    end
    local numText = string.format("%dP", index)
    self.TextSort:SetText(numText)
    self.NRCText_51:SetText(numText)
    if _data.curState == nil or _data.curState == LegendaryBattleModuleEnum.CurState.None then
      self.CurState:SetVisibility(UE4.ESlateVisibility.Collapsed)
    else
      self.CurState:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if _data.curState == LegendaryBattleModuleEnum.CurState.Fighting then
        self.CurState:SetActiveWidgetIndex(1)
      elseif _data.curState == LegendaryBattleModuleEnum.CurState.Resonance then
        self.CurState:SetActiveWidgetIndex(2)
      elseif _data.curState == LegendaryBattleModuleEnum.CurState.Catching then
        self.CurState:SetActiveWidgetIndex(0)
      end
    end
  else
    self.Switcher:SetActiveWidgetIndex(1)
    self.TextMatchmaking:SetText(_data.name)
  end
  if _data.name == "" then
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.Switcher:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self:SetNetWork()
end

function UMG_LegendaryBattle_TeammateItem_C:SetNetWork()
  local NetWorkConf = _G.DataConfigManager:GetOnlineGlobalConfig(9)
  local NetWorkRange = NetWorkConf.numList
  local NetWorkState = 0
  local network = self.uiData.netWork
  if NetWorkConf.key == "wifi_sign_strength" then
    if network then
      if network < NetWorkRange[1] and network > 0 then
        NetWorkState = 0
      elseif network < NetWorkRange[1] and network <= NetWorkRange[2] then
        NetWorkState = 1
      elseif network > NetWorkRange[2] then
        NetWorkState = 2
      else
        NetWorkState = 2
      end
    end
  else
    Log.Error("key\229\146\140id\229\175\185\228\184\141\228\184\138\232\190\163")
  end
  self.Signal:SetActiveWidgetIndex(NetWorkState)
end

function UMG_LegendaryBattle_TeammateItem_C:OnItemSelected(_bSelected)
end

function UMG_LegendaryBattle_TeammateItem_C:OnDeactive()
end

return UMG_LegendaryBattle_TeammateItem_C
