local Base = require("NewRoco.TUI.BP_NRCItemBase_C")
local UMG_RelationTree_ListItem1_C = Base:Extend("UMG_RelationTree_ListItem1_C")
local RelationTreeEvent = reload("NewRoco.Modules.System.RelationTree.RelationTreeEvent")

function UMG_RelationTree_ListItem1_C:OnConstruct()
  self.module = _G.NRCModuleManager:GetModule("RelationTreeModule")
  _G.NRCEventCenter:RegisterEvent("UMG_RelationTree_ListItem1_C", self, RelationTreeEvent.RELATION_LINE_UNLOCK_EFFECT, self.LineUnlockEffect)
end

function UMG_RelationTree_ListItem1_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, RelationTreeEvent.RELATION_LINE_UNLOCK_EFFECT, self.LineUnlockEffect)
end

function UMG_RelationTree_ListItem1_C:OnItemUpdate(_data, datalist, index)
  if not _data then
    return
  end
  local PlayerUid = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetCurPlayerUID)
  local OherRelationRequestEnumType = _G.NRCModuleManager:DoCmd(_G.RelationTreeCmd.GetOtherRequestsByUin, PlayerUid)
  self:StopAllAnimations()
  self._data = _data
  self.datalist = datalist
  self.index = index
  local MasterLineState = {0, 1}
  local MasterLineAnim = self.lighten_loop1
  local Image = self.NRCImage_262
  if #self.datalist[index] < 3 then
    MasterLineState = {2, 3}
    MasterLineAnim = self.lighten_loop4
    Image = self.in_4
  end
  for i = 1, 3 do
    local ItemStr = string.format("SocialTree_Item%d", i)
    local LineStr = string.format("Switcher_Line%d", i)
    if self[ItemStr] and self[LineStr] then
      if i <= #self.datalist[index] then
        local PlayerUid = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetCurPlayerUID)
        local UnlockMaxFloor = self.module:GetCurUnLockMaxFloor()
        local LevelData = self.module:GetCurOtherLevelData()
        self[ItemStr]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        self[LineStr]:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
        if 1 == i then
          local NextMasterNode = self.module:GetNextMasterNode(PlayerUid, self._data[i].ID)
          if NextMasterNode then
            if NextMasterNode.Unlock then
              self[LineStr]:SetActiveWidgetIndex(MasterLineState[2])
            else
              self[LineStr]:SetActiveWidgetIndex(MasterLineState[1])
              if NextMasterNode.ForwardUnlockState then
                self:PlayAnimation(MasterLineAnim, 0, 0)
              else
                self:StopAnimation(MasterLineAnim)
                self.NRCImage_5:SetRenderOpacity(1)
                local NRCImage5DynamicMaterial = self.NRCImage_5:GetDynamicMaterial(1)
                NRCImage5DynamicMaterial:SetScalarParameterValue("Anim", 0)
                local DynamicMaterial = Image:GetDynamicMaterial()
                DynamicMaterial:SetScalarParameterValue("Anim", 0)
              end
            end
          else
            self[LineStr]:SetActiveWidgetIndex(MasterLineState[1])
            self[LineStr]:SetVisibility(UE4.ESlateVisibility.Collapsed)
          end
        else
          local Image = self.NRCImage_314
          if 3 == i then
            Image = self.NRCImage_367
          end
          if self._data[i].Unlock then
            self[LineStr]:SetActiveWidgetIndex(1)
          else
            self[LineStr]:SetActiveWidgetIndex(0)
            local AnimStr = string.format("lighten_loop%d", i)
            if self._data[i].ForwardUnlockState then
              self:PlayAnimation(self[AnimStr], 0, 0)
            else
              self:StopAnimation(self[AnimStr])
              local DynamicMaterial = Image:GetDynamicMaterial()
              DynamicMaterial:SetScalarParameterValue("Anim", 0)
            end
          end
        end
        self[ItemStr]:SetData(self._data[i], index, self.datalist[index], PlayerUid, UnlockMaxFloor, LevelData)
      else
        self[ItemStr]:SetVisibility(UE4.ESlateVisibility.Collapsed)
        self[LineStr]:SetVisibility(UE4.ESlateVisibility.Collapsed)
      end
    end
  end
end

function UMG_RelationTree_ListItem1_C:UpdateSelectItemChange(NodeId)
  for i = 1, 3 do
    local ItemStr = string.format("SocialTree_Item%d", i)
    if self[ItemStr] then
      self[ItemStr]:UpdateItemSelect(NodeId)
    end
  end
