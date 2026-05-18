require("UnLuaEx")
local BattleEnum = require("NewRoco.Modules.Core.Battle.Common.BattleEnum")
local BattleEvent = require("NewRoco.Modules.Core.Battle.Common.BattleEvent")
local BattleUtils = require("NewRoco.Modules.Core.Battle.Common.BattleUtils")
local UMG_Battle_Popup_CommandMgr_C = NRCPanelBase:Extend("UMG_Battle_Popup_CommandMgr_C")

function UMG_Battle_Popup_CommandMgr_C:OnActive()
  self.battleManager = _G.BattleManager
  self.PreselectPopupQueue = {}
  self.RightList = {
    self.rightInfo
  }
  self.LeftList = {
    self.leftInfo
  }
  self.PopupRef = {}
  self.HideAllLeft = false
  self.HideAllRight = false
  self:AddListener()
  self.leftInfo:SetLeftOrRight(true)
  self.rightInfo:SetLeftOrRight(false)
  if BattleUtils.IsTeam() then
    self:PlayAnimation(self.Displacement)
  end
  self:SetPanelRenderOpacity()
  if not BattleUtils.IsTeam() and not BattleUtils.IsWorldLeaderFight() and not BattleUtils.IsBloodTeam() and not BattleUtils.IsBeastTeam() and self:IsPCMode() then
    local Padding = UE4.FMargin()
    Padding.Left = 0
    Padding.Top = 189
    Padding.Right = 30
    Padding.Bottom = 30
    self.Left.Slot:SetOffsets(Padding)
  end
end

function UMG_Battle_Popup_CommandMgr_C:SetPanelRenderOpacity()
  if _G.IsSetRenderOpacity then
    self:SetRenderOpacity(_G.RenderOpacity)
  end
end

function UMG_Battle_Popup_CommandMgr_C:OnDeactive()
  self:RemoveListener()
  table.clear(self.PreselectPopupQueue)
  self.LeftList = nil
  self.RightList = nil
  self.PopupRef = nil
end

function UMG_Battle_Popup_CommandMgr_C:AddListener()
  _G.BattleEventCenter:Bind(self, BattleEvent.UI_CLEAR_PRESELECT_POPUPS, BattleEvent.UI_SHOW_INFO_POPUP, BattleEvent.UI_HIDE_INFO_POPUP, BattleEvent.Popup_CommandInfo_End)
end

function UMG_Battle_Popup_CommandMgr_C:RemoveListener()
  _G.BattleEventCenter:UnBind(self)
end

function UMG_Battle_Popup_CommandMgr_C:OnBattleEvent(eventName, ...)
  if eventName == BattleEvent.UI_CLEAR_PRESELECT_POPUPS then
    self:ClearPopups()
  elseif eventName == BattleEvent.UI_SHOW_INFO_POPUP then
    self:ShowPopup(...)
  elseif eventName == BattleEvent.UI_HIDE_INFO_POPUP then
    self:HidePopup(...)
  elseif eventName == BattleEvent.Popup_CommandInfo_End then
    self:CommandInfoEnd(...)
  end
end

function UMG_Battle_Popup_CommandMgr_C:CommandInfoEnd(isLeft, command)
  local list = isLeft and self.LeftList or self.RightList or {}
  local isRemove = false
  for i = #list - 1, 1, -1 do
    if list[i] == command then
      isRemove = true
      table.remove(list, i)
    end
  end
  if isRemove then
    table.insert(list, command)
    self:RefreshPosition(isLeft)
  end
end

function UMG_Battle_Popup_CommandMgr_C:RefreshPosition(isLeft)
  local list = isLeft and self.LeftList or self.RightList or {}
  for i, v in ipairs(list) do
    local widgetSlot = v.Slot
    if widgetSlot then
      widgetSlot:SetPosition(UE4.FVector2D(0, (i - 1) * 80))
    else
      Log.Error("zgx WidgetSlot is nil")
    end
  end
end

function UMG_Battle_Popup_CommandMgr_C:ShowPopup(msg, flag)
  self:AddPopup(msg, msg[2].teamEnm == BattleEnum.Team.ENUM_TEAM, flag)
end

function UMG_Battle_Popup_CommandMgr_C:AddPopup(msg, isLeft, flag)
  local list = isLeft and self.LeftList or self.RightList
  if isLeft then
    self.HideAllLeft = false
  else
    self.HideAllRight = false
  end
  if not list then
    return
  end
  for i, v in ipairs(list) do
    if v.IsCanRepeat then
      v:ShowPopup(msg, isLeft, flag)
      return
    end
  end
  local umgPath = isLeft and _G.UEPath.UMG_Battle_PopupInfo or _G.UEPath.UMG_Battle_PopupInfoRight
  _G.BattleResourceManager:LoadWidgetAsync(self, umgPath, nil, function(caller, info)
    if info then
      local father = isLeft and caller.Left or caller.Right
      local widgetSlot = father:AddChild(info)
      info:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      widgetSlot:SetAutoSize(true)
      if list[1] and list[1].Slot then
        widgetSlot:SetLayout(list[1].Slot:GetLayout())
        widgetSlot:SetSize(list[1].Slot:GetSize())
        widgetSlot:SetZOrder(#list)
        widgetSlot:SetPosition(UE4.FVector2D(0, #list * 80))
      end
      _G.LastWidget = info
      table.insert(list, info)
      table.insert(caller.PopupRef, UnLua.Ref(info))
      for _, v in ipairs(list) do
        if isLeft and not caller.HideAllLeft and v.IsCanRepeat then
          v:ShowPopup(msg, isLeft, flag)
          return
        elseif not isLeft and not caller.HideAllRight and v.IsCanRepeat then
          v:ShowPopup(msg, isLeft, flag)
          return
        end
      end
    end
  end, nil)
end

function UMG_Battle_Popup_CommandMgr_C:HidePopup(msg, flag)
  if msg and msg.teamEnm == BattleEnum.Team.ENUM_TEAM then
    self.HideAllLeft = true
    if self.LeftList then
      for _, v in ipairs(self.LeftList) do
        if not (flag or v.flag) or flag == v.flag then
          v:HidePopup()
        end
      end
    end
  else
    self.HideAllRight = true
    if self.RightList then
      for _, v in ipairs(self.RightList) do
        if not (flag or v.flag) or flag == v.flag then
          v:HidePopup()
        end
      end
    end
  end
end

function UMG_Battle_Popup_CommandMgr_C:ClearPopups()
  Log.Debug("Clearing Popups")
  if self.RightList then
    for _, v in ipairs(self.RightList) do
      v:HidePopup()
    end
  end
  if self.LeftList then
    for _, v in ipairs(self.LeftList) do
      v:HidePopup()
    end
  end
end

function UMG_Battle_Popup_CommandMgr_C:IsPCMode()
  return UE.UGameplayStatics.GetGameInstance(self):IsPCMode()
end

return UMG_Battle_Popup_CommandMgr_C
