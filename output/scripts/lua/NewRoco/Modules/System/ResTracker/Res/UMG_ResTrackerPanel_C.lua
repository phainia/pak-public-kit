require("UnLuaEx")
local JsonUtils = require("Common.JsonUtils")
local UMG_ResTrackerPanel_C = _G.NRCPanelBase:Extend("UMG_ResTrackerPanel_C")

function UMG_ResTrackerPanel_C:OnConstruct()
  self:AddButtonListener(self.CloseButton, self.DoClose)
  self:AddButtonListener(self.TrackButton, self.Toggle)
  self:AddButtonListener(self.ExportCurrentButton, self.ExportCurrentResult)
  self:AddButtonListener(self.ModeButton, self.SwitchMode)
  self:AddButtonListener(self.HideButton, self.Hide)
  self:AddButtonListener(self.ShowButton, self.Show)
  self.UMGInfoText:InitText("~")
  self.OnlyButtonTriggered = true
  self.FrameInterval = 500
  self.MinFrameInterval = 100
  self.TriggerFrameCounter = self.FrameInterval
  self.On = false
  self.IsHiding = false
  self.Data = {}
  self.ExportCounter = 0
  self.green = UE4.UNRCStatics.HexToSlateColor("#3DFF55FF")
  self.red = UE4.UNRCStatics.HexToSlateColor("#FF0000FF")
end

function UMG_ResTrackerPanel_C:OnActive()
  self.Tracker = UE4.ReferenceTracker()
  self:Show()
  self.FrameInterval = math.max(self.MinFrameInterval, self.FrameInterval)
  self:SetFrameIntervalText()
  self.OnlyButtonTriggered = not self.OnlyButtonTriggered
  self:SwitchMode()
  self.On = true
  self:Toggle()
end

function UMG_ResTrackerPanel_C:OnF(...)
  Log.Error("OnFinish Test")
end

function UMG_ResTrackerPanel_C:OnDeactive()
  self.Tracker:Release()
end

function UMG_ResTrackerPanel_C:OnDestruct()
  self:RemoveAllButtonListener()
end

function UMG_ResTrackerPanel_C:Tip(message)
  self.LogText:SetText(message)
end

function UMG_ResTrackerPanel_C:TipTime(message)
  self:Tip(os.date("%Y-%m-%d %H:%M:%S") .. "  " .. message)
end

function UMG_ResTrackerPanel_C:Toggle()
  self.On = not self.On
  if self.OnlyButtonTriggered then
    if self.On then
      self:DoTrack()
      self.On = false
    end
  else
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

function UMG_ResTrackerPanel_C:SetFrameIntervalText()
  self.FrequencyText:SetText(self.FrameInterval)
end

function UMG_ResTrackerPanel_C:GetFrameInterval()
  self.FrameInterval = math.max(self.MinFrameInterval, tonumber(self.FrequencyText:GetText()))
  self:SetFrameIntervalText()
end

function UMG_ResTrackerPanel_C:SwitchMode()
  if self.On then
    return
  end
  if self.OnlyButtonTriggered then
    self.OnlyButtonTriggered = false
    self.ToggleTriggerText:SetText("\232\135\170\229\138\168")
    self.FrequencyText:SetIsReadOnly(false)
    self:GetFrameInterval()
    self.TriggerFrameCounter = self.FrameInterval
    self:Tip(string.format("\229\136\135\230\141\162\232\135\179\232\135\170\229\138\168\232\167\166\229\143\145\230\168\161\229\188\143,\232\167\166\229\143\145\233\151\180\233\154\148: %d\229\184\167", self.FrameInterval))
  else
    self.OnlyButtonTriggered = true
    self.ToggleTriggerText:SetText("\230\137\139\229\138\168")
    self.FrequencyText:SetIsReadOnly(true)
    self:Tip("\229\136\135\230\141\162\232\135\179\230\137\139\229\138\168\232\167\166\229\143\145\230\168\161\229\188\143")
  end
end

function UMG_ResTrackerPanel_C:OnTick()
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

function UMG_ResTrackerPanel_C:DoTrack()
  local names = self.InputText:GetText()
  self.Data.Names = names
  self:TipTime("Track: " .. names)
  local res = self.Tracker:Track(names)
  self:FillInfo()
  for i = 1, res:Length() do
    Log.Debug(i)
    local RefResult = res:Get(i)
    Log.Debug("Result\231\155\174\230\160\135: " .. RefResult.AssetObject:GetName())
    local Chains = RefResult.Chains
    for j = 1, Chains:Length() do
      local str = ""
      local Chain = Chains:Get(j)
      for k = 0, Chain:Num() - 1 do
        local Node = Chain:GetNode(k)
        if Node.Object:IsAsset() then
          str = str .. string.format("%s[%s] <- ", Node.Object:GetName(), Node.Object:GetClassName())
        end
      end
      Log.Debug(str)
    end
  end
end

function UMG_ResTrackerPanel_C:FillInfo()
  if self.Tracker == nil then
    return
  end
  self.Data.UMGInfo = self.Tracker:GetUMGInfo()
  self.Data.UMGDetail = self.Tracker:GetUMGDetail()
  self.Data.AssetInfo = self.Tracker:GetAssetInfo()
  self.Data.AssetDetail = self.Tracker:GetAssetDetail()
  self.UMGInfoText:InitText(self.Data.UMGInfo)
  self.UMGDetailText:SetText(self.Data.UMGDetail)
  self.AssetInfoText:SetText(self.Data.AssetInfo)
  self.AssetDetailText:SetText(self.Data.AssetDetail)
end

function UMG_ResTrackerPanel_C:Hide()
  self.IsHiding = true
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_ResTrackerPanel_C:Show()
  self.IsHiding = false
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_ResTrackerPanel_C:ExportCurrentResult()
  local Filename = "ResTrack/TrackResult_" .. os.date("%Y_%m_%d_%H_%M_%S") .. "_" .. self.ExportCounter
  self.ExportCounter = self.ExportCounter + 1
  JsonUtils.DumpSaved(Filename, self.Data)
end

return UMG_ResTrackerPanel_C
