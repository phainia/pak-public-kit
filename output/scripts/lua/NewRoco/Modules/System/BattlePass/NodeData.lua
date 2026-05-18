local NodeData = {}

function NodeData:New()
  local obj = {
    petbaseId = 0,
    parentbaseIds = {},
    evolutionStage = 1,
    pos = UE.FVector2D(0, 0),
    unLock = false,
    isBoss = false
  }
  setmetatable(obj, {__index = NodeData})
  return obj
end

function NodeData:GetPetbascConf()
  return _G.DataConfigManager:GetPetbaseConf(self.petbaseId)
end

function NodeData:GetPetIconPath(isShining)
  local conf = self:GetPetbascConf()
  if conf then
    local modelId = conf.model_conf
    local modelConf = _G.DataConfigManager:GetModelConf(modelId)
    if modelConf then
      if isShining then
        return NRCUtils:FormatConfIconPath(modelConf.shiny_icon, _G.UIIconPath.HeadIconPath)
      else
        return modelConf.icon
      end
    end
  end
  return nil
end

function NodeData:GetHandbookState()
  if self.unLock then
    return _G.ProtoEnum.PetHandbookStatus.PHS_COLLECTED
  end
  local state = _G.NRCModuleManager:DoCmd(_G.HandbookModuleCmd.GetPetState, self.petbaseId)
  return state
end

function NodeData:SetPos(x, y)
  self.pos.X = x
  self.pos.Y = y
end

function NodeData:GetPos()
  return self.pos
end

function NodeData:SetIsBoss(isBoss)
  self.isBoss = isBoss
end

return NodeData
