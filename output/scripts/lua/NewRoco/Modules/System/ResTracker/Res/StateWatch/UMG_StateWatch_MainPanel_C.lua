local UMG_StateWatch_MainPanel_C = _G.NRCPanelBase:Extend("UMG_StateWatch_MainPanel_C")

function UMG_StateWatch_MainPanel_C:OnConstruct()
  self:SetChildViews(self.UMG_TUIList)
end

function UMG_StateWatch_MainPanel_C:OnActive()
  self:SetData()
  self:AddButtonListener(self.CloseButton, self.DoClose)
  self:AddButtonListener(self.HideButton, self.Hide)
  self:AddButtonListener(self.ShowButton, self.Show)
end

function UMG_StateWatch_MainPanel_C:SetData()
  self.data = {
    [1] = {
      text = "\231\172\172\228\184\128\232\161\140",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [2] = {
      text = "\231\172\172\228\186\140\232\161\140",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [3] = {
      text = "\231\172\172\228\184\137\232\161\140",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [4] = {
      text = "\231\172\172\229\155\155\232\161\140",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    }
  }
  self.data1 = {
    [1] = {
      text = "\231\172\172\228\184\128\229\136\151",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [2] = {
      text = "\231\172\172\228\186\140\229\136\151",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [3] = {
      text = "\231\172\172\228\184\137\229\136\151",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    },
    [4] = {
      text = "\231\172\172\229\155\155\229\136\151",
      text1 = "12345",
      text3 = "Test",
      text4 = "12347"
    }
  }
  self.TUIResults:BindData(self.data, self.data1)
end

function UMG_StateWatch_MainPanel_C:Hide()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Hidden)
end

function UMG_StateWatch_MainPanel_C:Show()
  self.HideButton:SetVisibility(UE4.ESlateVisibility.Visible)
  self.ShowButton:SetVisibility(UE4.ESlateVisibility.Hidden)
  self.HidenArea:SetVisibility(UE4.ESlateVisibility.Visible)
end

function UMG_StateWatch_MainPanel_C:OnDeactive()
end

function UMG_StateWatch_MainPanel_C:OnAddEventListener()
end

return UMG_StateWatch_MainPanel_C
