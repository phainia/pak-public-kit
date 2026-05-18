local SkillLoadProxy = _G.MakeSimpleClass("SkillLoadProxy")
local LoadType = {
  LoadClass = 1,
  LoadSkill = 2,
  LoadActionRes = 3
}

function SkillLoadProxy.LoadClass(skillPath, owner, callBack)
  local loader = SkillLoadProxy(LoadType.LoadClass, owner, callBack)
  loader.SkillPath = NRCUtils.FormatBlueprintAssetPath(skillPath)
  loader:LoadSkillClass()
  return loader
end

function SkillLoadProxy.LoadSkill(skillPath, Comp, owner, callBack, blackBoard)
  local loader = SkillLoadProxy(LoadType.LoadSkill, owner, callBack)
  loader.SkillPath = NRCUtils.FormatBlueprintAssetPath(skillPath)
  loader.SkillComp = Comp
  loader.blackBoard = blackBoard
  loader:LoadSkillObj()
  return loader
end

function SkillLoadProxy.LoadActionRes(skillObj, owner, callBack, blackBoard)
  local loader = SkillLoadProxy(LoadType.LoadActionRes, owner, callBack)
  loader.skillObj = skillObj
  loader.blackBoard = blackBoard
  loader:AsyncLoadActionRes()
  return loader
end

function SkillLoadProxy:Ctor(loadType, owner, callBack)
  self.loadType = loadType
  self.owner = owner
  self.callBack = callBack
end

function SkillLoadProxy:LoadSkillClass()
  if string.IsNilOrEmpty(self.SkillPath) then
    self:OnLoadSkillClassFailed()
  end
  _G.NRCResourceManager:LoadResAsync(self, self.SkillPath, 255, 0, self.OnLoadSkillClassSucceed, self.OnLoadSkillClassFailed)
end

function SkillLoadProxy:OnLoadSkillClassSucceed(Request, Klass)
  if not Klass then
    self:OnLoadSkillClassFailed()
  end
  if self.loadType == LoadType.LoadClass then
    if self.callBack then
      self.callBack(self.owner, Klass)
    end
  elseif self.loadType == LoadType.LoadSkill then
    if not UE4.UObject.IsValid(self.SkillComp) and self.callBack then
      Log.Error("SkillLoadProxy:OnLoadSkillClassFailed \230\138\128\232\131\189\231\187\132\228\187\182\228\184\186\231\169\186")
      self.callBack(self.owner)
    end
    self.skillObj = self.SkillComp:AddSkillObjFromClassAndReturn(Klass)
    if (not self.skillObj or not UE4.UObject.IsValid(self.skillObj)) and self.callBack then
      Log.Error("SkillLoadProxy:OnLoadSkillClassFailed \230\138\128\232\131\189\229\174\158\228\190\139\229\140\150\229\164\177\232\180\165")
      self.callBack(self.owner)
    end
    self:AsyncLoadActionRes()
  end
end

function SkillLoadProxy:OnLoadSkillClassFailed()
  if self.callBack then
    Log.Error("SkillLoadProxy:OnLoadSkillClassFailed \230\138\128\232\131\189\232\181\132\230\186\144\229\138\160\232\189\189\229\164\177\232\180\165", self.SkillPath)
    self.callBack(self.owner)
  end
end

function SkillLoadProxy:LoadSkillObj()
  self:LoadSkillClass()
end

function SkillLoadProxy:AsyncLoadActionRes()
  if self.blackBoard then
    local blackboard = self.skillObj:GetBlackboard()
    if blackboard and UE.UObject.IsValid(blackboard) then
      for i, v in pairs(self.blackBoard) do
        blackboard:SetValueAsString(i, v)
      end
    end
  end
  self.skillObj:RegisterEventCallback("OnAsyncLoadActionEnd", self, self.OnActionLoadEnd)
  self.skillObj:StartAsyncLoading()
end

function SkillLoadProxy:OnActionLoadEnd()
  if self.callBack then
    self.callBack(self.owner, self.skillObj)
  end
end

return SkillLoadProxy
