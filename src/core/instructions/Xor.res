// XOR instruction - Bitwise exclusive OR
// Operation: a = a XOR b
// Inverse: a = a XOR b (XOR is self-inverse when applied with same operand)

let make = (varA: string, varB: string): Instruction.t => {
  instructionType: "XOR",
  args: [varA, varB],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, varB)->Belt.Option.getWithDefault(0)
    // Bitwise XOR in JavaScript: a ^ b
    let result = Js.Int.lor(Js.Int.land(valA, lnot(valB)), Js.Int.land(lnot(valA), valB))
    Js.Dict.set(state, varA, result)
  },
  invert: state => {
    // XOR is self-inverse: (a XOR b) XOR b = a
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let valB = Js.Dict.get(state, varB)->Belt.Option.getWithDefault(0)
    let result = Js.Int.lor(Js.Int.land(valA, lnot(valB)), Js.Int.land(lnot(valA), valB))
    Js.Dict.set(state, varA, result)
  },
}
