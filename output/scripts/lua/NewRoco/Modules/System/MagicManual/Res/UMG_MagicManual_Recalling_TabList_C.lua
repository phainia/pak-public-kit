local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_MagicManual_Recalling_TabList_C = Base:Extend("UMG_MagicManual_Recalling_TabList_C")

function UMG_MagicManual_Recalling_TabList_C:OnConstruct()
end

function UMG_MagicManual_Recalling_TabList_C:OnDestruct()
end

function UMG_MagicManual_Recalling_TabList_C:OnItemUpdate(_data, datalist, index)
  self.data = _data
  self.index = index
  self.tabListConf = _G.DataConfigManager:GetReacallListConf(self.data.id)
  if not self.tabListConf then
    Log.Error("UMG_MagicManual_Recalling_TabList_C:OnItemUpdate \229\183\166\228\190\167Tab\230\140\137\233\146\174\229\136\157\229\167\139\229\140\150\229\164\177\232\180\165\239\188\140\229\175\185\229\186\148\231\154\132RECALL_LIST_CONF id %s\230\178\161\230\156\137\229\156\168\232\161\168\228\184\173\230\137\190\229\136\176\239\188\140\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168", self.data.id)
    return
  end
  self:OnAddEventListener()
  self:_InitItem()
end

function UMG_MagicManual_Recalling_TabList_C:OnAddEventListener()
end

function UMG_MagicManual_Recalling_TabList_C:_InitItem()
  self.Selected:SetRenderOpacity(0)
  self.CanvasPanel_32:SetRenderOpacity(1)
  if self.Title then
    self.Title:SetText(self.tabListConf.reacall_list_name)
    self.Title_1:SetText(self.tabListConf.reacall_list_name)
  end
  if self.NRCImage_38 then
    self.NRCImage_38:SetPath(self.tabListConf.reacall_list_picture)
    self.NRCImage_2:SetPath(self.tabListConf.reacall_list_picture)
  end
end

function UMG_MagicManual_Recalling_TabList_C:OnItemSelected(_bSelected)
  if _bSelected then
    _G.NRCPanelBase:DelayFrames(1, function()
      self:PlaySelect()
    end)
    if self.data.parent then
      self.data.parent:OnClickRecallTabListItem(self.index)
    end
  else
    _G.NRCPanelBase:DelayFrames(1, function()
      self:PlayUnselect()
    end)
  end
end

function UMG_MagicManual_Recalling_TabList_C:OnDeactive()
end

function UMG_MagicManual_Recalling_TabList_C:OnAnimationFinished(Anim)
  if Anim == self.Select then
    self.CanvasPanel_32:SetRenderOpacity(0)
    self.Selected:SetRenderOpacity(1)
  end
  if Anim == self.Unselect then
    self.CanvasPanel_32:SetRenderOpacity(1)
    self.Selected:SetRenderOpacity(0)
  end
end

function UMG_MagicManual_Recalling_TabList_C:PlaySelect()
  self.CanvasPanel_32:SetRenderOpacity(1)
  self.Selected:SetRenderOpacity(1)
  self:StopAllAnimations()
  self:PlayAnimation(self.Select)
end

function UMG_MagicManual_Recalling_TabList_C:PlayUnselect()
  self.CanvasPanel_32:SetRenderOpacity(1)
  self.Selected:SetRenderOpacity(1)
  self:StopAllAnimations()
  self:PlayAnimation(self.Unselect)
end

return UMG_MagicManual_Recalling_TabList_C
