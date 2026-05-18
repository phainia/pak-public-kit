local TakePhotosUtils = require("NewRoco.Modules.System.TakePhotos.TakePhotosUtils")
local ActionPosePlayer = Class("ActionPosePlayer")

function ActionPosePlayer:Ctor(Player)
  self.Player = Player
  self.Conf = nil
  self.bMirror = nil
  self.ResourcePath = nil
  self:OnConstruct()
end

function ActionPosePlayer:OnConstruct()
  self.ResourceRequest = nil
end

function ActionPosePlayer:OnDestruct()
  self:StopAnim()
end

function ActionPosePlayer:PlayAnim(Conf, bMirror)
  if Conf == self.Conf and bMirror == self.bMirror then
    return
  end
  self:StopAnim()
  self:InternalPlayerByConf(Conf, bMirror)
end

function ActionPosePlayer:InternalPlayerByConf(Conf, bMirror)
  Log.Debug("[TakePhoto] InternalPlayerByConf", Conf.name)
  if not Conf then
    Log.Error("Logical Error!!!")
    return
  end
  self.Conf = Conf
  self.bMirror = bMirror
  local ResourcePath = self:ParseAnimationPath(Conf, bMirror)
  if ResourcePath and "" ~= ResourcePath then
    if ResourcePath ~= self.ResourcePath then
      self:InternalLoad(ResourcePath)
    elseif self.PlayingAnimation and UE.UObject.IsValid(self.PlayingAnimation) then
      self:InternalPlayerAnimation(self.PlayingAnimation)
    end
  end
end

function ActionPosePlayer:InternalLoad(Path)
  Log.Debug("[TakePhoto] InternalLoad", Path)
  self.ResourceRequest = NRCResourceManager:LoadResAsync(self, Path, 255, -1, self.OnLoadSuccess)
end

function ActionPosePlayer:OnLoadSuccess(Request, Asset)
  self.ResourceRequest = nil
  self.PlayingAnimation = Asset
  self.PlayingAnimationRef = Asset and UnLua.Ref(Asset)
  if Asset then
    self:InternalPlayerAnimation(Asset)
  end
end

function ActionPosePlayer:StopAnim()
  if self.ResourceRequest then
    NRCResourceManager:UnLoadRes(self.ResourceRequest)
    self.ResourceRequest = nil
  end
  if self.PlayingAnimation then
    self:InternalStopPlayAnimation(self.PlayingAnimation)
    self.PlayingAnimation = nil
    self.PlayingAnimationRef = nil
  end
  self.Conf = nil
  self.bMirror = nil
  self.ResourcePath = nil
end

function ActionPosePlayer:ParseAnimationPath(Conf, bMirror)
  local ResourcePath
  if 1 == self.Player.gender then
    if bMirror then
      ResourcePath = Conf.male_mirror_pose_path
    else
      ResourcePath = Conf.male_pose_path
    end
  elseif bMirror then
    ResourcePath = Conf.female_mirror_pose_path
  else
    ResourcePath = Conf.female_pose_path
  end
  return ResourcePath or ""
end

function ActionPosePlayer:InternalPlayerAnimation(Animation)
  TakePhotosUtils.EnablePlayerPoseAction(self.Player, self.Conf, Animation)
end

function ActionPosePlayer:InternalStopPlayAnimation(Animation)
  TakePhotosUtils.DisablePlayerPoseAction(self.Player, self.Conf, Animation)
end

return ActionPosePlayer
