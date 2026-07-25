# Rikit

Rikit is a collection of focused developer tools. Each tool transforms or inspects developer-provided input while keeping its behavior explicit and predictable.

## JSON Formatter

**JSON formatting**:
Rewriting JSON for readability using two-space or four-space indentation. Compact output and minification belong to a separate future tool.
_Avoid_: Minification, compacting

**JSON input**:
Any valid JSON value supplied for formatting, including objects, arrays, strings, numbers, booleans, and null.
_Avoid_: JSON object, payload

**Recursive natural key sorting**:
Deterministic ordering of every object's decoded keys throughout a JSON input, including objects nested inside arrays. Category precedence is symbols, lowercase letters, uppercase letters, then numeric keys; numeric keys are ordered by arbitrary-precision value.
_Avoid_: Top-level sorting, shallow sorting, lexicographical sorting

**Duplicate object key**:
A repeated member name within the same JSON object. Duplicate object keys are rejected with an error that identifies the duplicated key; its input diagnostic selects the entire second key occurrence that made the object invalid.
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

**JSON workspace**:
The input, output, and selected formatting options held for the current application session. Input and output may survive navigation but are never persisted across application restarts.
_Avoid_: Draft, saved input

**JSON editor**:
The code-oriented input and output panes of the JSON workspace. Both panes display gutter line numbers to support diagnostics and comparison. Source lines do not wrap and may be navigated horizontally, preserving a one-to-one relationship between source lines and gutter line numbers. The output pane remains read-only.
_Avoid_: Text box, wrapped editor

**Input diagnostic**:
A formatting failure associated with an exact position in a specific revision of the current JSON input. The editor automatically reveals the position, exclusively highlights the containing line, focuses the input editor, and selects or marks the offending character or token with a caret. Invoking its notification repeats the same navigation while the JSON Formatter remains visible. Editing the input or leaving the tool clears the diagnostic and permanently invalidates its notification action. A JSON workspace has at most one active input diagnostic; every later formatting attempt invalidates the previous diagnostic action.
_Avoid_: Error message, line-and-column text

## Notifications

**Actionable notification**:
A notification linked to a currently available user action. Its entire card is the interaction target, while a non-button icon on the right communicates actionability. Error severity alone never makes a notification actionable; an editor error is actionable only when it carries source-location information the current editor can use. The affordance is absent—not disabled—when the required application context is unavailable, the information is unusable, or the action has been invalidated. Actionable notifications are keyboard-focusable, expose an accessible action name, and activate with Enter or Space.
_Avoid_: Clickable popup, toast link

**Shortcut label**:
The shared, platform-aware visual representation of a keyboard shortcut throughout the application. Every shortcut uses the same component, spacing, typography, and high-contrast light-gray foreground on a gray background, while key names and symbols match the running operating system.
_Avoid_: Shortcut text, keyboard hint

## Activity

**Tool run**:
One explicit execution of a Rikit tool, recorded without the user's input, output, clipboard contents, filenames, or other payload data.
_Avoid_: Request, job

**Activity summary**:
Privacy-safe daily aggregate counts and byte totals grouped by tool and outcome, retained for one year. The dashboard presents day, week, month, six-month, and one-year views; outcomes distinguish successful runs, validation failures, and policy rejections.
_Avoid_: Usage log, payload history