end

function UMG_RelationTree_ListItem1_C:LineUnlockEffect(PlayerUin, RelationTreeType, IsDefault)
  local PlayerUid = _G.NRCModuleManager:DoCmd(RelationTreeCmd.GetCurPlayerUID)
  if PlayerUin == PlayerUid and self._data then
    self.PlayerUin = PlayerUin
    local AnimLinIn = self.line_in_1
    local AnimLinIn_2 = self.lighten_in1
    if #self._data < 3 then
      AnimLinIn = self.line_in_4
      AnimLinIn_2 = self.lighten_in4
    end
    for nodetype, nodevalue in pairs(self._data) do
      local EnumType
      if IsDefault then
        EnumType = nodevalue.RelationTreeTypeDefault
      else
        EnumType = nodevalue.RelationTreeType
      end
      if EnumType == RelationTreeType then
        if 1 ~= nodetype then
          nodevalue = self.module:GetCurrentNodeValueByType(PlayerUid, RelationTreeType)
          local NextNode = self.module:GetNextNode(PlayerUid, self._data[nodetype].ID)
          if nodevalue then
            self.UpdateRelationTreeType = nodevalue.RelationTreeType
            if nodevalue.Unlock then
              local AnimStr = string.format("line_in_%d", nodetype)
              if self[AnimStr] then
                _G.NRCAudioManager:PlaySound2DAuto(41501002, "UMG_RelationTree_ListItem1_C:lineIn")
                self:PlayAnimation(self[AnimStr])
              end
              if NextNode then
                self:LineUnlockEffect(PlayerUin, NextNode.RelationTreeType)
              end
            elseif nodevalue.ForwardUnlockState then
              local AnimStr = string.format("lighten_in%d", nodevalue.NodeType)
              if self[AnimStr] then
                self:PlayAnimation(self[AnimStr])
              end
            end
          end
        else
          local NextMasterNode = self.module:GetNextMasterNode(PlayerUid, nodevalue.ID)
          if NextMasterNode then
            self.MasterUpdateRelationTreeType = NextMasterNode.RelationTreeType
            if NextMasterNode.Unlock then
              _G.NRCAudioManager:PlaySound2DAuto(41501002, "UMG_RelationTree_ListItem1_C:lineIn")
              self:PlayAnimation(AnimLinIn)
            elseif NextMasterNode.ForwardUnlockState then
              self:PlayAnimation(AnimLinIn_2)
            end
          end
        end
      end
    end
  end
end

function UMG_RelationTree_ListItem1_C:OnAnimationFinished(anim)
  if anim == self.line_in_1 then
    self:StopAnimation(self.lighten_loop1)
    self.Switcher_Line1:SetActiveWidgetIndex(1)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.MasterUpdateRelationTreeType)
  elseif anim == self.line_in_2 then
    self:StopAnimation(self.lighten_loop2)
    self.Switcher_Line2:SetActiveWidgetIndex(1)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.UpdateRelationTreeType)
  elseif anim == self.line_in_3 then
    self:StopAnimation(self.lighten_loop3)
    self.Switcher_Line3:SetActiveWidgetIndex(1)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.UpdateRelationTreeType)
  elseif anim == self.line_in_4 then
    self:StopAnimation(self.lighten_loop4)
    self.Switcher_Line1:SetActiveWidgetIndex(3)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.MasterUpdateRelationTreeType)
  elseif anim == self.lighten_in1 then
    self:PlayAnimation(self.lighten_loop1, 0, 0)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.MasterUpdateRelationTreeType)
  elseif anim == self.lighten_in2 then
    self:PlayAnimation(self.lighten_loop2, 0, 0)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.UpdateRelationTreeType)
  elseif anim == self.lighten_in3 then
    self:PlayAnimation(self.lighten_loop3, 0, 0)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.UpdateRelationTreeType)
  elseif anim == self.lighten_in4 then
    self:PlayAnimation(self.lighten_loop4, 0, 0)
    _G.NRCEventCenter:DispatchEvent(RelationTreeEvent.RELATION_ITEM_UNLOCK_EFFECT, self.PlayerUin, self.MasterUpdateRelationTreeType)
  end
end

function UMG_RelationTree_ListItem1_C:OnDeactive()
end

return UMG_RelationTree_ListItem1_C
