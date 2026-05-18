local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local MusicCollectionModuleEvent = require("NewRoco.Modules.System.MusicCollection.MusicCollectionModuleEvent")
local UMG_LeftVerticalTab_C = Base:Extend("UMG_LeftVerticalTab_C")

function UMG_LeftVerticalTab_C:OnConstruct()
end

function UMG_LeftVerticalTab_C:OnDestruct()
end

function UMG_LeftVerticalTab_C:OnItemUpdate(_data, datalist, index)
  self.SelectLoopTimer = 8
  self.uiData = _data
  self.index = index
  local musicCollectionModule = _G.NRCModuleManager:GetModule("MusicCollectionModule")
  local musicCollectionPanel = musicCollectionModule:GetPanel("MusicCollectionPanel")
  if musicCollectionPanel then
    if musicCollectionPanel.OpenType == "MagicMessage" then
      self.redPointNew:SetupKey(0)
    else
      self.redPointNew:SetupKey(292, {
        self.uiData.TypeEnum
      })
    end
  end
  local SelectIcon, NormalIcon = self:GetTabIconPath()
  self.selectImg:SetPath(SelectIcon)
  self.icon:SetPath(NormalIcon)
end

function UMG_LeftVerticalTab_C:GetTabIconPath()
  local Path1 = "PaperSprite'/Game/NewRoco/Modules/System/MusicCollection/Raw/Frames/%s1_png.%s1_png'"
  local Path2 = "PaperSprite'/Game/NewRoco/Modules/System/MusicCollection/Raw/Frames/%s2_png.%s2_png'"
  local musicTypeConf = _G.DataConfigManager:GetMusicTypeConf(self.uiData.TypeEnum)
  return string.format(Path1, musicTypeConf.icon_path, musicTypeConf.icon_path), string.format(Path2, musicTypeConf.icon_path, musicTypeConf.icon_path)
end

function UMG_LeftVerticalTab_C:OnItemSelected(_bSelected)
  self:StopAllAnimations()
  self:CancelPlayLoopAnim()
  if _bSelected then
    self:PlayAnimation(self.change1)
    if self.uiData then
      _G.NRCModuleManager:GetModule("MusicCollectionModule"):DispatchEvent(MusicCollectionModuleEvent.ChangeTabType, self.index, self.uiData.Type, self.uiData.List)
    else
      Log.Warning("UMG_LeftVerticalTab_C uiData is nil")
    end
  else
    self:PlayAnimation(self.change2)
  end
end

function UMG_LeftVerticalTab_C:PlayLoopAnim()
  self:PlayAnimation(self.select_loop)
end

function UMG_LeftVerticalTab_C:OnDeactive()
end

function UMG_LeftVerticalTab_C:StartPlayLoopAnim()
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  self:PlayAnimation(self.select_loop)
  self.loopFuncID = nil
end

function UMG_LeftVerticalTab_C:CancelPlayLoopAnim()
  if self.loopFuncID then
    DelayManager:CancelDelayById(self.loopFuncID)
    self.loopFuncID = nil
  end
end

function UMG_LeftVerticalTab_C:OnAnimationFinished(anim)
  if anim == self.change1 then
    self:PlayAnimation(self.select_loop)
  elseif anim == self.select_loop then
    self:CancelPlayLoopAnim()
    self.loopFuncID = DelayManager:DelaySeconds(self.SelectLoopTimer, self.StartPlayLoopAnim, self)
  end
end

function UMG_LeftVerticalTab_C:OnDestruct()
  self:CancelPlayLoopAnim()
end

return UMG_LeftVerticalTab_C
