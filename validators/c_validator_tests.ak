//// @hidden

use aiken/builtin
use aiken/fuzz
use cardano/assets
use cardano/certificate.{DelegateBlockProduction, RegisterAndDelegateCredential}
use cardano/governance.{StakePool}
use cardano/script_context.{ScriptContext, Voting}
use cardano/transaction.{Transaction}
use showcase
use test_kit.{to_data}
use test_kit/fuzzy
use test_kit/fuzzy/fuzzer.{
  FromKey, Fuzzed, asset_name_fuzzer, credential_fuzzer, output_reference_fuzzer,
  policy_id_fuzzer, stake_pool_id_fuzzer, verification_key_hash_fuzzer,
}
use test_kit/tx.{add_mint}

test validator_test_mint(
  (policy_id, token_name) via fuzzy.tuple(
    policy_id_fuzzer(),
    asset_name_fuzzer(),
  ),
) {
  // Importing Validators
  // https://aiken-lang.org/language-tour/validators#importing-validators
  showcase.no_param.mint(
    42,
    policy_id,
    transaction.placeholder
      |> add_mint(assets.from_asset(policy_id, token_name, 42)),
  )
}

test validator_test_spend(o_ref via output_reference_fuzzer()) {
  and {
    showcase.no_param.spend(
      datum: Some(42 |> builtin.i_data),
      redeemer: Void,
      utxo: o_ref,
      tx: transaction.placeholder,
    ),
    showcase.no_param.spend(
      datum: Some("Hello, World!" |> builtin.b_data),
      redeemer: Void,
      utxo: o_ref,
      tx: transaction.placeholder,
    ),
    !showcase.no_param.spend(
      datum: Some(o_ref |> to_data),
      redeemer: Void,
      utxo: o_ref,
      tx: transaction.placeholder,
    ),
    showcase.no_param.spend(
      datum: None,
      redeemer: Void,
      utxo: o_ref,
      tx: transaction.placeholder,
    ),
  }
}

test validator_test_else(stake_pool_hash via stake_pool_id_fuzzer()) fail {
  showcase.no_param.else(
    ScriptContext {
      transaction: transaction.placeholder,
      redeemer: Void,
      info: Voting(stake_pool_hash |> StakePool),
    },
  )
}

test validator_test_with_param(
  (pkh, credential, stake_pool_hash, deposit) via fuzzy.tuple4(
    verification_key_hash_fuzzer(),
    credential_fuzzer(FromKey(Fuzzed)),
    stake_pool_id_fuzzer(),
    fuzz.int_at_least(500_000_000),
  ),
) {
  // Record Update
  // https://aiken-lang.org/language-tour/custom-types#updating-custom-types
  let tx = Transaction { ..transaction.placeholder, extra_signatories: [pkh] }
  // alternatively, use text_kit/tx.{add_signatory}
  // let tx = transaction.placeholder |> add_signatory(pkh)
  //
  and {
    showcase.with_param.withdraw(
      param_1: pkh,
      redeemer: Void,
      credential: credential,
      tx: tx,
    ),
    showcase.with_param.publish(
      param_1: pkh,
      redeemer: Void,
      certificate: RegisterAndDelegateCredential {
        delegate: stake_pool_hash |> DelegateBlockProduction,
        credential,
        deposit,
      },
      tx: tx,
    ),
  }
}
