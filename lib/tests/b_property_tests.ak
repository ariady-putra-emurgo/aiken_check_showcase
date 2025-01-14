//// @hidden

use aiken/builtin
use aiken/collection/list
use aiken/crypto.{Blake2b_224, Hash}
use aiken/fuzz
use aiken/primitive/bytearray
use aiken/primitive/int
use cardano/address.{Credential, Script, VerificationKey}
use cardano/assets
use cardano/transaction
use modules/functions
use test_kit.{print}
use test_kit/fuzzy
use test_kit/fuzzy/fuzzer.{
  FromFuzzed, FromScript, Fuzzed, WithTheSameDelegationScriptOrKey,
  address_fuzzer, credential_fuzzer, output_reference_fuzzer,
  verification_key_hash_fuzzer,
}
use test_kit/tx.{
  add_asset_to_tx_output, add_signatory, add_tx_input, add_tx_output,
  with_asset_of_tx_input,
}

test prop_bool(b via fuzz.bool()) {
  b || !b
}

test prop_bytearray(bs via fuzz.bytearray()) {
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
  hex == len * 2
}

test prop_label(b8 via fuzz.byte()) {
  // eg. we want to see the random distribution percentage
  fuzz.label(
    if b8 |> functions.is_even {
      @"Even"
    } else {
      @"Odd"
    },
  )

  b8 - b8 == 0
}

test prop_associativity(ls: List<Int> via fuzz.list(fuzz.int())) {
  let fr = ls |> list.foldr(0, builtin.add_integer)
  let fl = ls |> list.foldl(0, builtin.add_integer)

  fr == fl
}

test prop_fail_all(bs via fuzz.bytearray_between(1, 3)) fail {
  let len = bs |> builtin.length_of_bytearray

  fuzz.label(len |> int.to_string)

  len > 3
}

test prop_fail_once(i via fuzz.int()) fail once {
  i >= 0
}

// ## Custom fuzzers

fn fuzz_credential(hash: Hash<Blake2b_224, ByteArray>) -> Fuzzer<Credential> {
  fuzz.either(fuzz.constant(Script(hash)), fuzz.constant(VerificationKey(hash)))
}

// ### Composing fuzzers
// https://aiken-lang.org/language-tour/tests#composing-fuzzers

test prop_composing_fuzzers(
  credential via fuzz.and_then(fuzz.bytearray_fixed(28), fuzz_credential),
) {
  // test_kit.{print} also works with property testing
  // because it uses fuzz.label internally
  print("fuzz.Credential", credential)
}

// ### Use test_kit/fuzzy
// https://aiken-extra.github.io/test_kit/test_kit/fuzzy/fuzzer.html

test prop_test_kit(credential via credential_fuzzer(FromFuzzed)) {
  print("test_kit.Credential", credential)
}

test prop_address_fuzzer(
  address via address_fuzzer(
    FromScript(Fuzzed),
    WithTheSameDelegationScriptOrKey,
  ),
) {
  print("MultiPurpose-Validator Address", address)
}

/// use test_kit/tx
/// https://aiken-extra.github.io/test_kit/test_kit/tx.html
test prop_transaction(
  ((sender_pkh, receiver_pkh), o_ref) via fuzzy.tuple(
    fuzzy.unique2(verification_key_hash_fuzzer()),
    output_reference_fuzzer(),
  ),
) {
  let tx_input =
    tx.new_tx_input(o_ref, address.from_verification_key(sender_pkh))
      |> with_asset_of_tx_input(assets.from_lovelace(30_000_000))

  let tx_output =
    tx.new_tx_output(address.from_verification_key(receiver_pkh))
      |> add_asset_to_tx_output(assets.from_lovelace(30_000_000))

  let tx =
    transaction.placeholder
      |> add_tx_input(tx_input)
      |> add_tx_output(tx_output)
      |> add_signatory(sender_pkh)
  print("Transaction", tx)
}
