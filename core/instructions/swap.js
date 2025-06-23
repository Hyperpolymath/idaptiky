"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Swap = void 0;
var Swap = /** @class */ (function () {
    function Swap(args) {
        this.args = args;
        this.type = "SWAP";
    }
    Swap.prototype.execute = function (state) {
        var _a;
        var _b = this.args, a = _b[0], b = _b[1];
        _a = [state[b], state[a]], state[a] = _a[0], state[b] = _a[1];
    };
    Swap.prototype.invert = function (state) {
        this.execute(state); // swap is its own inverse
    };
    return Swap;
}());
exports.Swap = Swap;
