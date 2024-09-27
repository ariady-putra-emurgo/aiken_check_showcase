use aiken/builtin
use aiken/collection/list
use aiken/fuzz
use aiken/primitive/bytearray
use aiken/primitive/int
use modules/functions

test property_test_bool(b via fuzz.bool()) {
  (b || !b)?
}

test property_test_bytearray(bs via fuzz.bytearray()) {
  // `|>` (pipe) Operator
  // https://aiken-lang.org/language-tour/control-flow#piping
  // this makes it looks like OOP
  let len = bs |> builtin.length_of_bytearray
  let hex =
    bs
      |> bytearray.to_hex
      |> bytearray.from_string
      |> builtin.length_of_bytearray

  // hex length must always be twice the original bytearray
  (hex == len * 2)?
}

test property_test_label(b8 via fuzz.byte()) {
  // eg. we want to see the random distribution percentage
  fuzz.label(
    if b8 |> functions.is_even {
      @"Even"
    } else {
      @"Odd"
    },
  )

  (b8 - b8 == 0)?
}

test property_test_associativity(ls: List<Int> via fuzz.list(fuzz.int())) {
  let fr = ls |> list.foldr(0, builtin.add_integer)
  let fl = ls |> list.foldl(0, builtin.add_integer)

  (fr == fl)?
}

test property_test_fail_all(bs via fuzz.bytearray_between(1, 3)) fail {
  let len = bs |> builtin.length_of_bytearray

  fuzz.label(len |> int.to_string)

  (len > 3)?
}

test property_test_fail_once(i via fuzz.int()) fail once {
  (i >= 0)?
}
