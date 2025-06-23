"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReversibleVM = void 0;
var ReversibleVM = /** @class */ (function () {
    function ReversibleVM(initial) {
        this.history = [];
        this.state = __assign({}, initial);
    }
    ReversibleVM.prototype.run = function (instr) {
        instr.execute(this.state);
        this.history.push(instr);
    };
    ReversibleVM.prototype.undo = function () {
        var instr = this.history.pop();
        if (instr)
            instr.invert(this.state);
    };
    ReversibleVM.prototype.printState = function () {
        console.log("Current State:", this.state);
    };
    return ReversibleVM;
}());
exports.ReversibleVM = ReversibleVM;
