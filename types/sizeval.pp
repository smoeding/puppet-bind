# Type to match a memory size value
type Bind::Sizeval = Variant[Integer,Pattern[/\A\d+[kKmMgG]?\z/]]
