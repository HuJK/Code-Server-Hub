"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
const documentDecoration_1 = require("./documentDecoration");
const prismJsLanguages_1 = require("./prismJsLanguages");
const settings_1 = require("./settings");
class DocumentDecorationManager {
    constructor() {
        this.supportedLanguages = new Set(prismJsLanguages_1.default);
        this.showError = true;
        this.documents = new Map();
        this.PrismLoader = require("prismjs/tests/helper/prism-loader");
    }
    reset() {
        this.documents.forEach((document, key) => {
            document.dispose();
        });
        this.documents.clear();
        this.updateAllDocuments();
    }
    updateDocument(document) {
        const documentDecoration = this.getDocumentDecorations(document);
        if (documentDecoration) {
            documentDecoration.triggerUpdateDecorations();
        }
    }
    onDidOpenTextDocument(document) {
        const documentDecoration = this.getDocumentDecorations(document);
        if (documentDecoration) {
            documentDecoration.triggerUpdateDecorations();
        }
    }
    onDidChangeTextDocument(document, contentChanges) {
        const documentDecoration = this.getDocumentDecorations(document);
        if (documentDecoration) {
            documentDecoration.onDidChangeTextDocument(contentChanges);
        }
    }
    onDidCloseTextDocument(closedDocument) {
        const uri = closedDocument.uri.toString();
        const document = this.documents.get(uri);
        if (document !== undefined) {
            document.dispose();
            this.documents.delete(closedDocument.uri.toString());
        }
    }
    onDidChangeSelection(event) {
        const documentDecoration = this.getDocumentDecorations(event.textEditor.document);
        if (documentDecoration && documentDecoration.settings.highlightActiveScope) {
            documentDecoration.updateScopeDecorations(event);
        }
    }
    updateAllDocuments() {
        vscode_1.window.visibleTextEditors.forEach((editor) => {
            this.updateDocument(editor.document);
        });
    }
    getDocumentDecorations(document) {
        if (!this.isValidDocument(document)) {
            return;
        }
        const uri = document.uri.toString();
        let documentDecorations = this.documents.get(uri);
        if (documentDecorations === undefined) {
            try {
                const languages = this.getPrismLanguageID(document.languageId);
                const primaryLanguage = languages[0];
                if (!this.supportedLanguages.has(primaryLanguage)) {
                    return;
                }
                const settings = new settings_1.default(primaryLanguage, document.uri);
                const prismJs = this.PrismLoader.createInstance(languages);
                documentDecorations = new documentDecoration_1.default(document, prismJs, settings);
                this.documents.set(uri, documentDecorations);
            }
            catch (error) {
                if (error instanceof Error) {
                    if (this.showError) {
                        vscode_1.window.showErrorMessage("BracketPair Settings: " + error.message);
                        // Don't spam errors
                        this.showError = false;
                        setTimeout(() => {
                            this.showError = true;
                        }, 3000);
                    }
                }
                return;
            }
        }
        return documentDecorations;
    }
    getPrismLanguageID(languageID) {
        // Some VSCode language ids need to be mapped to match http://prismjs.com/#languages-list
        switch (languageID) {
            case "html": return ["markup", "javascript"];
            case "javascriptreact": return ["jsx"];
            case "jsonc": return ["javascript"];
            case "mathml": return ["markup"];
            case "nunjucks": return ["twig"];
            case "scad": return ["swift"]; // workaround for unsupported language in Prism
            case "svg": return ["markup"];
            case "typescriptreact": return ["tsx"];
            case "vb": return ["vbnet"];
            case "vue": return ["markup", "javascript"];
            case "xml": return ["markup"];
            default: return [languageID];
        }
    }
    isValidDocument(document) {
        if (document === undefined || document.lineCount === 0) {
            console.warn("Invalid document");
            return false;
        }
        return document.uri.scheme === "file" || document.uri.scheme === "untitled" || document.uri.scheme === "vsls";
    }
}
exports.default = DocumentDecorationManager;
//# sourceMappingURL=documentDecorationManager.js.map