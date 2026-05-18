local MagicManualModuleEvent = require("NewRoco.Modules.System.MagicManual.MagicManualModuleEvent")
local UMG_MagicManual_Recalling_C = _G.NRCPanelBase:Extend("UMG_MagicManual_Recalling_C")

function UMG_MagicManual_Recalling_C:OnActive(recallingId, parent)
end

function UMG_MagicManual_Recalling_C:OnEnable(module, recallingId, parent)
  self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  self.module = module
  self.recallingId = recallingId
  self.parent = parent
  self:OnAddEventListener()
  self:_InitPanel()
end

function UMG_MagicManual_Recalling_C:OnDeactive()
end

function UMG_MagicManual_Recalling_C:OnAddEventListener()
  if not self.bInit then
    self.bInit = true
    self:AddButtonListener(self.MagicManualKnowBtn.btnLevelUp, self.OnKnowBtnClicked)
  end
end

function UMG_MagicManual_Recalling_C:OnKnowBtnClicked()
  self:OnOpenLongDialog(_G.LuaText.reacall_text)
end

function UMG_MagicManual_Recalling_C:OnConstruct()
  self.bInit = false
end

function UMG_MagicManual_Recalling_C:_InitPanel()
  if not self.recallingId or 0 == self.recallingId then
    return
  end
  self.recallConf = _G.DataConfigManager:GetReacallConf(self.recallingId)
  if not self.recallConf then
    Log.Error("UMG_MagicManual_Recalling_C:_InitPanel \229\155\158\230\131\179id\229\175\185\229\186\148\231\154\132\232\161\168\232\161\140\228\184\141\229\173\152\229\156\168\239\188\140Id\228\184\186%s\239\188\140\230\163\128\230\159\165RECALL_CONF\233\133\141\231\189\174\232\161\168", self.recallingId)
    return
  end
  self.TabListItems = {}
  local fieldPrefix = "data"
  local nIndex = 0
  local num = 0
  for i = 1, 20 do
    local fieldName = fieldPrefix .. tostring(i)
    local tabId = self.recallConf[fieldName]
    if not tabId or 0 == tabId then
    elseif self:_CheckHasList(tabId) then
      local initItem = {}
      initItem.id = tabId
      initItem.parent = self
      if tabId == self.recallConf.jump_target then
        nIndex = num
      end
      table.insert(self.TabListItems, initItem)
      num = num + 1
    end
  end
  self.TabList:InitList(self.TabListItems)
  if 0 == #self.TabListItems then
    Log.Error("UMG_MagicManual_Recalling_C:_InitPanel \230\178\161\230\156\137\232\167\163\233\148\129\231\154\132\229\155\158\230\131\179\230\157\161\231\155\174", self.recallingId)
  else
    self.TabList:SelectItemByIndex(nIndex)
  end
end

function UMG_MagicManual_Recalling_C:_CheckHasList(tabId)
  local listConf = _G.DataConfigManager:GetReacallListConf(tabId)
  if listConf then
    local limitData = {}
    if listConf.reacallt_list_unlock_trigger1 and 0 ~= listConf.reacallt_list_unlock_trigger1 then
      table.insert(limitData, {
        trigger = listConf.reacallt_list_unlock_trigger1,
        data = listConf.trigger1_data
      })
    end
    if listConf.reacallt_list_unlock_trigger2 and 0 ~= listConf.reacallt_list_unlock_trigger2 then
      table.insert(limitData, {
        trigger = listConf.reacallt_list_unlock_trigger2,
        data = listConf.trigger2_data
      })
    end
    if listConf.reacallt_list_unlock_trigger3 and 0 ~= listConf.reacallt_list_unlock_trigger3 then
      table.insert(limitData, {
        trigger = listConf.reacallt_list_unlock_trigger3,
        data = listConf.trigger3_data
      })
    end
    local bHas = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.IsLimitSatisfy, limitData)
    return bHas
  else
    Log.Error("UMG_MagicManual_Recalling_C:_CheckHasList id%s\229\156\168RECALL_LIST_CONF\228\184\173\230\178\161\230\156\137\230\137\190\229\136\176\239\188\140\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168", tabId)
  end
  return false
end

