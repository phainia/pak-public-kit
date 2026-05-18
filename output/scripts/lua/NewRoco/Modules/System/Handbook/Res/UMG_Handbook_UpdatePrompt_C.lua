local UMG_Handbook_UpdatePrompt_C = _G.NRCPanelBase:Extend("UMG_Handbook_UpdatePrompt_C")

function UMG_Handbook_UpdatePrompt_C:OnActive(arg)
  self.IconPath = {
    "PaperSprite'/Game/NewRoco/Modules/System/Handbook/Raw/Common/Images/Frames/img_faxian1_png.img_faxian1_png'",
    "PaperSprite'/Game/NewRoco/Modules/System/MainUI/Raw/Atlas/MainUI/Frames/icon_qiu_png.icon_qiu_png'"
  }
  self.ShowTime = _G.DataConfigManager:GetGlobalConfigByKeyType("handbook_renew_hint_time", _G.DataConfigManager.ConfigTableId.PET_GLOBAL_CONFIG).num / 1000
  self:InitUI(arg)
end

function UMG_Handbook_UpdatePrompt_C:OnDeactive()
end

function UMG_Handbook_UpdatePrompt_C:InitUI(arg)
  local petInfo = _G.DataModelMgr.PlayerDataModel:GetPlayerPetInfo()
  if not petInfo then
    self:CloseUI()
    return
  end
  local number = petInfo.handbook.collect_coll_num
  local type = arg or 1
  if 1 == type then
    number = petInfo.handbook.found_coll_num
    _G.BattleManager.IsMeetNewPet = false
  end
  self.Ball:SetPath(self.IconPath[type])
  self.Quantity:SetText(tostring(number))
  if self.delayId then
    _G.DelayManager:CancelDelayById(self.delayId)
    self.delayId = nil
  end
  self.delayId = _G.DelayManager:DelaySeconds(self.ShowTime, self.CloseUI, self)
end

function UMG_Handbook_UpdatePrompt_C:CloseUI()
  self.delayId = nil
  self:DoClose()
end

return UMG_Handbook_UpdatePrompt_C
