# @summary Manage an address match list
#
# @api private
#
# @example Using the defined type
#
#   bind::aml { 'blackhole':
#     address_match_list => [ '127.0.0.1', '!any' ],
#     target             => 'named.conf.options',
#     order              => '50',
#   }
#
# @param address_match_list
#   The address match list to use.
#
# @param target
#   The concat target where this fragment will be included.
#
# @param order
#   The position where this fragment will be included in the concat target.
#
# @param omit_empty_list
#   Should an option item be omitted from the config if it has an empty
#   list. For some options (e.g. forwarders) it makes sense to include them
#   even with an empty address match list.
#
# @param indent
#   The indent prefix used for each line.
#
# @param item
#   The name of the address match list.
#
# @param comment
#   An optional string that is used as comment in the generated file.
#
#
define bind::aml (
  Bind::AddressMatchList $address_match_list,
  String                 $target,
  String                 $order,
  Boolean                $initial_empty_line = false,
  Boolean                $final_empty_line   = true,
  Boolean                $omit_empty_list    = false,
  String                 $indent             = '  ',
  String                 $item               = $name,
  Optional[String]       $comment            = undef,
) {
  # Convert parameter to an array and strip spaces from items
  $list1 = $address_match_list ? {
    ''      => [],
    String  => [strip($address_match_list)],
    default => strip($address_match_list)
  }

  # Filter undefined and empty items
  $list2 = $list1.filter |$val| { $val =~ NotUndef and !empty($val) }

  $params = {
    item               => $item,
    comment            => $comment,
    address_match_list => $list2,
    indent             => $indent,
    initial_empty_line => $initial_empty_line,
    final_empty_line   => $final_empty_line,
  }

  unless ($omit_empty_list and empty($list2)) {
    concat::fragment { "bind::${target}::${title}":
      target  => $target,
      order   => $order,
      content => epp("${module_name}/aml.epp", $params),
    }
  }
}
