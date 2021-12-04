# Type to match allowed values for DNSSEC key algorithms
type Bind::DNSSEC::Algorithm = Enum[
  'dsa', 'eccgost', 'ecdsap256sha256', 'ecdsap384sha384', 'ed25519', 'ed448',
  'nsec3dsa', 'nsec3rsasha1', 'rsamd5', 'rsasha1', 'rsasha256', 'rsasha512',
]
