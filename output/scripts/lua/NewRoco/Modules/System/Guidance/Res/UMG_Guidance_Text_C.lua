local EnhancedInputModuleEvent = require("NewRoco.Modules.Core.EnhancedInput.EnhancedInputModuleEvent")
local UMG_Guidance_Text_C = _G.NRCPanelBase:Extend("UMG_Guidance_Text_C")

function UMG_Guidance_Text_C:OnConstruct()
  _G.NRCEventCenter:RegisterEvent(self.name, self, EnhancedInputModuleEvent.KeyMappingsChanged, self.KeyMappingsChanged)
end

function UMG_Guidance_Text_C:OnDestruct()
  _G.NRCEventCenter:UnRegisterEvent(self, EnhancedInputModuleEvent.KeyMappingsChanged, self.KeyMappingsChanged)
end

function UMG_Guidance_Text_C:KeyMappingsChanged()
  if not self.widgetToText then
    return
  end
  for widget, text in pairs(self.widgetToText) do
    self:InitElementText(widget, text)
  end
end

function UMG_Guidance_Text_C:SetText(text)
  text = text or ""
  if self.text then
    return
  end
  self.text = text
  local textElements = self:SplitAndExtract(text)
  if 0 == #textElements then
    self.First:Init("")
    return
  end
  self.widgetToText = {}
  self:InitElementText(self.First, textElements[1])
  self.widgetToText[self.First] = textElements[1]
  local elementClass = UE4.UGameplayStatics.GetObjectClass(self.First)
  for idx = 2, #textElements do
    local textElement = UE4.UWidgetBlueprintLibrary.Create(self, elementClass)
    if textElement then
      self:InitElementText(textElement, textElements[idx])
      self.Container:AddChild(textElement)
      local slot = textElement.Slot
      if slot then
        slot:SetVerticalAlignment(UE4.EVerticalAlignment.VAlign_Center)
      end
    end
    self.widgetToText[textElement] = textElements[idx]
  end
end

function UMG_Guidance_Text_C:SplitAndExtract(str)
  local result = {}
  local pos = 1
  while true do
    local startPos, endPos, keyValue = str:find("<key=(.-)>", pos)
    if not startPos then
      if pos <= #str then
        table.insert(result, str:sub(pos))
      end
      break
    end
    if pos < startPos then
      table.insert(result, str:sub(pos, startPos - 1))
    end
    table.insert(result, {isKey = true, val = keyValue})
    pos = endPos + 1
  end
  return result
end

function UMG_Guidance_Text_C:InitElementText(widget, text)
  if text.isKey == true and text.val then
    widget:Init(nil, text.val)
  else
    widget:Init(text)
  end
end

return UMG_Guidance_Text_C
