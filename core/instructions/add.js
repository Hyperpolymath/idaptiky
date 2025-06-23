"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Add = void 0;
var Add = /** @class */ (function () {
    function Add(args) {
        this.args = args;
        this.type = "ADD";
    }
    Add.prototype.execute = function (state) {
        var _a = this.args, a = _a[0], b = _a[1];
        state[a] += state[b];
    };
    Add.prototype.invert = function (state) {
        var _a = this.args, a = _a[0], b = _a[1];
        state[a] -= state[b];
    };
    return Add;
}());
exports.Add = Add;
