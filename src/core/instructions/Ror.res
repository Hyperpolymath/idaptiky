// ROR instruction - Rotate Right
// Operation: a = (a >> 1) | (a << 31) for 32-bit integers
// Inverse: ROL (rotate left)

let make = (varA: string, ~bits: int=1, ()): Instruction.t => {
  instructionType: "ROR",
  args: [varA],
  execute: state => {
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    // Rotate right by 'bits' positions (32-bit)
    let rotated = Js.Int.lor(
      Js.Int.lsr(valA, bits),
      Js.Int.lsl(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
  invert: state => {
    // Inverse: rotate left by same number of bits
    let valA = Js.Dict.get(state, varA)->Belt.Option.getWithDefault(0)
    let rotated = Js.Int.lor(
      Js.Int.lsl(valA, bits),
      Js.Int.lsr(valA, 32 - bits)
    )
    Js.Dict.set(state, varA, rotated)
  },
}
