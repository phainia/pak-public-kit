local PetUtils = require("NewRoco.Utils.PetUtils")
local PetUIModuleEvent = reload("NewRoco.Modules.System.PetUI.PetUIModuleEvent")
local FVector2DUtils = require("NewRoco.Utils.FVector2DUtils")
local UMG_Having_Equipment_C = _G.NRCViewBase:Extend("UMG_Having_Equipment_C")

function UMG_Having_Equipment_C:OnConstruct()
  self:SetChildViews(self.HavingProp, self.HavingProp_1, self.HavingProp_2, self.HavingProp_Empty, self.HavingProp_Empty_1, self.HavingProp_Empty_2, self.HavingProp_3, self.HavingProp_4, self.HavingProp_5)
  self.subPanels_HavingProp = {
    self.HavingProp_3,
    self.HavingProp_4,
    self.HavingProp_5
  }
  self.subPanels_HavingProp_Empty = {
    self.HavingProp_Empty,
    self.HavingProp_Empty_1,
    self.HavingProp_Empty_2
  }
  self.LineS = {
    self.Line_4,
    self.Line_5
  }
  local icon1 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_kong_png.img_kong_png'"
  local icon2 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lv_png.img_lv_png'"
  local icon3 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lan_png.img_lan_png'"
  local icon4 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_zi_png.img_zi_png'"
  local icon5 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_cheng_png.img_cheng_png'"
  local checkicon1 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_kong_xz_png.img_kong_xz_png'"
  local checkicon2 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lv_xz_png.img_lv_xz_png'"
  local checkicon3 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_lan_xz_png.img_lan_xz_png'"
  local checkicon4 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_zi_xz_png.img_zi_xz_png'"
  local checkicon5 = "PaperSprite'/Game/NewRoco/Modules/System/PetUI/Raw/Having/Frames/img_cheng_xz_png.img_cheng_xz_png'"
  self.bgIcon = {
    icon1,
    icon2,
    icon3,
    icon4,
    icon5
  }
  self.checkbgIcon = {
    checkicon1,
    checkicon2,
    checkicon3,
    checkicon4,
    checkicon5
  }
  self.SelectHaving = 0
  self.CurrentSelectIndex = 0
  self.IsCanMovePosition = false
  self.IsCanScale = true
  self.MoveTime = 0
  self.uiData = {}
  self:OnAddEventListener()
end

function UMG_Having_Equipment_C:OnDestruct()
end

function UMG_Having_Equipment_C:OnActive(_PetData)
  self.uiData.petData = _PetData
  self:SetPanelInfo()
end

function UMG_Having_Equipment_C:SetSelectHaving(_SelectHaving)
  self.SelectHaving = _SelectHaving
end

function UMG_Having_Equipment_C:SetCurrentSelectIndex(_CurrentSelectIndex)
  self.CurrentSelectIndex = _CurrentSelectIndex
  self.IsCanScale = true
end

function UMG_Having_Equipment_C:SetHavingPosition()
  self.IsCanScale = false
  if 0 == self.CurrentSelectIndex then
  else
  end
end

function UMG_Having_Equipment_C:OnSetHavingUIPosition(Position)
end

function UMG_Having_Equipment_C:OnHavingChange(_data)
  self.uiData = _data
end

function UMG_Having_Equipment_C:SetPanelInfo()
  local PetData = self.uiData.petData
  local data = self:GetPetPossessionData(PetData)
  self:SetHavingSEquipInfo(self.subPanels_HavingProp, data)
  if 0 == self.CurrentSelectIndex then
  else
  end
end

function UMG_Having_Equipment_C:GetPetPossessionData(petData)
  local conf = _G.DataConfigManager:GetPetGlobalConfig("pet_max_equip_num")
  local items = petData.possession.item
  local maxNum = conf.num
  local PossessionData = {}
  for i = 1, maxNum do
    local data = {}
    data.pos = i
    if i == self.SelectHaving then
      data.IsSelect = true
    else
      data.IsSelect = false
    end
    data.bgIcon = self.bgIcon
    data.checkbgIcon = self.checkbgIcon
    if i <= #items then
      if items[i] and items[i].conf_id then
        data.bagItemConf = _G.DataConfigManager:GetBagItemConf(items[i].conf_id)
      end
      data.open = true
      data.petData = petData
      data.possessionItem = items[i]
    else
      data.breakData = self:GetPetBreakData(petData, i)
    end
    table.insert(PossessionData, data)
  end
  return PossessionData
