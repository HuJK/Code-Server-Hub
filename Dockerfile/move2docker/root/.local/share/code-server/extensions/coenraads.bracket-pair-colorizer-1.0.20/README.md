# Bracket Pair Colorizer

This extension allows matching brackets to be identified with colours. The user can define which characters to match, and which colours to use.

Screenshot:  
![Screenshot](https://github.com/CoenraadS/BracketPair/raw/master/images/example.png "Bracket Pair Colorizer")

-----------------------------------------------------------------------------------------------------------
## [Release Notes](https://github.com/CoenraadS/BracketPair/blob/master/CHANGELOG.md)

## Features

### User defined matching characters
> By default (), [], and {} are matched, however custom bracket characters can also be configured.

> A list of colors can be configured, as well as a specific color for orphaned brackets.

> Language support provided by Prism.js: http://prismjs.com/#languages-list
-----------------------------------------------------------------------------------------------------------

## Settings

> `"bracketPairColorizer.timeOut"`  
Configure how long the editor should be idle for before updating the document.  
Set to 0 to disable.

> `"bracketPairColorizer.forceUniqueOpeningColor"`  
![Disabled](https://github.com/CoenraadS/BracketPair/raw/master/images/forceUniqueOpeningColorDisabled.png "forceUniqueOpeningColor Disabled")
![Enabled](https://github.com/CoenraadS/BracketPair/raw/master/images/forceUniqueOpeningColorEnabled.png "forceUniqueOpeningColor Enabled")

> `"bracketPairColorizer.forceIterationColorCycle"`  
![Enabled](https://github.com/CoenraadS/BracketPair/raw/master/images/forceIterationColorCycleEnabled.png "forceIterationColorCycle Enabled")

>`"bracketPairColorizer.colorMode"`  
Consecutive brackets share a color pool for all bracket types  
Independent brackets allow each bracket type to use its own color pool  
![Consecutive](https://github.com/CoenraadS/BracketPair/raw/master/images/consecutiveExample.png "Consecutive Example")
![Independent](https://github.com/CoenraadS/BracketPair/raw/master/images/independentExample.png "Independent Example")

> `"bracketPairColorizer.highlightActiveScope"`  
Should the currently scoped brackets always be highlighted?

> `"bracketPairColorizer.activeScopeCSS"`  
Choose a border style to highlight the active scope. Use `{color}` to match the existing bracket color  
It is recommended to disable the inbuilt `editor.matchBrackets` setting if using this feature  
![BorderStyle](https://github.com/CoenraadS/BracketPair/raw/master/images/activeScopeBorder.png "Active Scope Border Example")  
>Tip: Add the value `"backgroundColor : {color}"` to increase visibility  
![BorderBackground](https://github.com/CoenraadS/BracketPair/raw/master/images/activeScopeBackground.png "Active Scope Background Example")

> `"bracketPairColorizer.consecutivePairColors"`   
> A new bracket pair can be configured by adding it to the array.  
> Note: Pair must be supported punctuation type by Prism.js  

> `"bracketPairColorizer.independentPairColors"`   
> A new bracket pair can be configured by adding it to the array.  
> Note: Pair must be supported punctuation type by Prism.js
 
>### HTML Configuration
>An example configuration for HTML is:  
```
    "bracketPairColorizer.consecutivePairColors": [
        [
            "</",
            ">"
        ],
        [
            "<",
            "/>"
        ],
        "<>",
        [
            "Gold",
            "Orchid",
            "LightSkyBlue"
        ],
        "Red"
    ]
```
