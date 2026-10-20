### 2026-10-16

**Summary:** Camera rotation is now driven by accumulated mouse input in the shared `InputState`, replacing the separate rotation state previously held in `App`. This release also includes minor documentation fixes and dead-code cleanup.

#### Bug Fixes

- Fix camera rotation only updating while `GameState::Playing`. Mouse motion is now always accumulated into `inputs.mouse_move` and applied in the render update, so no motion is lost to state-gated handling.
- Fix inaccurate doc comment on `ButtonState::consume_button_down`. It now correctly states that it consumes `just_pressed`.

#### Maintenance & Internal

- Refactor camera rotation to use `InputState.mouse_move` (a `Vector2<f32>`) instead of a standalone `camera_rotation` quaternion on `App`.
- Add `Camera::move_rotation` to apply mouse deltas directly to the camera’s own rotation.
- Rename `Camera::camera_rotation` to `Camera::mouse_rotation` and add a doc comment.
- Remove unused `camera_rotation` field from `App` and the now-unused `Quaternion` and `One` imports.
- Comment out unused constants `CAM_SPEED` and `SLOW_COEFF` in `game_world.rs`.
- Document the input data flow between `App` and `GameWorld`, including a known risk: changes to `world.inputs` during the logic update are currently discarded (`app.rs`).
- Add doc comments for `ButtonState::get_was_pressed` and `ButtonState::get_just_pressed`.

#### Breaking Changes

- **`Camera::camera_rotation` renamed to `Camera::mouse_rotation`**
    - **Old behaviour:** Callers used `Camera::camera_rotation(&mut quat, dx, dy)`, and `App` kept its own `camera_rotation` quaternion, which it passed to `camera.set_rotation(...)` each frame.
    - **New behaviour:** `Camera::mouse_rotation` takes the same arguments under the new name. `App` no longer stores a rotation. It accumulates mouse deltas in `inputs.mouse_move`, and the render update calls `camera.move_rotation(dx, dy)` and then resets `mouse_move`.
    - **Migration:** Update any callers of `Camera::camera_rotation` to `Camera::mouse_rotation`, or use `Camera::move_rotation` to rotate a camera instance directly. Code that read `App::camera_rotation` should read the camera’s rotation instead. Any new code that consumes mouse motion must read and reset `inputs.mouse_move` to avoid double application.

**Notes:**

- I classified the mouse-capture change as a bug fix based on the diff alone. If you’d rather list it under Features or Maintenance, it’s an easy swap.
- The renamed method is internal, so the breaking-change entry mainly matters if other modules or branches call it.
