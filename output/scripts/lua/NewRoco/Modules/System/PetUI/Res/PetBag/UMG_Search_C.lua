local BagModuleEvent = reload("NewRoco.Modules.System.Bag.BagModuleEvent")
local UMG_Search_C = _G.NRCPanelBase:Extend("UMG_Search_C")

function UMG_Search_C:OnConstruct()
  self.NRCText_98:SetText(LuaText.searched_in_my_warehouse)
  self.PetDataDic = {}
  local allPetList = self.module:GetAllPetDatasWithoutBigWorldTeam()
  for i, v in pairs(allPetList) do
    if v.base_conf_id then
      self.PetDataDic[v.base_conf_id] = v
    end
  end
  self:SetChildViews(self.PopUp2)
  self:OnAddEventListener()
end

function UMG_Search_C:OnAddEventListener()
  self:AddDelegateListener(self.InputBox.OnTextChanged, self.OnTextChanged)
  self:AddButtonListener(self.DeleteBtn, self.OnClearText)
end

function UMG_Search_C:OnActive()
  self:LoadAnimation(0)
  self:SetCommonPopUpInfo()
  self.allPetHandbookConfs = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetAllPetHandbookConfs)
  self.InputBox:SetText("")
  self.petList:InitGridView({})
  self.NRCSwitcher_0:SetActiveWidgetIndex(1)
end

function UMG_Search_C:GetHandbookAllBaseId(bookConf)
  local baseId = {}
  if bookConf and bookConf.include_petbase_id and #bookConf.include_petbase_id > 0 then
    for j = 1, #bookConf.include_petbase_id do
      local include = bookConf.include_petbase_id[j]
      if include.petbase_id and #include.petbase_id > 0 then
        for i = 1, #include.petbase_id do
          local id = include.petbase_id[i]
          if self.PetDataDic[id] then
            table.insert(baseId, id)
          end
        end
      end
    end
  end
  return baseId
end

function UMG_Search_C:OnClearText()
  self.InputBox:SetText("")
end

function UMG_Search_C:OnTextChanged()
  local text = self.InputBox:GetText()
  if "" ~= text then
    self.DeleteBtn:SetVisibility(UE4.ESlateVisibility.Visible)
  else
    self.DeleteBtn:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  text = self:SubStr(text, 30)
  text = string.GetSubStr(text, 30)
  if string.SubStringGetTotalIndex(text) > 30 then
    text = string.GetSubStr(text, 30)
  end
  self.InputBox:SetText(text)
  self:OnScreen(text)
end

function UMG_Search_C:OnScreen(text)
  if nil == text or 0 == #text or nil ~= text:match("^[%s\r\n\t]*$") then
    self.petList:InitGridView({})
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
    return
  end
  local results = {}
  for _, bookConf in pairs(self.allPetHandbookConfs) do
    local name = bookConf.name
    if string.find(name:lower(), text:lower(), 1, true) then
      table.insert(results, bookConf)
    end
  end
  if #results > 0 then
    local datas = {}
    for _, bookConf in pairs(results) do
      local baseId = self:GetHandbookAllBaseId(bookConf)
      for _, id in pairs(baseId) do
        local data = {petBaseId = id, isShowReduction = false}
        table.insert(datas, data)
      end
    end
    table.sort(datas, function(a, b)
      return a.petBaseId < b.petBaseId
    end)
    self.petList:InitGridView(datas)
    if #datas > 0 then
      self.NRCSwitcher_0:SetActiveWidgetIndex(0)
    end
  else
    self.petList:InitGridView({})
    self.NRCSwitcher_0:SetActiveWidgetIndex(1)
  end
end

function UMG_Search_C:SubStr(str, byte_count)
  local count = 0
  local len = #str
  local index = 1
  while byte_count > count and len >= index do
    local ch = string.byte(str, index)
    local step
    if ch < 128 then
      step = 1
    elseif ch >= 192 and ch < 224 then
      step = 2
    elseif ch >= 224 and ch < 240 then
      step = 3
    elseif ch >= 240 and ch < 248 then
      step = 4
    elseif ch >= 248 and ch < 252 then
      step = 5
    elseif ch >= 252 then
      step = 6
    else
      step = 0
    end
    if byte_count < count + step then
      break
    end
    count = count + step
    index = index + step
  end
  return string.sub(str, 1, index - 1)
end

function UMG_Search_C:SetCommonPopUpInfo()
  local CommonPopUpData = _G.NRCCommonPopUpData()
  CommonPopUpData.Call = self
  CommonPopUpData.TitleText = LuaText.searched_in_my_warehouse_title
  CommonPopUpData.Btn_LeftHandler = self.OnLeftBtn
  CommonPopUpData.Btn_RightHandler = self.OnRightBtn
  CommonPopUpData.ClosePanelHandler = self.OnCloseBtn
  CommonPopUpData.CloseBtnSound = 41401010
  self.OnPcCloseHandler = CommonPopUpData.ClosePanelHandler
  self.PopUp2.Btn_Right_GrayState = false
  self.PopUp2:SetPanelInfo(CommonPopUpData)
end

function UMG_Search_C:OnLeftBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401002, "UMG_Search_C:OnLeftBtn")
  self.InputBox:SetText("")
end

function UMG_Search_C:OnRightBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401001, "UMG_Search_C:OnRightBtn")
  if self.InputBox:GetText() == "" then
    self:OnCloseBtn()
    return
  end
  local filterPet = {}
  for i = 1, self.petList:GetItemCount() do
    local item = self.petList:GetItemByIndex(i - 1)
    if item.clickToggle == true then
      local petbaseId = item.data.petBaseId
      table.insert(filterPet, petbaseId)
    end
  end
  local condition = {}
  condition.FilterPetIdCondition = filterPet
  _G.NRCEventCenter:DispatchEvent(BagModuleEvent.OnFilter, filterPet, condition)
  self:OnCloseBtn()
end

function UMG_Search_C:OnCloseBtn()
  _G.NRCAudioManager:PlaySound2DAuto(41401010, "UMG_Search_C:OnCloseBtn")
  self:LoadAnimation(2)
end

function UMG_Search_C:OnDeactive()
end

function UMG_Search_C:OnAnimationFinished(Animation)
  if Animation == self:GetAnimByIndex(0) then
    self:LoadAnimation(1)
  elseif Animation == self:GetAnimByIndex(2) then
    self:DoClose()
  end
end

return UMG_Search_C
