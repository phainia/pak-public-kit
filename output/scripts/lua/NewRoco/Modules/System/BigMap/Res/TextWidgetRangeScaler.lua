local Config = {
  areaName2 = {
    font = {min = 55, max = 65},
    outline = {min = 2, max = 3}
  },
  RocoText = {
    font = {min = 18, max = 25},
    outline = {min = 3, max = 3}
  },
  areaName1 = {
    font = {min = 64, max = 70},
    outline = {min = 3, max = 3}
  },
  RocoText_2 = {
    font = {min = 18, max = 25},
    outline = {min = 3, max = 3}
  },
  areaName3 = {
    font = {min = 30, max = 37},
    outline = {min = 2, max = 3}
  },
  RocoText_4 = {
    font = {min = 20, max = 24},
    outline = {min = 3, max = 3}
  },
  areaName4 = {
    font = {min = 18, max = 38},
    outline = {min = 2, max = 3}
  },
  RocoText_6 = {
    font = {min = 18, max = 25},
    outline = {min = 3, max = 3}
  },
  areaName5 = {
    font = {min = 60, max = 64},
    outline = {min = 2, max = 3}
  }
}
local bDebugShowDetails = false
Config.areaName1_1 = Config.areaName1
Config.areaName2_1 = Config.areaName2
Config.areaName1_2 = Config.areaName3
Config.areaName1_3 = Config.areaName4
Config.areaName5_1 = Config.areaName5
Config.RocoText_1 = Config.RocoText
Config.RocoText_3 = Config.RocoText_2
Config.RocoText_5 = Config.RocoText_4
Config.RocoText_7 = Config.RocoText_6
local TextWidgetRangeScaler = Class("TextWidgetRangeScaler")

function TextWidgetRangeScaler:Ctor(inWidget)
  if inWidget and Config[inWidget:GetName()] then
    self.widget = inWidget
    self.widgetName = inWidget:GetName()
    self.initialState = {
      fontSize = inWidget.Font.Size,
      outlineSize = inWidget.Font.OutlineSettings.OutlineSize,
      text = nil
    }
  end
end

function TextWidgetRangeScaler:ChangeScale(scale, scaleRatio)
  if self.widget then
    local new_fontSize, new_outlinesize
    do
      local raw_fontSize = self.initialState.fontSize
      local raw_outlineSize = self.initialState.outlineSize
      new_fontSize = math.ceil(raw_fontSize * scale)
      new_outlinesize = raw_outlineSize / raw_fontSize * new_fontSize
      local conf = Config[self.widgetName]
      if conf then
        local font_range = math.abs(conf.font.min - conf.font.max)
        local font_size = math.ceil(conf.font.min + font_range * scaleRatio)
        new_fontSize = font_size
        local outline_range = math.ceil(math.abs(conf.outline.min - conf.outline.max))
        local outline_size = math.ceil(conf.outline.min + outline_range * scaleRatio)
        new_outlinesize = outline_size
      end
    end
    do
      local ModifiedFont = self.widget.Font
      ModifiedFont.Size = new_fontSize
      ModifiedFont.OutlineSettings.OutlineSize = new_outlinesize
      self.widget:SetFont(ModifiedFont)
    end
    if bDebugShowDetails then
      local text = self.widget:GetText()
      local name = self.widget:GetName()
      if text:sub(-1) ~= ")" then
        self.initialState.text = text
      else
        text = self.initialState.text
      end
      local debugText = string.format("%s[%d](%.2f)", text, self.widget.Font.Size, scale, name)
      self.widget:SetText(debugText)
    end
  end
end

return TextWidgetRangeScaler
