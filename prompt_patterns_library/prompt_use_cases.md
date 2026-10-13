# Prompt Use Cases
## Code Quality
- **Function Refactoring**
	- **Goal**: Extract block into standalone function
	- **Input**: Code block and section of code to be factorised out
	- **Output**: Refactored code with new function

- **Moving Declaration**
	- **Goal**: Move function/class declaration between files/modules/namespaces
	- **Input**: Code base with source function/class declaration and destination location
	- **Output**: Refactored codebase with the declaration moved and all references updated.

- **Style Enforcement**
	- **Goal**: Enforce consistent naming and formatting
	- **Input**: Code block
	- **Output**: Rewritten code with consistent style

## Documentation
- **Generate Documentation**
	- **Goal**: Generate accurate and helpful documentation
	- **Input**: Code block (Function or class declaration)
	- **Output**: Documentation describing what the code does and how to use it.

- **Insert Comments**
	- **Goal**: Improve readability with comments
	- **Input**: Code block
	- **Output**: Code with comments inserted where they would be helpful

- **Commenting**
	- **Goal**: Improve readability
	- **Input**: Code block
	- **Output**: Code with comments inserted where they would be helpful

## Debugging
- **Verify Code**
	- **Goal**: Spot possible bugs
	- **Input**: Code block and description of intended behaviour
	- **Output**: Description of possible bugs with explanation

- **Diagnose Bug**
	- **Goal**: Find source of a bug
	- **Input**: Code block and bug description
	- **Output**: Explanation of the cause of a bug and potential fixes

## Testing
- **Function Test**
	- **Goal**: Generate a test for a function
	- **Input**: Function declaration
	- **Output**: Code for a runnable test of the function

- **Feature Test**
	- **Goal**: Generate a test for a given feature
	- **Input**: Code base and feature description
	- **Output**: Code for a runnable test of the feature

## Learning
- **Feature Example**
	- **Goal**: Learn how to implement a feature using a specific package or library
	- **Input**: Desired feature and used packages/library
	- **Output**: Code snippet with explanation on how it works