function UMG_MagicManual_Recalling_C:OnClickRecallTabListItem(index)
  if not self.TabListItems or 0 == #self.TabListItems then
    Log.Error("UMG_MagicManual_Recalling_C:OnClickRecallTabListItem \229\135\186\231\142\176\229\155\158\230\131\179\228\184\1860\231\154\132\230\131\133\229\134\181\239\188\140\230\156\137\233\151\174\233\162\152\239\188\129")
    return
  end
  local tabItem = self.TabListItems[index]
  if not (tabItem and tabItem.id) or 0 == tabItem.id then
    Log.Error("UMG_MagicManual_Recalling_C:OnClickRecallTabListItem \229\175\185\229\186\148\231\154\132tab\229\135\186\231\142\1760\231\154\132\230\131\133\229\134\181\239\188\140\230\156\137\233\151\174\233\162\152\239\188\129")
    return
  end
  local listId = tabItem.id
  local recallListConf = _G.DataConfigManager:GetReacallListConf(listId)
  if not recallListConf then
    Log.Error("UMG_MagicManual_Recalling_C:OnClickRecallTabListItem id%s\229\156\168RECALL_LIST_CONF\228\184\173\230\178\161\230\156\137\230\137\190\229\136\176\239\188\140\230\163\128\230\159\165\233\133\141\231\189\174\232\161\168", listId)
    return
  end
  local initList = {}
  if recallListConf.main_terms_id1 and 0 ~= recallListConf.main_terms_id1 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.main_terms_id1, true))
  end
  if recallListConf.main_terms_id2 and 0 ~= recallListConf.main_terms_id2 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.main_terms_id2, true))
  end
  if recallListConf.main_terms_id3 and 0 ~= recallListConf.main_terms_id3 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.main_terms_id3, true))
  end
  if recallListConf.sub_terms_id1 and 0 ~= recallListConf.sub_terms_id1 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.sub_terms_id1, false))
  end
  if recallListConf.sub_terms_id2 and 0 ~= recallListConf.sub_terms_id2 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.sub_terms_id2, false))
  end
  if recallListConf.sub_terms_id3 and 0 ~= recallListConf.sub_terms_id3 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.sub_terms_id3, false))
  end
  if recallListConf.sub_terms_id4 and 0 ~= recallListConf.sub_terms_id4 then
    table.insert(initList, self:_GetRecallingItemInitItem(recallListConf.sub_terms_id4, false))
  end
  self.DetailsList:InitList(initList)
  self.DetailsList:SetScrollOffset(0)
  self:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
end

function UMG_MagicManual_Recalling_C:_GetRecallingItemInitItem(id, bIsMain)
  local termsConf = _G.DataConfigManager:GetReacallTremsConf(id)
  if not termsConf then
    Log.Error("\229\176\157\232\175\149\230\159\165\232\175\162\228\184\128\228\184\170\228\184\141\229\173\152\229\156\168\231\154\132term\233\161\185\239\188\140id\228\184\186%s\239\188\140\230\163\128\230\159\165RECALL_TERMS_CONF\233\133\141\231\189\174", id)
    return nil
  end
  local limitData = {}
  if termsConf.reacallt_terms_unlock_trigger1 and 0 ~= termsConf.reacallt_terms_unlock_trigger1 then
    table.insert(limitData, {
      trigger = termsConf.reacallt_terms_unlock_trigger1,
      data = termsConf.trigger1_data
    })
  end
  if termsConf.reacallt_terms_unlock_trigger2 and 0 ~= termsConf.reacallt_terms_unlock_trigger2 then
    table.insert(limitData, {
      trigger = termsConf.reacallt_terms_unlock_trigger2,
      data = termsConf.trigger2_data
    })
  end
  if termsConf.reacallt_terms_unlock_trigger3 and 0 ~= termsConf.reacallt_terms_unlock_trigger3 then
    table.insert(limitData, {
      trigger = termsConf.reacallt_terms_unlock_trigger3,
      data = termsConf.trigger3_data
    })
  end
  local bHas = _G.NRCModuleManager:DoCmd(_G.MagicManualModuleCmd.IsLimitSatisfy, limitData)
  if not bHas then
    return nil
  end
  local result = {}
  result.id = id
  result.parent = self
  result.bIsMain = bIsMain
  return result
end

function UMG_MagicManual_Recalling_C:OnDestruct()
end

function UMG_MagicManual_Recalling_C:OnOpenLongDialog(Content)
  local DialogContext = require("NewRoco.Modules.System.TipsModule.DialogContext")
  local Context = DialogContext()
  local title = _G.LuaText.reacall_text_title
  Context:SetTitle(title):SetContent(Content):SetMode(DialogContext.Mode.NotBtn):SetCloseOnCancel(true):SetCloseOnOK(true)
  _G.NRCModuleManager:DoCmd(_G.TipsModuleCmd.Dialog_OpenLongDialog, Context)
end

return UMG_MagicManual_Recalling_C
