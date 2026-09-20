## [Unreleased]

## [0.3.3] - 2026-08-19

- Reset the per-thread guard cache on the action's own thread via an `around_action`, preventing the authenticated user from leaking across requests under `ActionController::Live`.

## [0.1.0] - 2022-10-15

- Initial release
