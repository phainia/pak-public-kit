local DialogueModuleEvent = require("NewRoco.Modules.System.Dialogue.DialogueModuleEvent")
local AltarModuleEvent = require("NewRoco.Modules.System.AltarModule.AltarModuleEvent")
local UMG_ItemAltarFree_C = _G.NRCPanelBase:Extend("UMG_ItemAltarFree_C")

function UMG_ItemAltarFree_C:OnConstruct()
  Log.Debug("UMG_ItemAltarFree_C:OnConstruct")
  self.BtnConfirm:SetBtnText(LuaText.umg_itemaltar_1)
  self:AddButtonListener(self.CloseBtn.btnClose, self.OnClickCancel)
  self:AddButtonListener(self.BtnConfirm.btnLevelUp, self.OnClickConfirm)
  self:AddButtonListener(self.BtnConfirm_1.btnLevelUp, self.OnClickConfirmLock)
  _G.NRCEventCenter:RegisterEvent("UMG_ItemAltarFree_C", self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  _G.NRCEventCenter:RegisterEvent("UMG_ItemAltarFree_C", self, AltarModuleEvent.FreeAltarItemSelect, self.OnItemSelected)
  _G.NRCEventCenter:RegisterEvent("UMG_ItemAltarFree_C", self, AltarModuleEvent.FreeAltarItemUnSelect, self.OnItemUnSelected)
  self.BtnConfirm_1:SetShowLockIcon(false)
  self.BtnConfirm:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnConfirm_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.itemData = nil
end

function UMG_ItemAltarFree_C:OnActive(action)
  Log.Debug("UMG_ItemAltarFree_C:OnActive")
  local items = {}
  if action then
    self.optionId = action.Owner.config.id
    self.npcId = action.Owner.owner.serverData.base.actor_id
    self.action = action
    local paramStr = action.Config.action_param1
    Log.Dump(paramStr)
    local params = paramStr:split(";")
    Log.Debug(self.optionId .. " NPC id " .. self.npcId)
    self.altarName:SetText(_G.DataConfigManager:GetDialogueConf(action.Info.bound_dialog_id).submit_free_text)
    local commitIds = action.Info.begin_act_params
    local commitIdsKeyMap = {}
    if commitIds then
      for _, v in ipairs(commitIds) do
        commitIdsKeyMap[v] = v
      end
    end
    for i = 1, #params, 3 do
      local item = {}
      item.id = tonumber(params[i])
      if commitIdsKeyMap[item.id] then
        item.bCommit = true
      else
        item.bCommit = false
      end
      local bagItemData = _G.NRCModuleManager:DoCmd(BagModuleCmd.GetBagItemByID, item.id)
      if bagItemData then
        item.cur = bagItemData.num
      else
        item.cur = 0
      end
      item.need = tonumber(params[i + 1])
      table.insert(items, item)
    end
  else
    Log.Warning("UMG_PetAltar_C:OnActive option\228\184\186nil\239\188\140\229\166\130\230\158\156\228\184\141\230\152\175\233\128\154\232\191\135debug\233\157\162\230\157\191\230\137\147\229\188\128\232\175\183\230\163\128\230\159\165")
  end
  local itemNum = #items
  if itemNum > 0 then
    self:StableSort(items, function(b, a)
      if a.bCommit and not b.bCommit then
        return true
      elseif b.bCommit and not a.bCommit then
        return false
      elseif not a.bCommit and not b.bCommit then
        if 0 == a.cur and b.cur > 0 then
          return true
        else
          return false
        end
      else
        return false
      end
    end)
    self.NRCGridViewList1:InitGridView(items)
  else
    Log.Debug("no items")
  end
  self:PlayAnimation(self.In)
end

function UMG_ItemAltarFree_C:StableSort(list, compareFunc)
  for i = 2, #list do
    local j = i
    while j > 1 and compareFunc(list[j], list[j - 1]) do
      list[j], list[j - 1] = list[j - 1], list[j]
      j = j - 1
    end
  end
end

function UMG_ItemAltarFree_C:OnDialogueEnded()
  self:DoClose()
end

function UMG_ItemAltarFree_C:OnClickCancel()
  Log.Debug("UMG_ItemAltarFree_C:OnClickCancel")
  _G.NRCAudioManager:PlaySound2DAuto(40008006, "UMG_ItemAltarFree_C:OnClickCancel")
  if self.action and self.action.Finish then
    self.action:Finish(false, nil)
    self.action = nil
    self:PlayAnimation(self.Out)
  end
end

function UMG_ItemAltarFree_C:OnClickConfirm()
  Log.Debug("UMG_ItemAltarFree_C:OnClickConfirm")
  _G.NRCAudioManager:PlaySound2DAuto(41401003, "UMG_ItemAltarFree_C:OnClickConfirm")
  if self.action then
    self.action:GiveFinish(tostring(self.itemData.id))
    self.action = nil
    self:PlayAnimation(self.Out)
  end
end

function UMG_ItemAltarFree_C:OnItemSelected(_data)
  self.itemData = _data
  self.UMG_ItemAltarItem:OnItemUpdate(_data)
  self.UMG_ItemAltarItem:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.Tips1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  if _data.cur >= _data.need then
    self.BtnConfirm:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.BtnConfirm_1:SetVisibility(UE4.ESlateVisibility.Collapsed)
  else
    self.BtnConfirm:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.BtnConfirm_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  end
end

function UMG_ItemAltarFree_C:OnItemUnSelected()
  self.itemData = nil
  self.UMG_ItemAltarItem:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.Tips1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
  self.BtnConfirm:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.BtnConfirm_1:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_ItemAltarFree_C:OnClickConfirmLock()
  if self.itemData then
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("submit_item_free_lack").msg)
  else
    _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.TopHud_ShowTips, _G.DataConfigManager:GetLocalizationConf("submit_item_free_unselect").msg)
  end
end

function UMG_ItemAltarFree_C:OnAnimationFinished(Anim)
  if Anim == self.Out then
    _G.NRCModuleManager:DoCmd(AltarModuleCmd.CloseItemAltarPanelFree)
  end
end

function UMG_ItemAltarFree_C:OnDestruct()
  self.action = nil
  _G.NRCEventCenter:UnRegisterEvent(self, DialogueModuleEvent.DialogueEnded, self.OnDialogueEnded)
  _G.NRCEventCenter:UnRegisterEvent(self, AltarModuleEvent.FreeAltarItemSelect, self.OnItemSelected)
  _G.NRCEventCenter:UnRegisterEvent(self, AltarModuleEvent.FreeAltarItemUnSelect, self.OnItemUnSelected)
  self:RemoveButtonListener(self.CloseBtn.btnClose)
  self:RemoveButtonListener(self.BtnConfirm.btnLevelUp)
  self:RemoveButtonListener(self.BtnConfirm_1.btnLevelUp)
end

function UMG_ItemAltarFree_C:OnDeactive()
  self.action = nil
end

return UMG_ItemAltarFree_C
