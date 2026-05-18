local MissileUtils = {}
MissileUtils.ComponentMap = {}

function MissileUtils:NewMissileData()
  return {
    MissileType = nil,
    NpcId = nil,
    AttachSocket = nil,
    NeedFollow = nil,
    OffsetTransform = nil,
    LifeTime = nil,
    InitSpeed = nil,
    AccelerateSpeed = nil,
    MaxSpeed = nil,
    AngleSpeed = nil,
    TraceTime = nil,
    CancelTraceDist = nil,
    IsKeepLandHeight = nil,
    LandHeight = nil,
    HitFX = nil,
    HitFXScale = nil,
    HitFxDuration = nil,
    IsHeavyAttack = nil,
    HitCD = nil,
    MaxBounceCount = nil,
    MaxPenetrateCount = nil,
    EffectRadius = nil,
    AddBuffId = nil,
    AddBuffDuration = nil,
    ExplodeFX = nil,
    ExplodeFXScale = nil,
    ExplodeFxDuration = nil,
    CreateConfigID = nil,
    LaunchConfigID = nil,
    FlyConfigID = nil,
    HitEnemyConfigID = nil,
    HitObstacleConfigID = nil,
    ImpactForce = nil,
    IsHitDestroy = nil,
    AttackPerformType = nil
  }
end

function MissileUtils:RegisterComponent(missileType, component)
  self.ComponentMap[missileType] = component
end

function MissileUtils:GetComponent(missileType)
  if not self.ComponentMap[missileType] then
    return nil
  end
  return rawget(self.ComponentMap, missileType)()
end

function MissileUtils:Example()
end

return MissileUtils
