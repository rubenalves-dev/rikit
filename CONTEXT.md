# Rikit

Rikit is a collection of focused developer tools. Each tool transforms or inspects developer-provided input while keeping its behavior explicit and predictable.

## JSON Formatter

**JSON input**:
Any valid JSON value supplied for formatting, including objects, arrays, strings, numbers, booleans, and null.
_Avoid_: JSON object, payload

**Recursive key sorting**:
Deterministic lexicographical ordering of every object's keys throughout a JSON input, including objects nested inside arrays.
_Avoid_: Top-level sorting, shallow sorting

**Duplicate object key**:
A repeated member name within the same JSON object. Duplicate object keys are rejected with an error that identifies the duplicated key.
_Avoid_: Last-key-wins

**Exact number representation**:
The original textual representation of each JSON number, retained without changing its spelling or precision. This is the default formatting behavior.
_Avoid_: Parsed number, equivalent number

**Number normalization**:
An optional, exact transformation into minimal plain-decimal notation. It removes redundant characters such as fractional zeros and negative zero, expands scientific notation, and never changes the mathematical value.
_Avoid_: Number formatting, scientific notation, floating-point conversion

**String normalization**:
The default transformation of equivalent JSON string spellings, in both object keys and values, into readable and consistently escaped output. It can be disabled to retain every string token's exact source representation.
_Avoid_: String formatting

**Format command**:
An explicit request to format the current JSON input, triggered by the primary action or its keyboard shortcut. Editing and pasting input never format it automatically.
_Avoid_: Live formatting, auto-format

## Activity

**Tool run**:
One explicit execution of a Rikit tool, recorded without the user's input, output, clipboard contents, filenames, or other payload data.
_Avoid_: Request, job

**Activity summary**:
Privacy-safe daily aggregate counts and byte totals grouped by tool and outcome, retained for one year. The dashboard presents day, week, month, six-month, and one-year views; outcomes distinguish successful runs, validation failures, and policy rejections.
_Avoid_: Usage log, payload history
