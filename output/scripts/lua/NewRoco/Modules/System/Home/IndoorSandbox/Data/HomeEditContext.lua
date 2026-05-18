local HomeEditContext = Class("HomeEditContext")

function HomeEditContext:Ctor(EditService)
  self.EditService = EditService
  self.Operations = {}
end

function HomeEditContext:OnActivate()
  local Room = self.EditService:GetEditRoom()
  self:ProcessRoomProps(Room)
end

function HomeEditContext:OnDeactivate(EditRoomId)
  local Room = HomeIndoorSandbox.World:GetRoomById(EditRoomId)
  self:ProcessRoomProps(Room)
end

function HomeEditContext:ProcessRoomProps(Room)
  if not Room then
    return
  end
  local Data = Room:GetRoomData()
  for i, PropsData in ipairs(Data:GetPropsDataList()) do
    self:ProcessProps(PropsData)
  end
end

function HomeEditContext:UnProcessRoomProps(Room)
  self:ProcessRoomProps(Room)
end

function HomeEditContext:OnToggleRoom(FromRoomId, ToRoomId)
  if 0 ~= FromRoomId then
    self:UnProcessRoomProps(HomeIndoorSandbox.World:GetRoomById(FromRoomId))
  end
  self:ProcessRoomProps(HomeIndoorSandbox.World:GetRoomById(ToRoomId))
end

function HomeEditContext:ProcessProps(PropsData)
  if not PropsData.PropsActor then
    return
  end
  local bInEditMode = self.EditService:InEditMode()
  if bInEditMode and PropsData.RoomId ~= self.EditService.EditRoomId then
    bInEditMode = false
  end
  self:InternalOperation(PropsData, bInEditMode)
end

function HomeEditContext:OnPropsCreated(PropsData)
  self:ProcessProps(PropsData)
end

function HomeEditContext:InternalOperation(PropsData, bInEditMode)
  for Type, Operation in pairs(self.Operations) do
    xpcall(Operation, function(Err)
      if not RocoEnv.IS_EDITOR then
        local Message = string.format("%s", Err)
        _G.NRCSDKManager:CrashSightReportExceptionWithReason("HomeError", Message, debug.traceback())
      else
        HomeIndoorSandbox:Ensure(false, Err)
      end
    end, PropsData, bInEditMode)
  end
end

function HomeEditContext:RegisterPropsOperation(Type, Operation)
  if self.EditService:InEditMode() then
    HomeIndoorSandbox:Ensure(false, "logical error")
    return
  end
  self.Operations[Type] = Operation
  Log.Debug("[Home] RegisterPropsOperation", Type, Operation)
end

function HomeEditContext:UnRegisterPropsOperation(Type)
  self.Operations[Type] = nil
  Log.Debug("[Home] UnRegisterPropsOperation", Type)
end

return HomeEditContext
