local DummyTable = setmetatable({}, {
  __newindex = function()
    Log.Error("\231\166\129\230\173\162\229\134\153\229\133\165DummyTable\232\175\183\230\163\128\230\159\165\228\184\154\229\138\161\231\154\132\231\148\168\230\179\149")
  end,
  __call = function()
  end,
  __tostring = function()
    return "<Common.DummyTable>"
  end
})
return DummyTable
