# Type to match the maximum cache size
type Bind::Cachesize = Variant[
  Enum['default', 'unlimited'], Bind::Sizeval, Bind::Percentage
]
