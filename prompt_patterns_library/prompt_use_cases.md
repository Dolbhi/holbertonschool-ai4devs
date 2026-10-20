# Prompt Use Cases
## Code Quality
- **Refactor Function** [[refactor_function]]
	- **Goal**: Extract block into standalone function
	- **Input**: Code block and section of code to be factorised out
	- **Output**: Refactored code with new function

- **Move Declaration** [[move_declaration]]
	- **Goal**: Move function/class declaration between files/modules/namespaces
	- **Input**: Code base with source function/class declaration and destination location
	- **Output**: Refactored codebase with the declaration moved and all references updated.

## Documentation
- **Generate Documentation** [[generate_documentation]]
	- **Goal**: Generate accurate and helpful documentation
	- **Input**: Code block (Function or class declaration)
	- **Output**: Documentation describing what the code does and how to use it.

- **Insert Comments** [[insert_comments]]
	- **Goal**: Improve readability with comments
	- **Input**: Code block
	- **Output**: Code with comments inserted where they would be helpful

- **Generate Change Log** [[generate_change_log]]
	- **Goal**: Generate accurate log of changes made
	- **Input**: Files and lines changed
	- **Output**: Change log describing changes and impacted interfaces
## Debugging
- **Verify Code** [[verify_code]]
	- **Goal**: Spot possible bugs
	- **Input**: Code block and description of intended behaviour
	- **Output**: Description of possible bugs with explanation

- **Diagnose Bug** [[diagnose_bug]]
	- **Goal**: Find source of a bug
	- **Input**: Code block and bug description
	- **Output**: Explanation of the cause of a bug and potential fixes

## Testing
- **Function Test**
	- **Goal**: Generate a test for a function
	- **Input**: Function declaration
	- **Output**: Code for a runnable test of the function

- **Feature Test** [[feature_test]]
	- **Goal**: Generate a test for a given feature
	- **Input**: Code base and feature description
	- **Output**: Code for a runnable test of the feature

- **Quality Assurance** [[quality_assurance]]
	- **Goal**: Evaluate the quality of some output
	- **Input**: Original objective and requirements and output of a function or AI prompt
	- **Output**: Quality of output relative to given objective and requirements with explanation and feedback

## Learning
- **Feature Example** [[feature_example]]
	- **Goal**: Learn how to implement a feature using a specific package or library
	- **Input**: Desired feature and used packages/library
	- **Output**: Code snippet with explanation on how it works