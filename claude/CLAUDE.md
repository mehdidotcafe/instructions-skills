# Coding Style Guide

Follow this coding style guide when building features.

- Try to use Functional Programming principles as much as possible. If it's too difficult to implement, fallback on another paradigm.
- Use descriptive variable and function names inspired by Living Documentation book.
- Use Hexagonal Architecture when possible to separate concerns and improve testability.
- Take inspiration from the books "Clean Code" and "Clean Architecture" to write clean, maintainable, and scalable code.
- Take a Don't Repeat Yourself (DRY) approach to avoid code duplication and improve maintainability. If something is repeated more than 3 times, consider refactoring it into a reusable function or module.
- Using Test Driven Development (TDD) when building features is highly encouraged to ensure code quality and maintainability. Test should be Atomic, Independent, Repeatable, Self-validating, and Timely (FIRST).
- Try to respect the pyramid of tests: Unit tests should be the most common, followed by integration tests, and then end-to-end tests.
- Always take into account the project CODESTYLE.md or STYLEGUIDE.md file if it exists, and follow its guidelines for consistency across the codebase.
