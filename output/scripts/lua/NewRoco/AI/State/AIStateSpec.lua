local AIStateSpec = MakeSimpleClass("AIStateSpec")
AIStateSpec.RemoveReason = {
  Finalize = 1,
  Interrupt = 2,
  Expired = 3,
  Script = 4
}

function AIStateSpec:OnStateAdd(owner)
end

function AIStateSpec:OnStateRemoved(reason)
end

return AIStateSpec
