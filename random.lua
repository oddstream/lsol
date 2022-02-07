-- class Random

--[[
  Creates a pseudo-random value generator. The seed must be an integer.

  Uses an optimized version of the Park-Miller PRNG.
  http://www.firstpr.com.au/dsp/rand31/

  https://gist.github.com/blixt/f17b47c62508be59987b
]]

local Random = {
    -- seed
  }
  Random.__index = Random

  function Random.new(seed)
    local o = {}
    setmetatable(o, Random)

    o.seed = seed % 2147483647
    if o.seed <= 0 then
      o.seed = o.seed + 2147483646
    end

    return o
  end

  function Random:next()
    -- Returns a pseudo-random value between 1 and 2^32 - 2
    self.seed = self.seed * 16807 % 2147483647
    return self.seed
  end

  function Random:nextFloat()
    -- Returns a pseudo-random floating point number in range [0, 1]
    return (self:next() - 1) / 2147483646
  end

  function Random:nextInt(min, max)
    -- Returns a random integer between min (inclusive) and max (inclusive)
    return math.floor(self:nextFloat() * (max - min + 1)) + min
  end

  return Random
