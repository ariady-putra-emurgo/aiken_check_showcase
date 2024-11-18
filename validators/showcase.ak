use aiken/collection/list
use aiken/crypto.{VerificationKeyHash}
use cardano/address.{Credential}
use cardano/assets.{PolicyId}
use cardano/certificate.{Certificate}
use cardano/transaction.{OutputReference, Transaction}

validator no_param {
  mint(redeemer: Int, policy_id _policy_id: PolicyId, tx _tx: Transaction) {
    // `?` (trace-if-false) Operator
    // https://aiken-lang.org/language-tour/troubleshooting#-operator
    // this will print a trace only if the condition is False
    (redeemer == 42)?
  }

  spend(
    datum: Option<Data>,
    redeemer _redeemer: Void,
    utxo _utxo: OutputReference,
    tx _tx: Transaction,
  ) {
    // Pattern Matching (when-is)
    // https://aiken-lang.org/language-tour/custom-types#pattern-matching
    // think of it like `switch-case` in other programming languages
    when datum is {
      // soft-casting data,
      // it can be Int (42)
      // or ByteArray ("Hello, World!")
      // otherwise it's rejected
      Some(data) ->
        if data is Int {
          (data == 42)?
        } else if data is ByteArray {
          (data == "Hello, World!")?
        } else {
          False
        }

      // allow spending a UTxO without datum
      // eg. transfered by mistake
      // NOTE: Anyone can withdraw, first come first serve
      _ -> True
    }
  }

  else(_) {
    fail
  }
}

validator with_param(param_1 pkh: VerificationKeyHash) {
  withdraw(
    redeemer _redeemer: Void,
    credential _credential: Credential,
    tx: Transaction,
  ) {
    // Destructuring
    // https://aiken-lang.org/language-tour/custom-types#destructuring
    let Transaction { extra_signatories, .. } = tx

    trace @"Extra Signatories": extra_signatories

    // return: whether the Transaction was signed by the `pkh` or not
    extra_signatories |> list.has(pkh)
  }

  publish(
    redeemer _redeemer: Void,
    certificate _certificate: Certificate,
    tx: Transaction,
  ) {
    let Transaction { extra_signatories, .. } = tx

    // Traces
    // https://aiken-lang.org/language-tour/troubleshooting#traces
    // NOTE:
    //   - `aiken check` or `aiken c` will always print the trace
    //   - `aiken build` or `aiken b` will automatically remove all traces (silent build)
    //   - `aiken b -t compact` will only print the label, eg. @"Extra Signatories"
    //      All traces must have a label if you want to build using compact mode.
    //   - `aiken b -t verbose` will print the full trace
    trace @"Extra Signatories": extra_signatories

    // `|>` (pipe) Operator
    // https://aiken-lang.org/language-tour/control-flow#piping
    // this makes it looks like OOP
    extra_signatories |> list.has(pkh)
  }

  else(_) {
    fail
  }
}
