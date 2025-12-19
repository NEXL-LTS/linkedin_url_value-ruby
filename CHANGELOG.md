# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2025-12-19

### Changed

- Added `klass` method to `JobSerializer` for Rails 8.1 compatibility. Rails 8.1 changed how `ActiveJob::Serializers::ObjectSerializer` works, requiring subclasses to implement a `klass` method that returns the class being serialized.
