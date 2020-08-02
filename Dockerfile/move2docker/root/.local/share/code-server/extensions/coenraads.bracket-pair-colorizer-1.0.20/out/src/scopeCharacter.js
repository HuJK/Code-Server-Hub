"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class ScopeCharacter {
    constructor(match, options) {
        this.match = match;
        if (options) {
            this.escapeCharacter = options.escapeCharacter;
            this.mustMatchAtOffset = options.mustMatchAtOffset;
            this.mustNotMatchAtOffset = options.mustNotMatchAtOffset;
        }
    }
}
exports.default = ScopeCharacter;
//# sourceMappingURL=scopeCharacter.js.map