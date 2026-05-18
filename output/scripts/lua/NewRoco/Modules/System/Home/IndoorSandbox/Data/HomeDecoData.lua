local HomeDecoData = Class("HomeDecoData")

function HomeDecoData:Ctor(ConfId, RoomId)
  self.ConfId = ConfId
  self.ItemGid = 0
  self.Conf = nil
  self.RoomId = RoomId
  self.bTempData = nil
end

function HomeDecoData:Serialize()
  if not HomeIndoorSandbox:Ensure(0 ~= self.ConfId, "invalid deco id") then
    return
  end
  local Table = {
    item_gid = self.ItemGid,
    config_id = self.ConfId
  }
  return Table
end

function HomeDecoData:Deserialize(Table)
  self.ConfId = Table.config_id or 0
  self.ItemGid = Table.item_gid or 0
  if HomeIndoorSandbox:Ensure(0 ~= self.ConfId, "invalid deco id") then
    self.Conf = DataConfigManager:GetInteriorFinishConf(self.ConfId)
  end
end

function HomeDecoData:ResolveWorldRoom()
  return HomeIndoorSandbox.World:GetRoomById(self.RoomId)
end

function HomeDecoData:GetConfigMainType()
  return self.Conf.type
end

function HomeDecoData:Save()
  self.bTempData = false
end

function HomeDecoData:IsNeedRecover()
  return self.bTempData
end

function HomeDecoData:GetName()
  return self.Conf and self.Conf.name or 0
end

function HomeDecoData:GetComfortVal()
  return self.Conf and self.Conf.comfort or 0
end

function HomeDecoData:GetTabConf()
  if self.Conf then
    local Conf = DataConfigManager:GetFurnitureClassificationConf(self.Conf.classification)
    return Conf
  end
end

return HomeDecoData
