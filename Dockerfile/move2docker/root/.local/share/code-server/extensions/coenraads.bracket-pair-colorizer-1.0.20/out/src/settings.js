"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const bracketPair_1 = require("./bracketPair");
const colorMode_1 = require("./colorMode");
class Settings {
    constructor(languageID, documentUri) {
        this.bracketPairs = [];
        this.isDisposed = false;
        this.prismLanguageID = languageID;
        const configuration = vscode.workspace.getConfiguration("bracketPairColorizer", documentUri);
        this.activeScopeCSS = configuration.get("activeScopeCSS");
        if (!Array.isArray(this.activeScopeCSS)) {
            throw new Error("activeScopeCSS is not an array");
        }
        this.highlightActiveScope = configuration.get("highlightActiveScope");
        if (typeof this.highlightActiveScope !== "boolean") {
            throw new Error("alwaysHighlightActiveScope is not a boolean");
        }
        this.forceUniqueOpeningColor = configuration.get("forceUniqueOpeningColor");
        if (typeof this.forceUniqueOpeningColor !== "boolean") {
            throw new Error("forceUniqueOpeningColor is not a boolean");
        }
        this.forceIterationColorCycle = configuration.get("forceIterationColorCycle");
        if (typeof this.forceIterationColorCycle !== "boolean") {
            throw new Error("forceIterationColorCycle is not a boolean");
        }
        this.colorMode = colorMode_1.default[configuration.get("colorMode")];
        if (typeof this.colorMode !== "number") {
            throw new Error("colorMode enum could not be parsed");
        }
        this.timeOutLength = configuration.get("timeOut");
        if (typeof this.timeOutLength !== "number") {
            throw new Error("timeOutLength is not a number");
        }
        if (this.colorMode === colorMode_1.default.Consecutive) {
            const consecutiveSettings = configuration.get("consecutivePairColors");
            if (!Array.isArray(consecutiveSettings)) {
                throw new Error("consecutivePairColors is not an array");
            }
            if (consecutiveSettings.length < 3) {
                throw new Error("consecutivePairColors expected at least 3 parameters, actual: "
                    + consecutiveSettings.length);
            }
            const orphanColor = consecutiveSettings[consecutiveSettings.length - 1];
            if (typeof orphanColor !== "string") {
                throw new Error("consecutivePairColors[" + (consecutiveSettings.length - 1) + "] is not a string");
            }
            const colors = consecutiveSettings[consecutiveSettings.length - 2];
            if (!Array.isArray(colors)) {
                throw new Error("consecutivePairColors[" + (consecutiveSettings.length - 2) + "] is not a string[]");
            }
            consecutiveSettings.slice(0, consecutiveSettings.length - 2).forEach((brackets, index) => {
                if (typeof brackets === "string" || Array.isArray(brackets)) {
                    if (brackets.length !== 2) {
                        throw new Error("consecutivePairColors[" + index + "] requires 2 element, e.g. ['(',')']");
                    }
                    this.bracketPairs.push(new bracketPair_1.default(brackets[0], brackets[1], colors, orphanColor));
                    return;
                }
                throw new Error("consecutivePairColors[ " + index + "] should be a string or an array of strings");
            });
        }
        else {
            const independentSettings = configuration.get("independentPairColors");
            if (!Array.isArray(independentSettings)) {
                throw new Error("independentPairColors is not an array");
            }
            independentSettings.forEach((innerArray, index) => {
                if (!Array.isArray(innerArray)) {
                    throw new Error("independentPairColors[" + index + "] is not an array");
                }
                const brackets = innerArray[0];
                if (typeof brackets !== "string" && !Array.isArray(brackets)) {
                    throw new Error("independentSettings[" + index + "][0] is not a string or an array of strings");
                }
                if (brackets.length < 2) {
                    throw new Error("independentSettings[" + index + "][0] needs at least 2 elements");
                }
                const colors = innerArray[1];
                if (!Array.isArray(colors)) {
                    throw new Error("independentSettings[" + index + "][1] is not string[]");
                }
                const orphanColor = innerArray[2];
                if (typeof orphanColor !== "string") {
                    throw new Error("independentSettings[" + index + "][2] is not a string");
                }
                this.bracketPairs.push(new bracketPair_1.default(brackets[0], brackets[1], colors, orphanColor));
            });
        }
        this.regexNonExact = this.createRegex(this.bracketPairs, false);
        this.bracketDecorations = this.createBracketDecorations(this.bracketPairs);
        this.scopeDecorations = this.createScopeDecorations(this.bracketPairs);
    }
    dispose() {
        this.scopeDecorations.forEach((decoration, key) => {
            decoration.dispose();
        });
        this.scopeDecorations.clear();
        this.bracketDecorations.forEach((decoration, key) => {
            decoration.dispose();
        });
        this.bracketDecorations.clear();
        this.isDisposed = true;
    }
    createRegex(bracketPairs, exact) {
        const escape = (s) => s.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
        let regex = "";
        const matches = [];
        bracketPairs.forEach((bracketPair) => {
            matches.push(bracketPair.openCharacter);
            matches.push(bracketPair.closeCharacter);
        });
        const sortedByLengthMatches = matches.sort((a, b) => b.length - a.length);
        sortedByLengthMatches.forEach((match) => {
            if (regex !== "") {
                regex += "|";
            }
            if (exact) {
                regex += `${escape(match)}`;
            }
            else {
                regex += `${escape(match)}`;
            }
        });
        return new RegExp(regex, !exact ? "g" : undefined);
        ;
    }
    createBracketDecorations(bracketPairs) {
        const decorations = new Map();
        for (const bracketPair of bracketPairs) {
            for (const color of bracketPair.colors) {
                const decoration = vscode.window.createTextEditorDecorationType({
                    color, rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
                });
                decorations.set(color, decoration);
            }
            const errorDecoration = vscode.window.createTextEditorDecorationType({
                color: bracketPair.orphanColor,
                rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
            });
            decorations.set(bracketPair.orphanColor, errorDecoration);
        }
        return decorations;
    }
    createScopeDecorations(bracketPairs) {
        const decorations = new Map();
        const cssElements = this.activeScopeCSS.map((e) => [e.substring(0, e.indexOf(":")).trim(),
            e.substring(e.indexOf(":") + 1).trim()]);
        for (const bracketPair of bracketPairs) {
            for (const color of bracketPair.colors) {
                const decorationSettings = {
                    rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
                };
                cssElements.forEach((element) => {
                    decorationSettings[element[0]] = element[1].replace("{color}", color);
                });
                const decoration = vscode.window.createTextEditorDecorationType(decorationSettings);
                decorations.set(color, decoration);
            }
        }
        return decorations;
    }
}
exports.default = Settings;
//# sourceMappingURL=settings.js.map