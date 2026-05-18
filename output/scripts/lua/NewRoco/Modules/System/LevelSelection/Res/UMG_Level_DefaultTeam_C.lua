local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local LevelSelectionModuleEvent = require("NewRoco.Modules.System.LevelSelection.LevelSelectionModuleEvent")
local UMG_Level_DefaultTeam_C = Base:Extend("UMG_Level_DefaultTeam_C")

function UMG_Level_DefaultTeam_C:OnConstruct()
end

function UMG_Level_DefaultTeam_C:OnDestruct()
  if self.DelayId then
    _G.DelayManager:CancelDelayById(self.DelayId)
    self.DelayId = nil
  end
end

function UMG_Level_DefaultTeam_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.Text_name:SetText(_data.title)
  self.Exchange_1.btnLevelUp.OnClicked:Add(self, self.OpenBloodLineMagic)
  self.BloodBtn.OnClicked:Add(self, self.OpenBloodLineMagic)
  self.Btn_rename.OnClicked:Add(self, self.OnClickBtn_rename)
  self.Btn_add.OnClicked:Add(self, self.OnClickAddBtn)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Text_name_1:SetText(LuaText.challenge_text_28)
  if self.data.isDontPlayAim then
    self:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.DelayId = _G.DelayManager:DelaySeconds(0.05 * index, function()
      self:PlayAnimation(self.In)
      self:SetVisibility(UE4.ESlateVisibility.Visible)
    end)
  end
  if _data.teams and #_data.teams > 0 then
    local teamDatas = {}
    for i = 1, 6 do
      if i <= #_data.teams then
        table.insert(teamDatas, _data.teams[i])
      else
        table.insert(teamDatas, {pet_gid = 0})
      end
    end
    self.PetList:InitGridView(teamDatas)
    self.NRCSwitcher_1:SetActiveWidgetIndex(0)
    self.NRCImage_235:SetVisibility(UE4.ESlateVisibility.Visible)
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.NRCSwitcher_1:SetActiveWidgetIndex(1)
    self.NRCImage_235:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.Switcher:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  if _data.magicGid and 0 ~= _data.magicGid then
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, _data.magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
    self.Switcher:SetActiveWidgetIndex(0)
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_Level_DefaultTeam_C:OnItemSelected(_bSelected)
  if _bSelected then
    self:PlayAnimation(self.Select_In)
    _G.NRCModuleManager:GetModule("LevelSelectionModule"):DispatchEvent(LevelSelectionModuleEvent.OnSelectBattleTeam, self.data, self.index - 1)
  else
    self:PlayAnimation(self.Cancel)
  end
end

function UMG_Level_DefaultTeam_C:OpenBloodLineMagic()
  local items = _G.NRCModuleManager:DoCmd(_G.BagModuleCmd.GetBagItemArrayByType, _G.Enum.BagItemType.BI_PLAYERSKILL)
  if self.data.type == _G.Enum.PlayerTeamType.PTT_BIG_WORLD then
    for i, item in pairs(items) do
      if 1 == item.bag_item_flags then
        self.data.magicGid = item.gid
        break
      end
    end
  end
  if items and #items > 0 then
    _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenBloodLineMagic, self.data.type, self.data.idx)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, LuaText.challenge_text_10)
  end
end

function UMG_Level_DefaultTeam_C:UpdateBloodMagic(data)
  local magicGid = data.magicGid
  self.data.magicGid = magicGid
  if magicGid and 0 ~= magicGid then
    local bagItemData = _G.NRCModeManager:DoCmd(_G.BagModuleCmd.GetBagItemByGid, magicGid)
    local bagitemConf = _G.DataConfigManager:GetBagItemConf(bagItemData.id)
    self.Icon:SetPath(bagitemConf.icon)
    self.Switcher:SetActiveWidgetIndex(0)
  else
    self.Switcher:SetActiveWidgetIndex(1)
  end
end

function UMG_Level_DefaultTeam_C:OnDeactive()
end

function UMG_Level_DefaultTeam_C:OnAnimationFinished(anim)
end

function UMG_Level_DefaultTeam_C:OnClickAddBtn()
  Log.Error("\231\188\150\232\190\145\233\152\159\228\188\141")
  _G.NRCModuleManager:GetModule("LevelSelectionModule"):DispatchEvent(LevelSelectionModuleEvent.OnChangeBattleTeamItem, self.data)
end

function UMG_Level_DefaultTeam_C:OnClickBtn_rename()
  if self.data.type == _G.Enum.PlayerTeamType.PTT_BIG_WORLD then
    _G.NRCModeManager:DoCmd(TipsModuleCmd.TopHud_ShowTips, LuaText.challenge_text_21)
    return
  end
  local param = {
    teamType = self.data.type,
    TeamIdx = self.data.idx,
    teamName = self.data.title
  }
  _G.NRCModuleManager:DoCmd(_G.PetUIModuleCmd.OpenRechristenPanel, param, nil, 2)
end

function UMG_Level_DefaultTeam_C:OnSwitcherNRCSwitcher_56(SwitcherIndex)
  self.NRCSwitcher_56:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Level_DefaultTeam_C:OnClickBtn()
end

function UMG_Level_DefaultTeam_C:OnSwitcherSwitcher(SwitcherIndex)
  self.Switcher:SetActiveWidgetIndex(SwitcherIndex)
end

function UMG_Level_DefaultTeam_C:OnClickBloodBtn()
end

return UMG_Level_DefaultTeam_C
