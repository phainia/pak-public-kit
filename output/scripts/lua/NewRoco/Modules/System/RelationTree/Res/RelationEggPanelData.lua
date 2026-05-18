local RelationEggPanelData = NRCClass()
RelationEggPanelData.EggPanelType = {Bless = 0, Presentation = 1}

function RelationEggPanelData:Ctor()
  EventDispatcher():Attach(self)
  self.panelType = RelationEggPanelData.EggPanelType.Bless
  self.argData = nil
end

function RelationEggPanelData:SetArgData(data)
  self.argData = data
  return self
end

function RelationEggPanelData:SetType(type)
  self.panelType = type
  return self
end

return RelationEggPanelData
