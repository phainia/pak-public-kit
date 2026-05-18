local UMG_NpcInfo_FashionMall_C = _G.NRCPanelBase:Extend("UMG_NpcInfo_FashionMall_C")

function UMG_NpcInfo_FashionMall_C:OnActive()
end

function UMG_NpcInfo_FashionMall_C:OnDeactive()
end

function UMG_NpcInfo_FashionMall_C:OnAddEventListener()
end

function UMG_NpcInfo_FashionMall_C:OnConstruct()
end

function UMG_NpcInfo_FashionMall_C:OnDestruct()
end

function UMG_NpcInfo_FashionMall_C:OnEnable(describeText, title, desc, headIcon, showData)
  if string.IsNilOrEmpty(describeText) then
    self.PikaActVerPanel:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.PikaActVerPanel:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.describe:SetText(describeText)
  self.npcName_4:SetText(title)
  self.npcDesc_3:SetText(desc)
  self.headIcon_1:SetPath(headIcon)
  self.NRCGridView_89:InitGridView(showData)
end

function UMG_NpcInfo_FashionMall_C:OnDisable()
end

return UMG_NpcInfo_FashionMall_C
