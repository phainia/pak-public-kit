local FieldTagManager = Class()

function FieldTagManager:Ctor()
  self.Caches = {}
  self.CellSize = 50
  self.MinX = 0
  self.MinY = 0
  self.MaxX = 0
  self.MaxY = 0
end

function FieldTagManager:InitParams()
  local File = string.format("%sDots/EnvInfo/L_Bigworld_01/L_Bigworld_01_Bound.obj", UE4.UBlueprintPathsLibrary.ProjectContentDir())
  File = UE4.UBlueprintPathsLibrary.ConvertRelativePathToFull(File)
  local Result, Success = UE4.UNRCStatics.LoadToString(File)
  if Success then
    local lines = string.split(Result, "\n")
    local TheLine
    for _, Line in ipairs(lines) do
      if string.sub(Line, 0, 2) == "s " then
        TheLine = Line
      end
    end
    if TheLine then
      local Numbers = string.split(TheLine, " ")
      self.MinX = tonumber(Numbers[2])
      self.MinY = tonumber(Numbers[3])
      self.MaxX = tonumber(Numbers[5])
      self.MaxY = tonumber(Numbers[6])
      Log.Debug("Init Field Tag Params", self.MinX, self.MinY, self.MaxX, self.MaxY)
    else
      Log.Error("no line at all")
    end
  end
end

function FieldTagManager:Consume(Info)
  local AuraID = Info.id
  local Action = self.Caches[AuraID]
  if not Action then
    return
  end
  self.Caches[AuraID] = nil
  return Action
end

function FieldTagManager:Update(Action)
  self.Caches[Action.aura_id] = Action
end

return FieldTagManager
