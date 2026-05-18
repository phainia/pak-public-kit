local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_Friend_Expression_Item_C = Base:Extend("UMG_Friend_Expression_Item_C")

function UMG_Friend_Expression_Item_C:OnConstruct()
end

function UMG_Friend_Expression_Item_C:OnDestruct()
end

function UMG_Friend_Expression_Item_C:OnItemUpdate(_data, datalist, index)
  self.uiData = _data
  self.Icon_kong:SetVisibility(UE4.ESlateVisibility.Hidden)
  local EmoConf = _G.DataConfigManager:GetChatEmojiConf(_data)
  self.Icon:SetPath(self:GetEmoPath(EmoConf.emoji_use_icon))
  self.Name:SetText(EmoConf.emoji_resource_name)
  self.RedDot:SetupKey(422, self.uiData)
end

function UMG_Friend_Expression_Item_C:OnItemSelected(_bSelected)
  if _bSelected then
    if self.RedDot:IsRed() then
      self.RedDot:EraseRedPoint()
    end
    UE4.UNRCAudioManager.Get():PlaySound2DAuto(41401006, "UMG_Friend_Expression_Item_C:OnItemSelected")
    local EmoConf = _G.DataConfigManager:GetChatEmojiConf(self.uiData)
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.SendChatMessage, nil, EmoConf.emoji_esc)
    _G.NRCModuleManager:DoCmd(_G.FriendModuleCmd.OpenEmoMainPanel, 1, false)
  end
end

function UMG_Friend_Expression_Item_C:OnDeactive()
end

function UMG_Friend_Expression_Item_C:GetEmoPath(cfgPath)
  local path = "/Game/NewRoco/Modules/System/Friend/Raw/Expressio/Textures/" .. cfgPath
  return path
end

return UMG_Friend_Expression_Item_C