end

function UMG_Having_Equipment_C:GetPetBreakData(petData, index)
  local initConf = _G.DataConfigManager:GetPetGlobalConfig("pet_initial_equip_num")
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(petData.base_conf_id)
  local break_awardConf = _G.DataConfigManager:GetBreakRewardConf(petBaseConf.break_award_sort)
  local brekNum = self:GetbreakthroughNum()
  local num = initConf.num
  for i = 1, #break_awardConf.break_award do
    local item = break_awardConf.break_award[i]
    num = num + item.is_slot_add
    if index <= num then
      local breakData = {}
      breakData.conf = item
      breakData.breakOpenIndex = i
      if i <= brekNum then
        breakData.open = true
      else
        breakData.open = false
      end
      return breakData
    end
  end
end

function UMG_Having_Equipment_C:GetbreakthroughNum()
  local PetData = self.uiData.petData
  local petBaseConf = _G.DataConfigManager:GetPetbaseConf(PetData.base_conf_id)
  local break_awardConf = _G.DataConfigManager:GetBreakRewardConf(petBaseConf.break_award_sort)
  for i = 1, #break_awardConf.break_award do
    local item = break_awardConf.break_award[i]
    if PetData.last_breakthrough_lv >= item.break_level_point then
      return i
    end
  end
  return 0
end

function UMG_Having_Equipment_C:SetHavingSEquipInfo(_subPanels, _data)
  local subPanels = _subPanels
  local data = _data
  for v, subPanel in ipairs(subPanels) do
    if subPanel then
      subPanel:SetHavingEquipInfo(data[v], self.CurrentSelectIndex, self.IsCanScale)
    end
  end
end

function UMG_Having_Equipment_C:SetHavingSPosition(_subPanels, _Position)
  local subPanels = _subPanels
  for v, subPanel in ipairs(subPanels) do
    if subPanel then
      subPanel:SetHavingPoSitionInfo(_Position[v])
    end
  end
end

function UMG_Having_Equipment_C:IsNeedMove(_subPanels, _Position)
  local subPanels = _subPanels
  for v, subPanel in ipairs(subPanels) do
    if subPanel then
      local IsCanMovePosition = subPanel:IsNeedMovePosition(_Position[v])
      if false == IsCanMovePosition then
        return false
      end
    end
  end
  return true
end

function UMG_Having_Equipment_C:MoveHavingPosition(_subPanels, _Position, deltaTime)
  local subPanels = _subPanels
  local IsNeedMoveInfo = self:IsNeedMove(subPanels, _Position)
  self.MoveTime = self.MoveTime + deltaTime
  if true == IsNeedMoveInfo then
    for v, subPanel in ipairs(subPanels) do
      if subPanel then
        local CurrentPosition = subPanel:GetCurrentPosition()
        local pos = FVector2DUtils.Lerp(CurrentPosition, _Position[v], self.MoveTime)
        if pos.X == _Position[v].X and pos.Y == _Position[v].Y then
          pos.X = _Position[v].X
          pos.Y = _Position[v].Y
          self.IsCanMovePosition = false
          self.MoveTime = 0
        end
        subPanel:SetHavingPoSitionInfo(pos)
      end
    end
  end
end

function UMG_Having_Equipment_C:SetLinePosition(_LinePosition)
  for i, Line in ipairs(self.LineS) do
    if Line then
      local pos = _LinePosition[i]
      local posInfo = UE4.FVector2D(pos.X, pos.Y)
      Line.Slot:SetPosition(posInfo)
    end
  end
end

function UMG_Having_Equipment_C:OnTick(deltaTime)
  if self.IsCanMovePosition == true then
    if 0 == self.CurrentSelectIndex then
    else
    end
    self:DispatchEvent(PetUIModuleEvent.HavingModelMove, self.CurrentSelectIndex, self.MoveTime)
  end
end

function UMG_Having_Equipment_C:GetDatas()
  return self:GetPetPossessionData(self.uiData.petData)
end

function UMG_Having_Equipment_C:OnDeactive()
end

function UMG_Having_Equipment_C:OnAddEventListener()
end

return UMG_Having_Equipment_C
