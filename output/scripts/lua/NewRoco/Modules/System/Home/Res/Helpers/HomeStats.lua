local HomeStats = Class("HomeStats")

function HomeStats:Ctor()
  self.ComfortValView = nil
  self.RoomNameView = nil
  self.AddComfortValView = nil
end

function HomeStats:BindComfortValView(ComfortValView)
  self.ComfortValView = ComfortValView
end

function HomeStats:BindAddComfortValView(AddComfortValView)
  self.AddComfortValView = AddComfortValView
  self.AddComfortValView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function HomeStats:BindRoomNameView(RoomNameView)
  self.RoomNameView = RoomNameView
end

function HomeStats:ResolveComfort(PropsData, DiffValue)
  if self.ComfortValView then
    self.ComfortValView:SetText(tostring(HomeIndoorSandbox.Server.WorldData.HomeComfortLevel or 0))
  end
  if self.AddComfortValView then
    if not PropsData or DiffValue and 0 == DiffValue then
      self.AddComfortValView:SetText("")
    elseif not DiffValue or DiffValue > 0 then
      self.AddComfortValView:SetText("+" .. (DiffValue or PropsData:GetComfortVal() or 0))
      self.AddComfortValView:SetColorAndOpacity(HomeIndoorSandbox.Enum.Color_ComfortInc)
    elseif DiffValue < 0 then
      self.AddComfortValView:SetText("-" .. DiffValue)
      self.AddComfortValView:SetColorAndOpacity(HomeIndoorSandbox.Enum.Color_ComfortDec)
    end
  end
end

function HomeStats:ResolveRoomName()
  local RoomName = ""
  local EditRoom = HomeIndoorSandbox.HomeEditServ:GetEditRoom()
  if EditRoom then
    local RoomData = EditRoom:GetRoomData()
    RoomName = RoomData.RoomName or ""
  end
  if self.RoomNameView then
    self.RoomNameView:SetText(RoomName)
  end
  return RoomName
end

return HomeStats
