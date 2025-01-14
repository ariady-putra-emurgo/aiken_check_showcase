//// @hidden

use modules/functions
use test_kit.{print}

test unit_test_1() {
  // `and` Block
  // https://aiken-lang.org/language-tour/primitive-types#andor-keywords
  and {
    functions.add_1(1) == 2,
    functions.add_1(2) == 3,
    functions.add_1(3) == 4,
  }
}

test unit_test_2() {
  // `!` Negation / NOT
  // https://aiken-lang.org/language-tour/primitive-types#bool
  and {
    !functions.is_even(1),
    functions.is_even(2),
    !functions.is_even(3),
  }
}

// ## Troubleshooting
// https://aiken-lang.org/language-tour/troubleshooting

test traces() {
  // Traces
  // https://aiken-lang.org/language-tour/troubleshooting#traces
  trace @"Debug": 123
  True
}

test prints() {
  // use test_kit.{print}
  print("Debug", 123)
}
