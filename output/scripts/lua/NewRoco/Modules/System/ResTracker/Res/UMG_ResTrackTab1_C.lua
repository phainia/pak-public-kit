local ResTrackerModuleEvent = require("NewRoco.Modules.System.ResTracker.ResTrackerModuleEvent")
local UMG_ResTrackTab1_C = _G.NRCViewBase:Extend("UMG_ResTrackTab1_C")

function UMG_ResTrackTab1_C:OnConstruct()
  self:SetChildViews(self.TrackResults)
  self.On = false
  self.OnlyButtonTriggered = true
  self.FrameInterval = 300
  self.MinFrameInterval = 50
  self.TriggerFrameCounter = self.FrameInterval
  self.green = UE4.UNRCStatics.HexToSlateColor("#3DFF55FF")
  self.red = UE4.UNRCStatics.HexToSlateColor("#FF0000FF")
  self.Data = {}
  self:AddButtonListener(self.TrackButton, self.Toggle)
  self:AddButtonListener(self.ModeButton, self.SwitchMode)
  self:AddButtonListener(self.FillButton, self.FillUMGName)
  self:AddButtonListener(self.DropDownButton, self.DropDown)
  self:RegisterEvent(self, ResTrackerModuleEvent.ResultItemClicked, self.CacheResultItem)
  self:RegisterEvent(self, ResTrackerModuleEvent.UMGItemClicked, self.FillCommonUMG)
  self:InitUMGList()
end

function UMG_ResTrackTab1_C:InitUMGList()
  local CommonUMG = {
    "UMG_ResTrackPanel",
    "UMG_Bag",
    "UMG_LobbyMain",
    "UMG_NPCShop",
    "UMG_Login",
    "UMG_Login_New",
    "UMG_PetInfoMain",
    "UMG_PetLeftPanel",
    "UMG_PetTotalWarehouse",
    "UMG_PetFightMain",
    "UMG_PetMiddlePanel",
    "UMG_PetRightPanel",
    "UMG_PetEvolution",
    "UMG_PetSkillMain",
    "UMG_MainPet",
    "UMG_MainMap",
    "UMG_HeroInfoMain",
    "UMG_MapWorld",
    "UMG_Dialog",
    "UMG_DialogueMain",
    "UMG_Department",
    "UMG_Tips",
    "UMG_Goods",
    "UMG_Handbook",
    "UMG_BookInfoMain",
    "UMG_TopHUD",
    "UMG_TowerMain",
    "UMG_ZoneTip",
    "UMG_PlayerInfoHUD",
    "UMG_PetUpgradePanel",
    "UMG_PetTalentInfo",
    "UMG_LevelUpMain",
    "UMG_"
  }
  table.sort(CommonUMG)
  self.UMGDropDownList:InitList(CommonUMG)
  self.IsDropDown = true
  self:DropDown()
end

function UMG_ResTrackTab1_C:OnDestruct()
  self:UnRegisterAllEvent()
  self:RemoveAllButtonListener()
end

function UMG_ResTrackTab1_C:Init(TrackPanel)
  self.TrackPanel = TrackPanel
  self.Tracker = TrackPanel.Tracker
  self.Tip = TrackPanel.Tip
  self.TipTime = TrackPanel.TipTime
end

function UMG_ResTrackTab1_C:Release()
  self.TrackPanel = nil
  self.Tracker = nil
  self.Tip = nil
  self.TipTime = nil
end

function UMG_ResTrackTab1_C:OnActive()
  self:SetFrameIntervalText()
  self:DoSwitch()
  self.TrackResults:OnActive(self)
end

function UMG_ResTrackTab1_C:OnDeactive()
  self.TrackResults:OnDeactive()
end

function UMG_ResTrackTab1_C:CacheResultItem(item)
  self.CachedResultItem = item
end

function UMG_ResTrackTab1_C:FillUMGName()
  if self.On then
    return
  end
  if self.CachedResultItem == nil then
    return
  end
  local ReferName = self.CachedResultItem.ReferName
  if nil == ReferName then
    return
  end
  if string.StartsWith(ReferName, "UMG_") then
    if string.EndsWith(ReferName, "_C") then
      ReferName = string.sub(ReferName, 1, #ReferName - 2)
    end
    self.InputText:SetText(ReferName)
  end
end

function UMG_ResTrackTab1_C:DropDown()
  self.IsDropDown = not self.IsDropDown
  if self.IsDropDown then
    self.UMGList:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.UMGList:SetVisibility(UE4.ESlateVisibility.Hidden)
  end
end

function UMG_ResTrackTab1_C:FillCommonUMG(UMGName)
  if nil ~= UMGName and string.StartsWith(UMGName, "UMG") then
    self.InputText:SetText(UMGName)
  end
  if self.IsDropDown then
    self:DropDown()
  end
end

function UMG_ResTrackTab1_C:SetFrameIntervalText()
  self.FrequencyText:SetText(self.FrameInterval)
end

function UMG_ResTrackTab1_C:GetFrameInterval()
  self.FrameInterval = math.max(self.MinFrameInterval, tonumber(self.FrequencyText:GetText()))
  self:SetFrameIntervalText()
end

function UMG_ResTrackTab1_C:Toggle()
  if self.OnlyButtonTriggered then
    self:DoTrack()
  else
    self.On = not self.On
    self:GetFrameInterval()
    if self.On then
      self.TriggerFrameCounter = self.FrameInterval
      self.TrackButtonText:SetText(" Stop  ")
      self.TrackButton:SetBackgroundColor(self.red)
      self.FrequencyText:SetIsReadOnly(true)
    else
      self.TrackButtonText:SetText(" Track ")
      self.TrackButton:SetBackgroundColor(self.green)
      self.FrequencyText:SetIsReadOnly(false)
    end
  end
end

function UMG_ResTrackTab1_C:DoTrack()
  local names = self.InputText:GetText()
  self.Data.Names = names
  self.TrackPanel:TipTime("Track: " .. names)
  local results = self.Tracker:Track(names)
  self.TrackResults:BindResults(results)
end

function UMG_ResTrackTab1_C:SwitchMode()
  if self.On then
    return
  end
  self.OnlyButtonTriggered = not self.OnlyButtonTriggered
  self:DoSwitch()
end

function UMG_ResTrackTab1_C:DoSwitch()
  if not self.OnlyButtonTriggered then
    self.OnlyButtonTriggered = false
    self.ToggleTriggerText:SetText("\232\135\170\229\138\168")
    self.FrequencyText:SetIsReadOnly(false)
    self:GetFrameInterval()
    self.TriggerFrameCounter = self.FrameInterval
    self.TrackPanel:Tip(string.format("\232\135\170\229\138\168\232\167\166\229\143\145\230\168\161\229\188\143,\232\167\166\229\143\145\233\151\180\233\154\148: %d\229\184\167", self.FrameInterval))
  else
    self.OnlyButtonTriggered = true
    self.ToggleTriggerText:SetText("\230\137\139\229\138\168")
    self.FrequencyText:SetIsReadOnly(true)
    self.TrackPanel:Tip("\230\137\139\229\138\168\232\167\166\229\143\145\230\168\161\229\188\143")
  end
  self.On = false
end

function UMG_ResTrackTab1_C:OnTick()
  if self.OnlyButtonTriggered or not self.On then
    return
  end
  if self.TriggerFrameCounter == self.FrameInterval then
    self.TriggerFrameCounter = 0
    self:DoTrack()
  else
    self.TriggerFrameCounter = self.TriggerFrameCounter + 1
  end
end

return UMG_ResTrackTab1_C
