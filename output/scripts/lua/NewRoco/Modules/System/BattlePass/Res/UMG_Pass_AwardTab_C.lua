local BattlePassModuleEvent = require("NewRoco.Modules.System.BattlePass.BattlePassModuleEvent")
local UMG_Pass_AwardTab_C = _G.NRCViewBase:Extend("UMG_Pass_AwardTab_C")

function UMG_Pass_AwardTab_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Pass_AwardTab_C:OnAddEventListener()
  self:AddButtonListener(self.btnLevelUp, self.OnClickbtnLevelUp)
  _G.NRCEventCenter:RegisterEvent("UMG_Pass_AwardTab_C", self, BattlePassModuleEvent.UpdateActiveTableView, self.UpdateTable)
end

function UMG_Pass_AwardTab_C:OnActive(index, name)
  self.rewardIconDefaultPath = "PaperSprite'/Game/NewRoco/Modules/System/BattlePass/Raw/Frames/img_kuili_png.img_kuili_png'"
  self.rewardIconSelectPath = "PaperSprite'/Game/NewRoco/Modules/System/BattlePass/Raw/Frames/img_kuili1_png.img_kuili1_png'"
  self.activeIconDefaultPath = "PaperSprite'/Game/NewRoco/Modules/System/BattlePass/Raw/Frames/img_huodong1_png.img_huodong1_png'"
  self.activeIconSelectPath = "PaperSprite'/Game/NewRoco/Modules/System/BattlePass/Raw/Frames/img_huodong_png.img_huodong_png'"
  self.tabIndex = index
  if 0 == self.tabIndex then
    self.Ordinary:SetPath(self.rewardIconDefaultPath)
    self.PitchOn:SetPath(self.rewardIconSelectPath)
  elseif 1 == self.tabIndex then
    self.Ordinary:SetPath(self.activeIconDefaultPath)
    self.PitchOn:SetPath(self.activeIconSelectPath)
  end
  self:DefentIcon(index)
end

function UMG_Pass_AwardTab_C:DefentIcon(index)
end

function UMG_Pass_AwardTab_C:SelectIcon(index)
end

function UMG_Pass_AwardTab_C:UnSelectIcon(index)
end

function UMG_Pass_AwardTab_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, BattlePassModuleEvent.UpdateActiveTableView, self.UpdateTable)
end

function UMG_Pass_AwardTab_C:OnDeactive()
end

function UMG_Pass_AwardTab_C:UpdateTable(index)
  self:StopAllAnimations()
  if index == self.tabIndex then
    self:SelectIcon(self.tabIndex)
    self:PlayAnimation(self.In)
  else
    self:UnSelectIcon(self.tabIndex)
    self:PlayAnimation(self.Out)
  end
end

function UMG_Pass_AwardTab_C:OnClickbtnLevelUp()
  local curIndex = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.GetActiveSelectTabIndex)
  local isClick = _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.OffActiveSelectTabIndex)
  if false == isClick then
    return
  end
  if self.tabIndex == curIndex then
    return
  end
  local panelName = "BattlePassAwardMain"
  local moduleName = "BattlePassModule"
  local isSelectBtn = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetIsSelectBtn, moduleName, panelName)
  if isSelectBtn then
    return
  end
  local touchReasonType = _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.GetPanelSelectBtnReason, panelName).TAB
  _G.NRCModuleManager:DoCmd(MultiTouchModuleCmd.LockIsSelectBtn, moduleName, panelName, touchReasonType)
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetActiveSelectTabIndex, self.tabIndex)
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.UpdateActiveTableView, self.tabIndex)
end

function UMG_Pass_AwardTab_C:OnTriggerFun()
  _G.NRCModuleManager:DoCmd(_G.BattlePassModuleCmd.SetActiveSelectTabIndex, self.tabIndex)
  _G.NRCEventCenter:DispatchEvent(BattlePassModuleEvent.UpdateActiveTableView, self.tabIndex)
end

return UMG_Pass_AwardTab_C
