local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_PlayDetails_Item_C = Base:Extend("UMG_PlayDetails_Item_C")

function UMG_PlayDetails_Item_C:OnConstruct()
end

function UMG_PlayDetails_Item_C:OnDestruct()
end

function UMG_PlayDetails_Item_C:OnItemUpdate(_data, datalist, index)
  self.descText = {}
  local BattleRuleConf = _G.DataConfigManager:GetBattleRuleConf(_data)
  self.Desc:SetText(BattleRuleConf.desc)
end

function UMG_PlayDetails_Item_C:ShowDescRightPanel(id)
  self:OnDescTextClicked(id)
end

function UMG_PlayDetails_Item_C:OnDescTextClicked(id)
  if self.descText[1] then
    for i = 1, #self.descText do
      if self.descText[i] == id then
        return
      else
        table.insert(self.descText, id)
      end
    end
  else
    table.insert(self.descText, id)
  end
  local descNote = _G.DataConfigManager:GetDescNoteConf(tonumber(id))
  local descText = string.format("\227\128\144%s\227\128\145\n%s", descNote.note, descNote.desc)
  _G.NRCModuleManager:DoCmd(MagicManualModuleCmd.OpenDescTextPanel, descText)
end

function UMG_PlayDetails_Item_C:OnItemSelected(_bSelected)
end

function UMG_PlayDetails_Item_C:OnDeactive()
end

return UMG_PlayDetails_Item_C
