"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode = require("vscode");
const foundBracket_1 = require("./foundBracket");
const textLine_1 = require("./textLine");
class DocumentDecoration {
    constructor(document, prismJs, settings) {
        // This program caches lines, and will only analyze linenumbers including or above a modified line
        this.lineToUpdateWhenTimeoutEnds = 0;
        this.lines = [];
        // What have I created..
        this.stringStrategies = new Map();
        this.stringOrTokenArrayStrategies = new Map();
        this.settings = settings;
        this.document = document;
        this.prismJs = prismJs;
        const basicStringMatch = (content, lineIndex, charIndex, positions) => {
            return this.matchString(content, lineIndex, charIndex, positions);
        };
        // Match punctuation on all languages
        this.stringStrategies.set("punctuation", basicStringMatch);
        if (settings.prismLanguageID === "markup") {
            this.stringStrategies.set("attr-name", basicStringMatch);
        }
        if (settings.prismLanguageID === "powershell") {
            this.stringStrategies.set("namespace", basicStringMatch);
        }
        if (settings.prismLanguageID === "markdown") {
            const markdownUrl = (array, lineIndex, charIndex, positions) => {
                // Input: ![Disabled](images/forceUniqueOpeningColorDisabled.png "forceUniqueOpeningColor Disabled")
                // [0]: ![Disabled](images/forceUniqueOpeningColorDisabled.png
                // [1]: "forceUniqueOpeningColor Disabled"
                // [2]: )
                return this.matchStringOrTokenArray(new Set([0, array.length - 1]), array, lineIndex, charIndex, positions);
            };
            this.stringOrTokenArrayStrategies.set("url", markdownUrl);
        }
    }
    dispose() {
        this.settings.dispose();
    }
    onDidChangeTextDocument(contentChanges) {
        this.updateLowestLineNumber(contentChanges);
        this.triggerUpdateDecorations();
    }
    // Lines are stored in an array, if line is requested outside of array bounds
    // add emptys lines until array is correctly sized
    getLine(index, document) {
        if (index < this.lines.length) {
            return this.lines[index];
        }
        else {
            if (this.lines.length === 0) {
                this.lines.push(new textLine_1.default(document.lineAt(0).text, this.settings, 0));
            }
            for (let i = this.lines.length; i <= index; i++) {
                const previousLine = this.lines[this.lines.length - 1];
                const newLine = new textLine_1.default(document.lineAt(i).text, this.settings, i, previousLine.copyMultilineContext());
                this.lines.push(newLine);
            }
            const lineToReturn = this.lines[this.lines.length - 1];
            return lineToReturn;
        }
    }
    triggerUpdateDecorations() {
        if (this.settings.isDisposed) {
            return;
        }
        if (this.settings.timeOutLength > 0) {
            if (this.updateDecorationTimeout) {
                clearTimeout(this.updateDecorationTimeout);
            }
            this.updateDecorationTimeout = setTimeout(() => {
                this.updateDecorationTimeout = null;
                this.updateDecorations();
                if (this.updateScopeEvent) {
                    this.updateScopeDecorations(this.updateScopeEvent);
                    this.updateScopeEvent = undefined;
                }
            }, this.settings.timeOutLength);
        }
        else {
            this.updateDecorations();
        }
    }
    updateScopeDecorations(event) {
        if (this.updateDecorationTimeout) {
            this.updateScopeEvent = event;
            return;
        }
        const scopes = new Set();
        event.selections.forEach((selection) => {
            const scope = this.getScope(selection.active);
            if (scope) {
                scopes.add(scope);
            }
        });
        const colorMap = new Map();
        // Reduce all the colors/ranges of the lines into a singular map
        for (const scope of scopes) {
            {
                const existingRanges = colorMap.get(scope.color);
                if (existingRanges !== undefined) {
                    existingRanges.push(scope.open.range);
                    existingRanges.push(scope.close.range);
                }
                else {
                    colorMap.set(scope.color, [scope.open.range, scope.close.range]);
                }
            }
        }
        for (const [color, decoration] of this.settings.scopeDecorations) {
            const ranges = colorMap.get(color);
            if (ranges !== undefined) {
                event.textEditor.setDecorations(decoration, ranges);
            }
            else {
                // We must set non-used colors to an empty array
                // or previous decorations will not be invalidated
                event.textEditor.setDecorations(decoration, []);
            }
        }
    }
    getScope(position) {
        for (let i = position.line; i < this.lines.length; i++) {
            const scope = this.lines[i].getScope(position);
            if (scope) {
                return scope;
            }
        }
    }
    updateLowestLineNumber(contentChanges) {
        for (const contentChange of contentChanges) {
            this.lineToUpdateWhenTimeoutEnds =
                Math.min(this.lineToUpdateWhenTimeoutEnds, contentChange.range.start.line);
        }
    }
    updateDecorations() {
        // One document may be shared by multiple editors (side by side view)
        const editors = vscode.window.visibleTextEditors.filter((e) => this.document === e.document);
        if (editors.length === 0) {
            console.warn("No editors associated with document: " + this.document.fileName);
            return;
        }
        const lineNumber = this.lineToUpdateWhenTimeoutEnds;
        const amountToRemove = this.lines.length - lineNumber;
        // Remove cached lines that need to be updated
        this.lines.splice(lineNumber, amountToRemove);
        const languageID = this.settings.prismLanguageID;
        const text = this.document.getText();
        let tokenized;
        try {
            tokenized = this.prismJs.tokenize(text, this.prismJs.languages[languageID]);
            if (!tokenized) {
                return;
            }
        }
        catch (err) {
            console.warn(err);
            return;
        }
        const positions = [];
        this.parseTokenOrStringArray(tokenized, 0, 0, positions);
        positions.forEach((element) => {
            const currentLine = this.getLine(element.range.start.line, this.document);
            currentLine.addBracket(element);
        });
        this.colorDecorations(editors);
    }
    parseTokenOrStringArray(tokenized, lineIndex, charIndex, positions) {
        tokenized.forEach((token) => {
            if (token instanceof this.prismJs.Token) {
                const result = this.parseToken(token, lineIndex, charIndex, positions);
                charIndex = result.charIndex;
                lineIndex = result.lineIndex;
            }
            else {
                const result = this.parseString(token, lineIndex, charIndex);
                charIndex = result.charIndex;
                lineIndex = result.lineIndex;
            }
        });
        return { lineIndex, charIndex };
    }
    parseString(content, lineIndex, charIndex) {
        const split = content.split("\n");
        if (split.length > 1) {
            lineIndex += split.length - 1;
            charIndex = split[split.length - 1].length;
        }
        else {
            charIndex += content.length;
        }
        return { lineIndex, charIndex };
    }
    parseToken(token, lineIndex, charIndex, positions) {
        if (typeof token.content === "string") {
            const strategy = this.stringStrategies.get(token.type);
            if (strategy) {
                return strategy(token.content, lineIndex, charIndex, positions);
            }
            return this.parseString(token.content, lineIndex, charIndex);
        }
        else if (Array.isArray(token.content)) {
            const strategy = this.stringOrTokenArrayStrategies.get(token.type);
            if (strategy) {
                return strategy(token.content, lineIndex, charIndex, positions);
            }
            return this.parseTokenOrStringArray(token.content, lineIndex, charIndex, positions);
        }
        else {
            return this.parseToken(token.content, lineIndex, charIndex, positions);
        }
    }
    matchString(content, lineIndex, charIndex, positions) {
        if (lineIndex < this.lineToUpdateWhenTimeoutEnds) {
            return this.parseString(content, lineIndex, charIndex);
            ;
        }
        this.settings.regexNonExact.lastIndex = 0;
        let match;
        // tslint:disable-next-line:no-conditional-assignment
        while ((match = this.settings.regexNonExact.exec(content)) !== null) {
            const startPos = new vscode.Position(lineIndex, charIndex + match.index);
            const endPos = startPos.translate(0, match[0].length);
            positions.push(new foundBracket_1.default(new vscode.Range(startPos, endPos), match[0]));
        }
        return this.parseString(content, lineIndex, charIndex);
    }
    // Array can be Token or String. Indexes are which indexes should be parsed for brackets
    matchStringOrTokenArray(indexes, array, lineIndex, charIndex, positions) {
        for (let i = 0; i < array.length; i++) {
            const content = array[i];
            let result;
            if (indexes.has(i) && typeof content === "string") {
                result = this.matchString(content, lineIndex, charIndex, positions);
            }
            else {
                result = this.parseTokenOrStringArray([content], lineIndex, charIndex, positions);
            }
            lineIndex = result.lineIndex;
            charIndex = result.charIndex;
        }
        return { lineIndex, charIndex };
    }
    colorDecorations(editors) {
        const colorMap = new Map();
        // Reduce all the colors/ranges of the lines into a singular map
        for (const line of this.lines) {
            {
                for (const [color, ranges] of line.colorRanges) {
                    const existingRanges = colorMap.get(color);
                    if (existingRanges !== undefined) {
                        existingRanges.push(...ranges);
                    }
                    else {
                        // Slice because we will be adding values to this array in the future,
                        // but don't want to modify the original array which is stored per line
                        colorMap.set(color, ranges.slice());
                    }
                }
            }
        }
        for (const [color, decoration] of this.settings.bracketDecorations) {
            if (color === "") {
                continue;
            }
            const ranges = colorMap.get(color);
            editors.forEach((editor) => {
                if (ranges !== undefined) {
                    editor.setDecorations(decoration, ranges);
                }
                else {
                    // We must set non-used colors to an empty array
                    // or previous decorations will not be invalidated
                    editor.setDecorations(decoration, []);
                }
            });
        }
        this.lineToUpdateWhenTimeoutEnds = Infinity;
    }
}
exports.default = DocumentDecoration;
//# sourceMappingURL=documentDecoration.js.map