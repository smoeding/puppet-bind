# Type to match allowed values for the key lifetime
type Bind::Key::Lifetime = Pattern[
  /^(-?)P(?=\d|T\d)(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)([DW]))?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$/,
  /\Aunlimited\Z/,
]
