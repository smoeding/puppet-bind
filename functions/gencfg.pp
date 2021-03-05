# @summary Generate a configuration snippet from a hash
#
# Generate a Bind configuration snippet from a hash.  Each key of the hash is
# used as a config option.  The can be a string, a numeric value, a boolean or
# an array or hash.  the config option is terminated with a ';' char.
#
# String and numeric value are used normally.  A boolean value is returned as
# 'yes' or 'no'.  Arrays are enclosed in braces and array values are returned
# as a single line if the number of elements is zero or one.  Otherwise a new
# line is used for each value.  Hashes are also enclosed in braces and the
# keys and values are processed recursively.
#
# @private
#
# @param config [Hash[String,Data]] A hash with the configuration items.  For
#   each key the name of the key and the value are generated in Bind9 config
#   file syntax.  Values may be Booleans, Numbers, Strings, Arrays and other
#   Hashes.
#
# @param indent [Integer] The number of space characters to use as indentation
#   for each line.  The default value is 0; in this case no indentation is
#   used.
#
# @return [String] The config in Bind9 syntax.
#
function bind::gencfg(Hash[String,Data] $config, Integer $indent = 0) >> String {
  # base indentation
  $space = sprintf('%*s', $indent, '')

  # use string length of longest hash key for alignment
  $align = $config.reduce(0) |$memo, $item| { max($memo, $item[0].length) }

  $config.reduce('') |$memo, $item| {
    case $item[1] {
      Boolean: {
        # Convert boolean values to 'yes' or 'no'
        sprintf("%s%s%*s %s;\n", $memo, $space, -$align, $item[0], bool2str($item[1], 'yes', 'no'))
      }

      Array: {
        # If the array has zero or one element, then the result is written on
        # the same line as the option.  Otherwise a new line is used for every
        # array element and the array elements are indented by two additional
        # spaces.
        if ($item[1].length <= 1) {
          $param = $item[1].reduce(' ') |$memo, $elt| {
            "${memo}${elt}; "
          }
        }
        else {
          $param = $item[1].reduce("\n${space}") |$memo, $elt| {
            "${memo}  ${elt};\n${space}"
          }
        }
        sprintf("%s%s%*s {%s};\n", $memo, $space, -$align, $item[0], $param)
      }

      Hash: {
        # Hash parameters are generated recursively using more indentation.
        $param = bind::gencfg($item[1], $indent + 2)
        sprintf("%s%s%*s {\n%s%s};\n", $memo, $space, -$align, $item[0], $param, $space)
      }

      default: {
        sprintf("%s%s%*s %s;\n", $memo, $space, -$align, $item[0], String($item[1]))
      }
    }
  }
}
