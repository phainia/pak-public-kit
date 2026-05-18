local WeeklyChallengeBattleModuleEnum = {}
local EnumMeta = {
  __index = function(t, k)
    local v = rawget(t, k)
    if not v then
      Log.ErrorFormat("\230\137\190\228\184\141\229\136\176\229\144\141\229\173\151\228\184\186%s\231\154\132\230\158\154\228\184\190", k)
    end
    return v
  end,
  __newindex = function(t, k, v)
    Log.ErrorFormat("\228\184\141\229\133\129\232\174\184\229\138\168\230\128\129\228\191\174\230\148\185\230\158\154\228\184\190\229\128\188%s", k)
  end
}
WeeklyChallengeBattleModuleEnum.PhotoMode = setmetatable({
  StopAtFirstFrame = 1,
  StopAtPercent = 2,
  PlayAtStart = 3
}, EnumMeta)
return WeeklyChallengeBattleModuleEnum
