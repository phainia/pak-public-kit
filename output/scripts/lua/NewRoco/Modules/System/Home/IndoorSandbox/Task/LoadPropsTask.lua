local PropsWorker = require("NewRoco/Modules/System/Home/IndoorSandbox/Worker/PropsWorker")
local Super = require("NewRoco/Modules/System/Home/IndoorSandbox/HomeTask")
local LoadPropsTask = Super:Extend("LoadPropsTask")

function LoadPropsTask:Ctor(PropsData, RoomId, OnResLoadFailed)
  Super.Ctor(self)
  self.RoomId = RoomId
  self.bResLoadFinish = false
  self.BlueprintClass = nil
  self.PropsData = PropsData
  self.bPropsEstablished = false
  self.bAsync = true
  self.OnResLoadFailed = OnResLoadFailed
  self.bInvalidConfig = not PropsData:IsValidConfig()
  local AssetPath = PropsData:GetBlueprintClassPath()
  if AssetPath then
    self.Request = HomeIndoorSandbox.ResMgr:ReqResource(FPartial(self.OnResLoad, self, AssetPath), AssetPath)
  end
end

function LoadPropsTask:OnClean()
  if self.Request then
    HomeIndoorSandbox.ResMgr:ReleaseResource(self.Request)
    self.Request = nil
  end
end

function LoadPropsTask:OnResLoad(AssetPath, BlueprintClass, Msg)
  if not BlueprintClass then
    HomeIndoorSandbox:Ensure(false, "cannot loaded furniture class " .. AssetPath)
    if not RocoEnv.IS_EDITOR then
      local Message = string.format("\230\151\160\230\179\149\229\138\160\232\189\189\232\181\132\228\186\167 AssetPath(%s), Msg(%s)", AssetPath, Msg)
      _G.NRCSDKManager:CrashSightReportExceptionWithReason("LoadPropsTask\229\188\130\229\184\184", Message, "")
    end
  end
  if not UE.UObject.IsValid(BlueprintClass) then
    BlueprintClass = nil
    HomeIndoorSandbox:Ensure(false, "invalid furniture class loaded " .. AssetPath)
    if not RocoEnv.IS_EDITOR then
      local Message = string.format("\232\181\132\228\186\167\230\151\160\230\149\136\228\186\134 AssetPath(%s), Msg(%s)", AssetPath, Msg)
      _G.NRCSDKManager:CrashSightReportExceptionWithReason("LoadPropsTask\229\188\130\229\184\184", Message, "")
    end
  end
  if BlueprintClass and (not BlueprintClass.IsChildOf or not BlueprintClass:IsChildOf(UE.ANRCHomePlacementActor)) then
    Msg = "Invalid furniture class=" .. (BlueprintClass.GetFullName and BlueprintClass:GetFullName())
    BlueprintClass = nil
    if not RocoEnv.IS_EDITOR then
      local Message = string.format("\232\181\132\228\186\167\231\177\187\229\158\139\228\184\141\230\152\175\229\174\182\229\133\183 AssetPath(%s), Msg(%s)", AssetPath, Msg)
      _G.NRCSDKManager:CrashSightReportExceptionWithReason("LoadPropsTask\229\188\130\229\184\184", Message, "")
    end
  end
  self.Request = nil
  self.bResLoadFinish = true
  self.BlueprintClass = BlueprintClass
  HomeIndoorSandbox:Ensure(BlueprintClass, Msg)
end

function LoadPropsTask:CheckFinish()
  if self.bInvalidConfig then
    if self.OnResLoadFailed then
      self.OnResLoadFailed(self.PropsData)
    end
    self:NotifyFinish()
    return
  end
  if self.bResLoadFinish then
    if not self.BlueprintClass then
      if self.OnResLoadFailed then
        self.OnResLoadFailed(self.PropsData)
      end
      return self:NotifyFinish()
    end
    if not self.Worker then
      self.Worker = PropsWorker(self)
    end
    if self.Worker:IsFinish() then
      HomeIndoorSandbox:LogInfo("end load props", self.PropsData.Id)
      self:NotifyFinish()
    end
  end
end

function LoadPropsTask:OnStart()
  HomeIndoorSandbox:LogInfo("start load props", self.PropsData.Id)
  return self:CheckFinish()
end

function LoadPropsTask:OnUpdate()
  return self:CheckFinish()
end

function LoadPropsTask:ToString()
  if self.DebugStr then
    return self.DebugStr
  end
  self.DebugStr = "LoadPropsTask:" .. self.PropsData.Id
  return self.DebugStr
end

return LoadPropsTask
