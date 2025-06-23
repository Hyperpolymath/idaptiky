import { ReversibleVM } from "./core/vm";
import { Add } from "./core/instructions/add";
import { Swap } from "./core/instructions/swap";

const vm = new ReversibleVM({ x: 3, y: 4 });

vm.run(new Add(["x", "y"]));    // x = x + y
vm.run(new Swap(["x", "y"]));   // swaps x and y

vm.printState();                // Should show updated state

vm.undo();                     // Undo SWAP
vm.undo();                     // Undo ADD

vm.printState();                // Should show original state
