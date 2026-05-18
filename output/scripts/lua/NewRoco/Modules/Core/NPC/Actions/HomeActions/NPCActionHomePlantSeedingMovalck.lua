local NPCActionBase = require("NewRoco.Modules.Core.NPC.Actions.NPCActionBase")
local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local FarmUtils = require("NewRoco.Modules.System.Farm.FarmUtils")
local Base = NPCActionBase
local NPCActionHomePlantSeedingMovalck = Base:Extend("NPCActionHomePlantSeedingMovalck")

function NPCActionHomePlantSeedingMovalck:Ctor(Owner, Config, Info)
  Base.Ctor(self, Owner, Config, Info)
  self.plantName = nil
  self.landInfo = nil
  self.isFinish = false
end

function NPCActionHomePlantSeedingMovalck:Execute()
  Base.Execute(self)
  self.isFinish = false
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.RemindSwitch = 0
  CommonPopUpData.ContentText = self:OnGetTimeContext()
  CommonPopUpData.TitleText = _G.LuaText.clear_plant_title
  CommonPopUpData.Btn_LeftText = _G.LuaText.clear_plant_btn_cancel
  CommonPopUpData.Btn_RightText = _G.LuaText.clear_plant_btn_affirm
  CommonPopUpData.Call = self
  CommonPopUpData.Btn_RightHandler = self.OnAffirm
  CommonPopUpData.Btn_LeftHandler = self.OnCancel
  CommonPopUpData.Btn_CloseHandler = self.OnCancel
  CommonPopUpData.ClosePanelHandler = self.OnCancel
  CommonPopUpData.OnTickHandler = self.OnTickUMG
  _G.NRCAudioManager:PlaySound2DAuto(41400009, "NPCActionHomePlantSeedingMovalck:Execute")
  _G.NRCModeManager:DoCmd(_G.CommonPopUpModuleCmd.OpenRemindPanel, CommonPopUpData)
end

function NPCActionHomePlantSeedingMovalck:OnAffirm()
  self.landInfo = self.Owner:GetOwnerFarmlandInfo()
  if not self.landInfo then
    self:OnCancel()
    return
  end
  if self.landInfo.plant_rip_time <= _G.ZoneServer:GetServerTime() / 1000 then
    self:OnCancel()
    return
  end
  self.isFinish = true
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "NPCActionHomePlantSeedingMovalck:OnAffirm")
  self:Finish(true, nil, "1")
end

function NPCActionHomePlantSeedingMovalck:OnCancel()
  self.isFinish = true
  if self.Owner then
    self:Finish(false, nil, "0")
  end
  _G.NRCAudioManager:PlaySound2DAuto(41400010, "NPCActionHomePlantSeedingMovalck:OnAffirm")
end

function NPCActionHomePlantSeedingMovalck:OnGetTimeContext()
  self.landInfo = self.Owner:GetOwnerFarmlandInfo()
  if not self.plantName then
    self.plantName = FarmUtils.GetPlantName(self.landInfo.plant_seed_id, self.landInfo.plant_tab_id)
  end
  local endTime = self.landInfo.plant_rip_time
  local nowTimePoke = math.floor(_G.ZoneServer:GetServerTime() / 1000)
  local remainTime = endTime - nowTimePoke
  local context = _G.LuaText.clear_plant_confirm_text
  local time = FarmUtils.GetTxtByTime(remainTime)
  return string.format(context, self.plantName, time)
end

function NPCActionHomePlantSeedingMovalck:OnTickUMG(CommonPopUpData, umg)
  if self.isFinish then
    return
  end
  self.landInfo = self.Owner:GetOwnerFarmlandInfo()
  if not self.landInfo then
    umg:OnBtnClose()
    return
  end
  if self.landInfo.plant_rip_time <= _G.ZoneServer:GetServerTime() / 1000 then
    umg:OnBtnClose()
    return
  end
  CommonPopUpData.ContentText = self:OnGetTimeContext()
  umg:UpdateContext()
end

return NPCActionHomePlantSeedingMovalck
