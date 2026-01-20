# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.4] - 2026-01-20

### Changed

- Updated `JobSerializer#serialize?` to check for `LinkedinUrlValue::Base` instead of `klass`. This fixes `ActiveJob::SerializationError: Unsupported argument type: LinkedinUrlValue::AsBlank` errors in Rails 8.1 by ensuring all LinkedinUrlValue types (Regular, Exceptional, AsBlank) can be serialized.

## [0.2.3] - 2026-01-02

### Changed

- Updated `JobSerializer#klass` to return `LinkedinUrlValue::Regular` instead of `LinkedinUrlValue::Base`. Rails job serialization uses an index hash where `Base` (an abstract class) will never match, so the serializer now returns the concrete `Regular` class.

## [0.2.2] - 2025-12-19

### Changed

- Added `klass` method to `JobSerializer` for Rails 8.1 compatibility. Rails 8.1 changed how `ActiveJob::Serializers::ObjectSerializer` works, requiring subclasses to implement a `klass` method that returns the class being serialized.
