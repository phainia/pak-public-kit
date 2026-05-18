local UMG_Tab1Template_C = _G.NRCPanelBase:Extend("UMG_Tab1Template_C")

function UMG_Tab1Template_C:OnConstruct()
  Log.Debug("UMG_Tab1Template_C:OnConstruct")
  self.uidata = nil
end

function UMG_Tab1Template_C:SetNRCText(text)
  self.NRCText_1:SetText(text)
end

function UMG_Tab1Template_C:SetNRCImagePath(path)
  self.NRCImage_0:SetPath(path)
end

function UMG_Tab1Template_C:SetTextScrollViewText(text)
  self.BP_NRCTextScrollView:InitText(text)
end

function UMG_Tab1Template_C:SetSwitcherIndex(index)
  self.NRCSwitcher0:SetActiveWidgetIndex(index)
end

function UMG_Tab1Template_C:SetDropDownListItemNum(index)
  self.UMG_NRCDropDownList:SelectItem(index)
end

function UMG_Tab1Template_C:AddListener()
  self.NRCCheckBox_11:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.NRCCheckBox_12:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.NRCCheckBox_13:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.NRCCheckBox_21:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.NRCCheckBox_22:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
  self.NRCCheckBox_23:BindLuaCallBack({
    self,
    self.OnToggleGroupChanged
  }, {
    self,
    self.OnCheckBoxCondition
  })
end

function UMG_Tab1Template_C:OnToggleGroupChanged(GroupId, CheckBoxName)
  if "yajiji1" == CheckBoxName then
    self:SetTextScrollViewText("\233\184\173\229\144\137\229\144\137")
  elseif "dimo1" == CheckBoxName then
    self:SetTextScrollViewText("\232\191\170\232\142\171")
  elseif "shuilanlan1" == CheckBoxName then
    self:SetTextScrollViewText("\230\176\180\232\147\157\232\147\157")
  elseif "yajiji2" == CheckBoxName then
    self:SetNRCImagePath("PaperSprite'/Game/NewRoco/Modules/System/Common/Icon/UIHeadIcon/Frames/3012_png.3012_png'")
  elseif "dimo2" == CheckBoxName then
    self:SetNRCImagePath("PaperSprite'/Game/NewRoco/Modules/System/Common/Icon/UIHeadIcon/Frames/3004_png.3004_png'")
  elseif "shuilanlan2" == CheckBoxName then
    self:SetNRCImagePath("PaperSprite'/Game/NewRoco/Modules/System/Common/Icon/UIHeadIcon/Frames/3002_png.3002_png'")
  end
end

function UMG_Tab1Template_C:OnCheckBoxCondition(GroupId, CheckBoxName, IsClickable)
end

function UMG_Tab1Template_C:OnDestruct()
  Log.Debug("UMG_Tab1Template_C:OnDestruct")
end

function UMG_Tab1Template_C:OnActive()
  self:AddListener()
  self.uidata = {
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#cacaca"},
    {key = "Yuzuru", color = "#b9ffb0"},
    {key = "HANYU", color = "#b0ddff"},
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#b9ffb0"},
    {key = "Yuzuru", color = "#cacaca"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#b0ddff"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#cacaca"},
    {key = "HANYU", color = "#ffffff"},
    {key = "Yuzuru", color = "#b9ffb0"},
    {key = "HANYU", color = "#cacaca"},
    {key = "Yuzuru", color = "#ffffff"},
    {key = "HANYU", color = "#b0ddff"},
    {key = "Yuzuru", color = "#b9ffb0"}
  }
  self.UMG_NRCDropDownList:OnActive(self.uidata)
  self:SetNRCText("NRCText\231\164\186\228\190\139\239\188\140Editor\228\184\173\229\143\175\228\187\165\229\138\160\232\189\189\229\146\140\228\191\174\230\148\185\230\168\161\230\157\191")
  self:SetNRCImagePath("PaperSprite'/Game/NewRoco/Modules/System/Common/Icon/BagItem/Frames/100007_png.100007_png'")
  self:SetTextScrollViewText("\229\150\156\230\172\162\231\157\161\232\167\137\239\188\140\230\142\165\232\191\145\233\184\173\229\144\137\229\144\137\231\154\132\228\186\186\233\131\189\228\188\154\231\170\129\231\132\182\230\132\159\229\143\151\229\136\176\230\151\160\229\189\162\231\154\132\233\184\173\229\138\155\227\128\130\231\134\159\230\130\137\229\141\180\229\143\136\231\165\158\231\167\152\231\154\132\228\188\153\228\188\180\227\128\130\231\137\185\230\174\138\233\173\148\229\138\155\229\189\177\229\147\141\228\184\139\239\188\140\228\188\154\230\148\185\229\143\152\232\135\170\232\186\171\231\154\132\232\186\171\228\189\147\230\158\132\233\128\160\227\128\130\229\150\156\230\172\162\230\188\130\230\181\174\229\156\168\230\176\180\228\184\173\227\128\130\230\159\148\232\189\175\231\154\132\232\186\171\228\189\147\229\175\185\233\173\148\230\179\149\232\131\189\233\135\143\230\179\162\229\138\168\230\156\137\231\157\128\230\155\180\231\129\181\230\149\143\231\154\132\230\132\159\231\159\165\227\128\130")
  self:SetSwitcherIndex(2)
  self:SetDropDownListItemNum(1)
end

function UMG_Tab1Template_C:Test()
  Log.Error("\230\181\139\232\175\149\228\184\128\228\184\139\230\152\175\229\144\166\232\131\189\232\176\131\231\148\168\229\136\176")
end

function UMG_Tab1Template_C:OnDeactive()
end

return UMG_Tab1Template_C
