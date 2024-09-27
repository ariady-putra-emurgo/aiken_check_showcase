use aiken/builtin
use cardano/address.{VerificationKey}
use cardano/certificate.{DelegateBlockProduction, RegisterAndDelegateCredential}
use cardano/governance.{StakePool}
use cardano/script_context.{ScriptContext, Voting}
use cardano/transaction.{OutputReference, Transaction}
use showcase

test validator_test_mint() {
  // Importing Validators
  // https://aiken-lang.org/language-tour/validators#importing-validators
  showcase.no_param.mint(42, "", transaction.placeholder)
}

test validator_test_spend() {
  // `let` Bindings
  // https://aiken-lang.org/language-tour/variables-and-constants#variables--let-bindings
  let arbitrary_utxo = OutputReference("", 0)

  // Upcasting
  // https://aiken-lang.org/language-tour/custom-types#upcasting
  let invalid_datum: Data = arbitrary_utxo

  // `and` Block
  // https://aiken-lang.org/language-tour/primitive-types#andor-keywords
  and {
    showcase.no_param.spend(
      datum: Some(42 |> builtin.i_data),
      redeemer: Void,
      utxo: arbitrary_utxo,
      tx: transaction.placeholder,
    ),
    showcase.no_param.spend(
      datum: Some("Hello, World!" |> builtin.b_data),
      redeemer: Void,
      utxo: arbitrary_utxo,
      tx: transaction.placeholder,
    ),
    !showcase.no_param.spend(
      datum: Some(invalid_datum),
      redeemer: Void,
      utxo: arbitrary_utxo,
      tx: transaction.placeholder,
    ),
    showcase.no_param.spend(
      datum: None,
      redeemer: Void,
      utxo: arbitrary_utxo,
      tx: transaction.placeholder,
    ),
  }
}

test validator_test_else() fail {
  showcase.no_param.else(
    ScriptContext {
      transaction: transaction.placeholder,
      redeemer: Void,
      info: Voting("VerificationKeyHash" |> StakePool),
    },
  )
}

test validator_test_with_param() {
  let pkh = "VerificationKeyHash"

  // Record Update
  // https://aiken-lang.org/language-tour/custom-types#updating-custom-types
  let tx = Transaction { ..transaction.placeholder, extra_signatories: [pkh] }

  and {
    showcase.with_param.withdraw(
      param_1: pkh,
      redeemer: Void,
      credential: "Credential" |> VerificationKey,
      tx: tx,
    ),
    showcase.with_param.publish(
      param_1: pkh,
      redeemer: Void,
      certificate: RegisterAndDelegateCredential {
        credential: "Credential" |> VerificationKey,
        delegate: "StakePoolId" |> DelegateBlockProduction,
        deposit: 500_000_000,
      },
      tx: tx,
    ),
  }
}
