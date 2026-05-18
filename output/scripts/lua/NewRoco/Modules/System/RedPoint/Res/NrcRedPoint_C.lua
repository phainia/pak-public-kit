local RedPointUtils = require("NewRoco.Modules.System.RedPoint.RedPointUtils")
local NrcRedPoint_C = _G.NRCUmgClass:Extend("NrcRedPoint_C")

function NrcRedPoint_C:OnConstruct()
  self.Overridden.Construct(self)
  self.RedPointImagePath = {
    [Enum.RedPointType.RPT_COMMON] = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_red_dian_png.img_red_dian_png'",
    [Enum.RedPointType.RPT_NEW] = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_red_xin_png.img_red_xin_png'",
    [Enum.RedPointType.RPT_AWARD] = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_red_liwu_png.img_red_liwu_png'",
    [Enum.RedPointType.RPT_NUMBER] = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_red_shuzi_png.img_red_shuzi_png'",
    [Enum.RedPointType.RPT_EGG] = "PaperSprite'/Game/NewRoco/Modules/System/Common/CommonStatic/Frames/img_red_Egg_png.img_red_Egg_png'"
  }
  self:Register()
end

function NrcRedPoint_C:OnDestruct()
  self:CancelPlayLoopAnim()
  self:UnRegister()
end

function NrcRedPoint_C:Register()
  if 0 == self.Key then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.RegRedPointUI, self)
end

function NrcRedPoint_C:UnRegister()
  if _G.RedPointModuleCmd then
    _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.UnRegRedPointUI, self)
  end
end

function NrcRedPoint_C:GetKey()
  return self.Key
end

function NrcRedPoint_C:IsRed()
  return self.isRed or false
end

function NrcRedPoint_C:SetRed(isRed)
  local preRed = self.isRed
  self.isRed = isRed
  if preRed ~= isRed and self.redStatusChangeCallback then
    self.redStatusChangeCallback(self, isRed)
  end
end

function NrcRedPoint_C:SetRedStatusChangeListener(caller, func, ...)
  if nil == func then
    self.redStatusChangeCallback = nil
  else
    self.redStatusChangeCallback = _G.MakeWeakFunctor(caller, func, ...)
  end
end

local function _ExtraKeyEqual(a, b)
  if a == b then
    return true
  end
  if type(a) == "table" and type(b) == "table" then
    if #a ~= #b then
      return false
    end
    for i = 1, #a do
      if a[i] ~= b[i] then
        return false
      end
    end
    return true
  end
  return false
end

