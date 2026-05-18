local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Common_NounInterpretationTipsItem_C = Base:Extend("UMG_Common_NounInterpretationTipsItem_C")

function UMG_Common_NounInterpretationTipsItem_C:OnConstruct()
end

function UMG_Common_NounInterpretationTipsItem_C:OnDestruct()
end

function UMG_Common_NounInterpretationTipsItem_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self:SetMainInfo()
end

function UMG_Common_NounInterpretationTipsItem_C:SetMainInfo()
  if self.uiData.bIsUseOriginalText and self.uiData.descText then
    self.textBuffDesc:SetText(self.uiData.descText)
    self.textBuffDesc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  else
    local descId = self.uiData.descId
    local note = _G.DataConfigManager:GetDescNoteConf(descId)
    local descA = note.desc
    descA = string.gsub(descA, "<desc_id=(%d+)>", "")
    descA = string.gsub(descA, "</>", "")
    local text = string.format([[
%s
%s]], string.format("<Orange>\227\128\144%s\227\128\145</>", note.note), descA)
    self.textBuffDesc:SetText(text)
    self.textBuffDesc:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    local linkIds = self:GetHyperLinkIds(note.desc)
    for i = 1, #linkIds do
      local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(linkIds[i]))
      local descB = descNote.desc
      descB = string.gsub(descB, "<desc_id=(%d+)>", "")
      descB = string.gsub(descB, "</>", "")
      local descText = string.format("\227\128\144%s\227\128\145\n%s", descNote.note, descB)
      if 1 == i then
        self.textBuffDesc_1:SetText(descText)
        self.textBuffDesc_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      elseif 2 == i then
        self.textBuffDesc_2:SetText(descText)
        self.textBuffDesc_2:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
  self.OverviewChangeGridView:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.uiData.OverviewChangeInfo and self.OverviewChangeGridView then
    self.OverviewChangeGridView:InitGridView(self.uiData.OverviewChangeInfo)
    self.OverviewChangeGridView:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
  self.DetailsChangeGridView:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if self.uiData.DetailsChangeInfo and self.DetailsChangeGridView then
    self.DetailsChangeGridView:InitGridView(self.uiData.DetailsChangeInfo)
    self.DetailsChangeGridView:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_Common_NounInterpretationTipsItem_C:OnItemSelected(_bSelected)
end

function UMG_Common_NounInterpretationTipsItem_C:OnDeactive()
end

function UMG_Common_NounInterpretationTipsItem_C:GetHyperLinkIds(inputString)
  local pattern = "<desc_id=(%d+)>"
  local ids = {}
  local vis = {}
  for id in string.gmatch(inputString, pattern) do
    if not vis[id] then
      table.insert(ids, id)
      vis[id] = true
      local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(id))
      local childIds = self:GetChildIds(descNote.desc, vis)
      for _, childId in pairs(childIds) do
        table.insert(ids, childId)
      end
    end
  end
  return ids
end

function UMG_Common_NounInterpretationTipsItem_C:GetChildIds(inputString, vis)
  local pattern = "<desc_id=(%d+)>"
  local ids = {}
  for id in string.gmatch(inputString, pattern) do
    if not vis[id] then
      table.insert(ids, id)
      vis[id] = true
      local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(id))
      local childIds = self:GetChildIds(descNote.desc, vis)
      for _, childId in pairs(childIds) do
        table.insert(ids, childId)
      end
    end
  end
  return ids
end

return UMG_Common_NounInterpretationTipsItem_C
