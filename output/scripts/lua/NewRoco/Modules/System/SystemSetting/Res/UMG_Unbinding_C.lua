local UMG_Unbinding_C = _G.NRCPanelBase:Extend("UMG_Unbinding_C")

function UMG_Unbinding_C:OnConstruct()
  self:OnAddEventListener()
end

function UMG_Unbinding_C:OnActive(phone)
  self.moduleData = self.module.data
  local descData = self.moduleData:GetBindPhoneDesc()
  self:DealHyperlinkText(descData.unbind1)
  self.Number:SetText(self.moduleData:GetEncryptPhoneNum(phone))
end

function UMG_Unbinding_C:OnDeactive()
end

function UMG_Unbinding_C:OnAddEventListener()
  self:AddButtonListener(self.Btn2.btnLevelUp, self.OnUnBindPhone)
  self:AddButtonListener(self.PopUp.btnClose.btnClose, self.OnClickCloseBtn)
  self:AddButtonListener(self.PopUp.FullScreen_Close, self.OnClickCloseBtn)
  self.Desc.OnRichTextClick:Add(self, self.BindPhoneTextClick)
end

function UMG_Unbinding_C:OnUnBindPhone()
  _G.NRCAudioManager:PlaySound2DAuto(1002, "UMG_SystemSettingMain_C:OnUnBindPhone")
  local data = {unbind_all_scenes = false}
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenBindPhonePanel, self.moduleData.BindMobilePhoneEnum.UNBIND, data)
  self:DoClose()
end

function UMG_Unbinding_C:OnClickCloseBtn()
  self:DoClose()
end

function UMG_Unbinding_C:DealHyperlinkText(str)
  local count = 0
  local result = str:gsub("&({.-})&", function(match)
    local linkText = match:match("\"text\":%s*\"([^\"]+)\"")
    if linkText then
      count = count + 1
      return "<a id=\"" .. linkText .. "\">" .. tostring(count) .. "</>"
    end
    return match
  end)
  self.Desc:SetText(result)
end

function UMG_Unbinding_C:BindPhoneTextClick(id)
  local flag = false
  if "2" == id then
    flag = true
  end
  local data = {unbind_all_scenes = flag}
  _G.NRCModuleManager:DoCmd(_G.SystemSettingModuleCmd.OpenBindPhonePanel, self.moduleData.BindMobilePhoneEnum.UNBIND, data)
  self:DoClose()
end

return UMG_Unbinding_C
