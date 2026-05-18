local Base = _G.NRCUmgClass
local UMG_LuaItem_C = Base:Extend("UMG_LuaItem_C")

function UMG_LuaItem_C:Ctor()
  Base.Ctor(self)
end

function UMG_LuaItem_C:Construct()
  self.Toggle.OnCheckStateChanged:Add(self, self.OnToggle)
end

function UMG_LuaItem_C:Destruct()
  self.Payload = nil
  self.Toggle.OnCheckStateChanged:Remove(self, self.OnToggle)
end

function UMG_LuaItem_C:IsInstance()
  return rawget(self.Payload, "class") == self.Payload
end

function UMG_LuaItem_C:OnToggle()
  if self.Toggle:GetCheckedState() == UE4.ECheckBoxState.Checked then
    self.ValueContainer:SetVisibility(UE4.ESlateVisibility.Visible)
    if 0 == self.ValueContainer:GetChildrenCount() then
      if not self.Payload then
        return
      end
      local IsInstance = self:IsInstance()
      for k, v in pairs(self.Payload) do
        if IsInstance then
          if "class" == k then
            goto lbl_142
          elseif "_eventDispatcher" == k then
            goto lbl_142
          elseif "Super" == k then
            goto lbl_142
          elseif "InstanceOf" == k then
            goto lbl_142
          elseif "__call" == k then
            goto lbl_142
          elseif "__index" == k then
            goto lbl_142
          elseif "__newindex" == k then
            goto lbl_142
          elseif "InstanceOf" == k then
            goto lbl_142
          elseif "SubclassOf" == k then
            goto lbl_142
          elseif "Initialize" == k then
            goto lbl_142
          elseif "New" == k then
            goto lbl_142
          elseif "Extend" == k then
            goto lbl_142
          elseif "SendEvent" == k then
            goto lbl_142
          elseif "HasListener" == k then
            goto lbl_142
          elseif "AddEventListener" == k then
            goto lbl_142
          elseif "RemoveEventListener" == k then
            goto lbl_142
          elseif "RemoveAllListeners" == k then
            goto lbl_142
          elseif "RemoveListeners" == k then
            goto lbl_142
          elseif "className" == k then
            if not string.IsNilOrEmpty(v) and rawget(self.Payload, "name") == v then
              goto lbl_142
            end
          elseif "name" == k and not string.IsNilOrEmpty(v) and rawget(self.Payload, "className") == v then
            goto lbl_142
          end
        end
        self:MakeChild(k, v, self.Depth + 1)
        ::lbl_142::
      end
    end
  else
    self.ValueContainer:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LuaItem_C:MakeChild(Name, Data, Depth)
  local Widget = UE4.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("/Game/NewRoco/Modules/System/Debug/Res/UMG_LuaItem"))
  self.ValueContainer:AddChild(Widget)
  Widget:SetData(Name, Data, Depth)
  return Widget
end

function UMG_LuaItem_C:SetData(Name, Data, Depth)
  self.Key:SetText(tostring(Name))
  if nil == Data then
    self.Toggle:SetVisibility(UE4.ESlateVisibility.Collapsed)
    return
  end
  self.Depth = Depth or 0
  local Type = type(Data)
  if "table" == Type then
    self.Payload = Data
    if self:IsInstance() then
      local className = self.Payload.className
      if string.IsNilOrEmpty(className) then
        self.Key:SetText(string.format("%s/(UnknownClass)", Name))
      else
        self.Key:SetText(string.format("%s/(%s)", Name, className))
      end
    else
      self.Payload = _G.BinDataUtils.BinDataUnboxing(Data, true)
    end
    if 0 == self.Depth then
      self.Toggle:SetCheckedState(UE4.ECheckBoxState.Checked)
    end
    self:OnToggle()
  else
    self:MakeChild(Data, nil, self.Depth + 1)
    self.Toggle:SetVisibility(UE4.ESlateVisibility.Collapsed)
  end
end

function UMG_LuaItem_C:ClearChildren()
  self.ValueContainer:ClearChildren()
end

return UMG_LuaItem_C
