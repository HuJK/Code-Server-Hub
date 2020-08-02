"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class Match {
    static contains(content, position, character) {
        return (this.checkMatch(content, position, character) &&
            this.checkOffsetCondition(content, position, character));
    }
    static checkMatch(content, position, character) {
        return content.substr(position, character.match.length) === character.match
            && this.isNotEscaped(content, position, character);
    }
    static isNotEscaped(content, position, character) {
        if (!character.escapeCharacter) {
            return true;
        }
        let counter = 0;
        position -= character.escapeCharacter.length;
        while (position > 0 &&
            content.substr(position, character.escapeCharacter.length) === character.escapeCharacter) {
            position -= character.escapeCharacter.length;
            counter++;
        }
        return counter % 2 === 0;
    }
    static checkOffsetCondition(content, postion, character) {
        if (character.mustMatchAtOffset) {
            for (const matchCondition of character.mustMatchAtOffset) {
                const checkPosition = postion + matchCondition.offset;
                if (checkPosition < 0) {
                    return false;
                }
                if (!this.checkMatch(content, checkPosition, matchCondition.character)) {
                    return false;
                }
            }
        }
        if (character.mustNotMatchAtOffset) {
            for (const matchCondition of character.mustNotMatchAtOffset) {
                const checkPosition = postion + matchCondition.offset;
                if (checkPosition >= 0 && this.checkMatch(content, checkPosition, matchCondition.character)) {
                    return false;
                }
            }
        }
        return true;
    }
}
exports.default = Match;
//# sourceMappingURL=match.js.map