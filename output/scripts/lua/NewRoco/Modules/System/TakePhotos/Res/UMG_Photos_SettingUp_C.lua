local UMG_Photos_SettingUp_C = _G.NRCViewBase:Extend("UMG_Photos_SettingUp_C")

function UMG_Photos_SettingUp_C:OnConstruct()
end

function UMG_Photos_SettingUp_C:OnDestruct()
  self:UnBindInputAction()
end

function UMG_Photos_SettingUp_C:OnActive()
end

function UMG_Photos_SettingUp_C:OnDeactive()
end

function UMG_Photos_SettingUp_C:BindInputAction()
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_PhotoSettingClose")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperAddInputMappingContext, imc, self.depth)
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseFirst")
  UE.UNRCEnhancedInputHelper.BindAction(ia, UE.ETriggerEvent.Triggered, self, "OnPcClose")
  UE4Helper.SetDesiredShowCursor(true, "UMG_Photos_SettingUp_C")
end

function UMG_Photos_SettingUp_C:UnBindInputAction()
  local ia = UE.UNRCEnhancedInputHelper.GetInputAction("IA_CloseFirst")
  UE.UNRCEnhancedInputHelper.UnBindAction(ia)
  local imc = UE.UNRCEnhancedInputHelper.GetInputMappingContext("IMC_PhotoSettingClose")
  _G.NRCModuleManager:DoCmd(_G.EnhancedInputModuleCmd.EnhancedInputHelperRemoveInputMappingContext, imc)
  UE4Helper.ReleaseDesiredShowCursor("UMG_Photos_SettingUp_C")
end

function UMG_Photos_SettingUp_C:OnPcClose()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:UnBindInputAction()
end

function UMG_Photos_SettingUp_C:OnAddEventListener()
end

function UMG_Photos_SettingUp_C:SetCountDownShowList(DataList, SelectIdx)
  self._CountDownList = self.CountDown
  self._CountDownList:ClearSelection()
  self._CountDownList:InitList(DataList)
  self._CountDownList:SelectItemByIndex((SelectIdx or 1) - 1)
end

function UMG_Photos_SettingUp_C:RefreshBurstShootSelection(SelectIdx)
  self._BurstDownList:SelectItemByIndex((SelectIdx or 1) - 1)
end

function UMG_Photos_SettingUp_C:SetBurstShootShowList(DataList, SelectIdx)
  self._BurstDownList = self.CountDown_1
  self._BurstDownList:ClearSelection()
  self._BurstDownList:InitList(DataList)
  self._BurstDownList:SelectItemByIndex((SelectIdx or 1) - 1)
end

return UMG_Photos_SettingUp_C
