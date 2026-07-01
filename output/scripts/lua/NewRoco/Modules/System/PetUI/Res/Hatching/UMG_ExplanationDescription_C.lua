local DummyTable = require("Common.DummyTable")
local UMG_ExplanationDescription_C = _G.NRCPanelBase:Extend("UMG_ExplanationDescription_C")

function UMG_ExplanationDescription_C:OnConstruct()
  self:SetChildViews(self.PopUp)
end

function UMG_ExplanationDescription_C:OnActive()
  self:LoadAnimation(0)
  self:OnAddEventListener()
  self:SetCommonPopUpInfo(self.PopUp)
  self:UpdateView()
end

function UMG_ExplanationDescription_C:OnDeactive()
end

function UMG_ExplanationDescription_C:OnAddEventListener()
end

function UMG_ExplanationDescription_C:BindInputAction()
  local mappingContext = self:AddInputMappingContext("IMC_CommonCloseUI")
  if mappingContext then
    mappingContext:BindAction("IA_CloseUI", self, "OnPcClose2")
  end
end

function UMG_ExplanationDescription_C:UnBindInputAction()
  local mappingContext = self:GetInputMappingContext("IMC_CommonCloseUI")
  if mappingContext then
    mappingContext:UnBindAction("IA_CloseUI")
  end
  self:RemoveInputMappingContext("IMC_CommonCloseUI")
end

function UMG_ExplanationDescription_C:SetCommonPopUpInfo(PopUp)
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.FullScreen_Close = true
  CommonPopUpData.Call = self
  CommonPopUpData.ClosePanelHandler = self.TryToClosePanel
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  PopUp:SetPanelInfo(CommonPopUpData)
end

function UMG_ExplanationDescription_C:UpdateView()
  local contentStr = LuaText.egg_type_explain
  self.ContentText:SetText(contentStr)
  if self.NRCText_Icon then
    self.NRCText_Icon:SetText(LuaText.egg_type_explain_2)
  end
  if self.NRCText_type then
    self.NRCText_type:SetText(LuaText.egg_type_explain_3)
  end
  if self.NRCText_Range then
    self.NRCText_Range:SetText(LuaText.egg_type_explain_4)
  end
  local ItemDataList = {}
  local allEggTypeConfigs = DataConfigManager:GetTable(DataConfigManager.ConfigTableId.EGG_TYPE_CONF):GetAllDatas()
  for id, config in pairs(allEggTypeConfigs or DummyTable) do
    if config and config.name then
      local eggTypeItemData = self:CreateEggTypeItemData(id, config)
      if eggTypeItemData then
        table.insert(ItemDataList, eggTypeItemData)
      end
    end
  end
  table.sort(ItemDataList, function(a, b)
    if a and b and a.eggTypeConfig and b.eggTypeConfig and a.eggTypeConfig.notice_display_order and b.eggTypeConfig.notice_display_order and a.eggTypeConfig.notice_display_order < b.eggTypeConfig.notice_display_order then
      return true
    end
    return false
  end)
  self.GridView_Item:InitGridView(ItemDataList)
end

function UMG_ExplanationDescription_C:CreateEggTypeItemData(id, config)
  local eggTypeItemData = {eggTypeConfId = id, eggTypeConfig = config}
  return eggTypeItemData
end

function UMG_ExplanationDescription_C:OnAnimationFinished(anim)
  if anim == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

function UMG_ExplanationDescription_C:OnPcClose2()
  self:TryToClosePanel()
end

function UMG_ExplanationDescription_C:TryToClosePanel()
  self:LoadAnimation(2)
end

return UMG_ExplanationDescription_C
