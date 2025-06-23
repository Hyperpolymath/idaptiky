"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var vm_1 = require("./core/vm");
var add_1 = require("./core/instructions/add");
var swap_1 = require("./core/instructions/swap");
var vm = new vm_1.ReversibleVM({ x: 3, y: 4 });
vm.run(new add_1.Add(["x", "y"])); // x = x + y
vm.run(new swap_1.Swap(["x", "y"])); // swaps x and y
vm.printState(); // Should show updated state
vm.undo(); // Undo SWAP
vm.undo(); // Undo ADD
vm.printState(); // Should show original state