local function _ConvertExtraKey(extraKey)
  if type(extraKey) == "table" then
    local t = {}
    for i, value in ipairs(extraKey) do
      if type(value) == "number" then
        value = tostring(value)
      end
      t[1 + #t] = value
    end
    return t
  elseif type(extraKey) == "number" then
    return tostring(extraKey)
  end
  return extraKey
end

function NrcRedPoint_C:SetupKey(key, extraKey, extrakeyTable, HideReason)
  if nil == extraKey and self.Key == key and nil == extrakeyTable or self.Key == key and extraKey and (self.OriExtraKey == extraKey or _ExtraKeyEqual(self.OriExtraKey, extraKey)) then
    return
  end
  if type(extraKey) ~= "table" then
    extraKey = {extraKey}
  end
  self:UnRegister()
  self.Key = key or 0
  self.HideReason = HideReason
  self.OriExtraKey = extraKey
  self.ExtraKey = _ConvertExtraKey(extraKey)
  if extrakeyTable then
    self.ExtraKeyTable = {}
    for i, extraKey in ipairs(extrakeyTable) do
      local newExtraKey = _ConvertExtraKey(extraKey)
      table.insert(self.ExtraKeyTable, newExtraKey)
    end
  end
  if 0 == self.Key then
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
  self:Register()
end

function NrcRedPoint_C:ActiveKey()
  self.active = true
end

function NrcRedPoint_C:DeactiveKey()
  self.active = false
end

function NrcRedPoint_C:EraseRedPoint(firstMatchFlag)
  if not (0 ~= self.Key and self.isRed) or self.rpNode == nil or nil == next(self.rpNode.litUpReasonDic) then
    return
  end
  _G.NRCModuleManager:DoCmd(_G.RedPointModuleCmd.EraseRedPoint, self.Key, self.ExtraKey, firstMatchFlag)
end

function NrcRedPoint_C:SetRpNode(rpNode)
  self.rpNode = rpNode
end

function NrcRedPoint_C:Refresh()
  if self.rpNode == nil then
    self:SetRed(false)
    self:ShowRedPoint(false)
    return
  end
  local isRed = false
  local numInfo
  if self.ExtraKey and #self.ExtraKey > 0 then
    isRed, numInfo = RedPointUtils.AdvCheckIsRed(self.rpNode, self.ExtraKey)
  elseif self.ExtraKeyTable and #self.ExtraKeyTable > 0 then
    isRed = RedPointUtils.AdvCheckIsRedByExtraKeyTable(self.rpNode, self.ExtraKeyTable)
  else
    if self.HideReason then
      local HideCount = self.rpNode.popReasonDic and self.rpNode.popReasonDic[self.HideReason] and self.rpNode.popReasonDic[self.HideReason].oriPointData and #self.rpNode.popReasonDic[self.HideReason].oriPointData or 0
      isRed = self.rpNode.redCount - HideCount > 0
    else
      isRed = self.rpNode.redCount > 0
    end
    if self.rpNode.numInfo then
      numInfo = self.rpNode.numInfo
    end
  end
  local preIsRead = self.isRed
  self:SetRed(isRed)
  self:ShowRedPoint(isRed)
  local _SearchSonNodeRedPointType = function(rpNode, redPointTypeTable, rpCfgs, RedPointNodeDic)
    for _, fromKey in pairs(rpNode.popFromDic) do
      local cfg = rpCfgs[fromKey]
      local fromNode = RedPointNodeDic[fromKey]
      local redpoint_type = tonumber(cfg.redpoint_type[1])
      local num = 0
      local isLeafNode = false
      for _, p in pairs(fromNode.litUpReasonDic) do
        isLeafNode = true
        local pCount = p and #p.oriPointData or 0
        num = num + pCount
      end
      if isLeafNode then
        if 0 ~= num and redpoint_type then
          table.insert(redPointTypeTable, redpoint_type)
        end
      else
        _SearchSonNodeRedPointType(fromNode, redPointTypeTable, rpCfgs, RedPointNodeDic)
      end
    end
  end
  local _SearchSonNodeRedPointTypeByExtraKey = function(rpNode, redPointTypeTable, rpCfgs, RedPointNodeDic, extraKey)
    for _, fromKey in pairs(rpNode.popFromDic) do
      local cfg = rpCfgs[fromKey]
      local fromNode = RedPointNodeDic[fromKey]
      local redpoint_type = tonumber(cfg.redpoint_type[1])
      local isLeafNode = false
      local hasMatchPoint = false
      for _, p in pairs(fromNode.litUpReasonDic) do
        isLeafNode = true
        if p.splitPointData == nil then
          p.splitPointData = {}
          for i, v in pairs(p.oriPointData) do
            p.splitPointData[i] = p.splitFunc(v)
          end
        end
        local splitPointData = p.splitPointData
        for _, exKey in pairs(splitPointData) do
          local Match = true
          for i, value in ipairs(extraKey) do
            if value ~= exKey[i] then
              Match = false
              break
            end
          end
          if true == Match then
            hasMatchPoint = true
            break
          end
        end
      end
      if isLeafNode then
        if hasMatchPoint and redpoint_type then
          table.insert(redPointTypeTable, redpoint_type)
        end
      else
        _SearchSonNodeRedPointTypeByExtraKey(fromNode, redPointTypeTable, rpCfgs, RedPointNodeDic, extraKey)
      end
    end
  end
  self.module = NRCModuleManager:GetModule("RedPointModule")
  local RedPointNodeDic = self.module.data:GetRedPointNodeDic()
  local rpCfgs = NRCModuleManager:DoCmd(RedPointModuleCmd.GetRedPointCfgs)
  self.rpNode.redPointTypeTable = {}
  if self.ExtraKey and #self.ExtraKey > 0 then
    _SearchSonNodeRedPointTypeByExtraKey(self.rpNode, self.rpNode.redPointTypeTable, rpCfgs, RedPointNodeDic, self.ExtraKey)
  elseif self.ExtraKeyTable and #self.ExtraKeyTable > 0 then
    for _, extraKey in pairs(self.ExtraKeyTable) do
      _SearchSonNodeRedPointTypeByExtraKey(self.rpNode, self.rpNode.redPointTypeTable, rpCfgs, RedPointNodeDic, extraKey)
    end
  else
    _SearchSonNodeRedPointType(self.rpNode, self.rpNode.redPointTypeTable, rpCfgs, RedPointNodeDic)
  end
  self:RefreshUITemplate(isRed, numInfo)
  if #self.rpNode.redPointTypeTable > 0 then
    self.useNewRedPoint = true
    self.loopAnim = self.Loop
    self.outAnim = self.Out
  end
  if NrcRedPoint_C.S_ShowDebug then
    self:ShowDebugInfo(NrcRedPoint_C.S_ShowDebug, NrcRedPoint_C.S_DebugDir)
    self:ChangeDebugInfoPostion(NrcRedPoint_C.S_PositionIdx)
    self:ChangeDebugInfoColor(NrcRedPoint_C.S_ColorIdx)
  end
  if self.enableAnim then
    self:StopAllAnimations()
    self:CancelPlayLoopAnim()
    if self.isRed then
      if not preIsRead then
        self:DoPlayNodeAnim(self.inAnim)
      end
      if 3 == self.RedPointIndex then
        self:DelayPlayLoopAnim(1)
      end
    elseif preIsRead then
      self:DoPlayNodeAnim(self.outAnim)
    end
  end
end

function NrcRedPoint_C:RefreshUITemplate(isRed, numInfo)
  if false == isRed then
    self.RedPointImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  local redPointUIIndex = 0
  if self.rpNode.redPointTypeTable then
    for _, val in ipairs(self.rpNode.redPointTypeTable) do
      if val > redPointUIIndex then
        redPointUIIndex = val
      end
    end
  end
  self.RedPointIndex = redPointUIIndex
  if self.rpNode.cfg.redpoint_type[1] then
    local num = tonumber(self.rpNode.cfg.redpoint_type[1])
    if num and self.RedPointIndex < 3 then
      self.RedPointIndex = num
    end
  end
  if not (0 == self.RedPointIndex or self.active) or numInfo and 0 ~= numInfo then
    self.RedPointNode:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self.RedPointImage:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    if numInfo and 0 ~= numInfo then
      self.RedPointImage:SetPath(self.RedPointImagePath[Enum.RedPointType.RPT_NUMBER])
      self.NumText:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
      if numInfo > 99 then
        self.NumText:SetText("99+")
      else
        self.NumText:SetText(numInfo)
      end
    elseif self.RedPointIndex == Enum.RedPointType.RPT_NEW then
      if NRCModuleManager:DoCmd(RedPointModuleCmd.CheckRpNodeIsLeaf, self.rpNode) then
        self.RedPointImage:SetPath(self.RedPointImagePath[Enum.RedPointType.RPT_NEW])
      else
        self.RedPointImage:SetPath(self.RedPointImagePath[Enum.RedPointType.RPT_COMMON])
      end
    else
      self.RedPointImage:SetPath(self.RedPointImagePath[self.RedPointIndex])
    end
  else
    self.RedPointNode:SetVisibility(UE4.ESlateVisibility.SelfHitTestInvisible)
    self.RedPointImage:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function NrcRedPoint_C:ShowRedPoint(bShow)
  if bShow and self.active then
    self:EraseRedPoint(true)
    self.RedPointNode:SetVisibility(UE4.ESlateVisibility.Collapsed)
    self:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  if self.RedPointNode then
    self.RedPointNode:SetVisibility(bShow and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self:SetVisibility(self.RedPointNode:GetVisibility())
  end
end

function NrcRedPoint_C:SetRedPointUIType(type, bShow)
  if self.RedPointImage and self.RedPointImagePath[type] then
    self.RedPointImage:SetPath(self.RedPointImagePath[type])
    self.RedPointImage:SetVisibility(bShow and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
    self:SetVisibility(self.RedPointImage:GetVisibility())
  end
end

function NrcRedPoint_C:FormatExtraKey(extraKey)
  if extraKey then
    if type(extraKey) ~= "string" then
      extraKey = tostring(extraKey)
    end
    return extraKey:gsub("^%s*(.-)%s*$", "%1")
  end
  return ""
end

function NrcRedPoint_C:EnableAnimation()
  self.useTemplateAnim = false
  if self.redPointInst then
    self.loopAnim = self.redPointInst.Loop
    self.outAnim = self.redPointInst.Out
    self.inAnim = self.redPointInst.In
    if self.loopAnim or self.outAnim then
      self.useTemplateAnim = true
      if self.loopAnim then
        self.redPointInst:BindToAnimationFinished(self.loopAnim, {
          self,
          self.OnLoopAnimFinished
        })
      end
    end
  end
  if not self.useTemplateAnim then
    self.loopAnim = self.Loop
    self.outAnim = self.Out
    self.inAnim = self.In
  end
  self.enableAnim = not not self.loopAnim or not not self.outAnim or not not self.inAnim
end

function NrcRedPoint_C:DoPlayNodeAnim(_anim)
  if not self or not UE4.UObject.IsValid(self) then
    return
  end
  if _anim then
    if self.useTemplateAnim and not self.useNewRedPoint then
      self.redPointInst:PlayAnimation(_anim)
    else
      self:PlayAnimation(_anim)
    end
  end
end

function NrcRedPoint_C:DelayPlayLoopAnim(delaySeconds)
  if self.loopAnim then
    self:CancelPlayLoopAnim()
    self.loopAnimDelayId = _G.DelayManager:DelaySeconds(delaySeconds or 8, self.OnDelayPlayLoopAnim, self)
  end
end

function NrcRedPoint_C:OnDelayPlayLoopAnim()
  self.loopAnimDelayId = nil
  if self.loopAnim then
    self:DoPlayNodeAnim(self.loopAnim)
  end
end

function NrcRedPoint_C:OnLoopAnimFinished()
  if self:IsRed() then
    self:DelayPlayLoopAnim()
  end
end

function NrcRedPoint_C:OnAnimationFinished(anim)
  if anim == self.loopAnim then
    self:OnLoopAnimFinished()
  end
end

function NrcRedPoint_C:CancelPlayLoopAnim()
  if self.loopAnimDelayId then
    _G.DelayManager:CancelDelayById(self.loopAnimDelayId)
    self.loopAnimDelayId = nil
  end
end

function NrcRedPoint_C:PlayRedPointAnimIn()
  self:StopAllAnimations()
  self:PlayAnimation(self.In)
end

function NrcRedPoint_C:PlayRedPointAnimOut()
  self:StopAllAnimations()
  self:PlayAnimation(self.Out)
end

function NrcRedPoint_C:ShowDebugInfo(bShow)
  NrcRedPoint_C.S_ShowDebug = bShow
  if self.DebugText == nil then
    self.DebugText = self:CreateDebugText()
    local font = self.DebugText.Font
    font.Size = 12
    self.DebugText:SetFont(font)
    local achors = UE4.FAnchors()
    achors.Minimum = UE4.FVector2D(0.5, 0.5)
    achors.Maximum = UE4.FVector2D(0.5, 0.5)
    self.DebugText.Slot:SetAutoSize(true)
    self.DebugText.Slot:SetAnchors(achors)
  end
  local str = ""
  if bShow then
    local t = {}
    local rpNode = self.rpNode
    if not rpNode then
      return
    end
    t[#t + 1] = "Key = [ " .. self.key .. " ]"
    if self.ExtraKey then
      if type(self.ExtraKey) == "table" then
        t[#t + 1] = "ExtraKey = [ " .. table.concat(self.ExtraKey, ",") .. " ]"
      else
        t[#t + 1] = "ExtraKey = [ " .. self.ExtraKey .. " ]"
      end
    end
    for reason, p in pairs(rpNode.litUpReasonDic) do
      local pCount = 0
      if self.ExtraKey and #self.ExtraKey > 0 then
        pCount = RedPointUtils.GetAdvRedCountInReasonData(p, self.ExtraKey, self.PointDataIdx)
      else
        pCount = p and #p.oriPointData or 0
      end
      t[#t + 1] = "Reason= " .. reason .. ", count  = " .. pCount
    end
    for reason, p in pairs(rpNode.popReasonDic) do
      local pCount = 0
      if self.ExtraKey and #self.ExtraKey > 0 then
        pCount = RedPointUtils.GetAdvRedCountInReasonData(p, self.ExtraKey, self.PointDataIdx)
      else
        pCount = p and #p.oriPointData or 0
      end
      t[#t + 1] = "PopReason= " .. reason .. ", count = " .. pCount .. ", PopKey= " .. rpNode.popFromDic[reason]
    end
    str = table.concat(t, "\n")
    Log.Debug(str)
  end
  self.DebugText:SetText(str)
  self.DebugText:SetVisibility(bShow and UE4.ESlateVisibility.HitTestInvisible or UE4.ESlateVisibility.Collapsed)
end

function NrcRedPoint_C:ChangeDebugInfoPostion(positionIdx)
  NrcRedPoint_C.S_PositionIdx = positionIdx
  if self.DebugText == nil or nil == positionIdx then
    return
  end
  if positionIdx then
    positionIdx = positionIdx % 4
    if 0 == positionIdx then
      self.DebugText.Slot:SetAlignment(UE4.FVector2D(0, 0.5))
      self.DebugText.Slot:SetPosition(UE4.FVector2D(20, 0))
    elseif 1 == positionIdx then
      self.DebugText.Slot:SetAlignment(UE4.FVector2D(0.5, 0))
      self.DebugText.Slot:SetPosition(UE4.FVector2D(0, 20))
    elseif 2 == positionIdx then
      self.DebugText.Slot:SetAlignment(UE4.FVector2D(1, 0.5))
      self.DebugText.Slot:SetPosition(UE4.FVector2D(-20, 0))
    elseif 3 == positionIdx then
      self.DebugText.Slot:SetAlignment(UE4.FVector2D(0.5, 1))
      self.DebugText.Slot:SetPosition(UE4.FVector2D(0, -20))
    end
  else
    self.DebugText.Slot:SetAlignment(UE4.FVector2D(0, 0.5))
    self.DebugText.Slot:SetPosition(UE4.FVector2D(20, 0))
  end
end

function NrcRedPoint_C:ChangeDebugInfoColor(colorIdx)
  NrcRedPoint_C.S_ColorIdx = colorIdx
  if self.DebugText == nil or nil == colorIdx then
    return
  end
  if colorIdx then
    colorIdx = colorIdx % 4
    if 0 == colorIdx then
      self.DebugText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ffffff"))
    elseif 1 == colorIdx then
      self.DebugText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#ff0000"))
    elseif 2 == colorIdx then
      self.DebugText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#00ff00"))
    elseif 3 == colorIdx then
      self.DebugText:SetColorAndOpacity(UE4.UNRCStatics.HexToSlateColor("#0000ff"))
    end
  end
end

return NrcRedPoint_C
