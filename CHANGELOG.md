# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.12.1] - 2026-09-09

### Fixed

- Overlooked usage of `Pack.Vector3` not being migrated to `Pack.Vector3()` breaking `Pack.Any`
- BufferFixed evaluator checking `< length` instead of `== length`

## [0.12.0] - 2026-07-24

### Added

- `Pack.Bool` (Alias for `Pack.Boolean`)
- `Pack.Option` (Alias for `Pack.Nullable`)

### Changed

- Modifies the declaration of `Pack.Vector3` and `Pack.Vector2`. These could previously be written as if they were static datatypes but now must be called as functions. Call it without an argument to keep the original default of Float32, otherwise pass in a numeric Pack datatype.

## [0.11.0] - 2026-03-18

### Added

- Pack:Reflect method for schema introspecion in Struct schemas, allowing you to resolve sub-schemas by path. Supports deep navigation through nested Dictionaries / SparseDictionaries.

### Changed

- Rewrite project README for clarity.
- Optimize CString implementation for near instant reads.

### Removed

- Support for the **Wally** package manager. Pack is now only available as a binary or through [Pesde](https://pesde.dev/packages/isoopod/pack). [see commit for reasoning](https://github.com/isoopod/Pack/commit/2660a601d91119c6c15244532c203b7a0a2add5a)

## [0.10.1] - 2025-12-08

### Fixed

- ConfigParser not parsing correctly and turning everything into virtual tables
- Debug mode always being enabled in studio

[unreleased]: https://github.com/isoopod/Pack/compare/v0.12.1...HEAD
[0.12.1]: https://github.com/isoopod/Pack/compare/v0.12.0...v0.12.1
[0.12.0]: https://github.com/isoopod/Pack/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/isoopod/Pack/compare/v0.10.1...v0.11.0
[0.10.1]: https://github.com/isoopod/Pack/compare/7fe49eef8207d53df84ae93875221f3cde098f85...v0.10.1
