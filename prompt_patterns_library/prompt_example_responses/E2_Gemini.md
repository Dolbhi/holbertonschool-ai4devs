### 2026-10-16

#### Summary

This release refactors camera rotation state handling by decoupling rotational storage from the main `App` struct and shifting delta updates into the `InputState` pipeline. It also includes public API renames for camera rotation methods and minor doc comment improvements.

#### Features

- **Accumulate mouse delta in input state:** Route raw `DeviceEvent::MouseMotion` events directly into `InputState.mouse_move` and reset the delta each frame during the game loop update.

#### Breaking Changes

- **Renamed `Camera::camera_rotation` to `Camera::mouse_rotation` and updated camera mutation API:**
    - **Old Behaviour:** `App` maintained a `camera_rotation: Quaternion<f32>` field, updated it directly in `DeviceEvent::MouseMotion`, and applied it via `Camera::set_rotation`. `Camera` exposed `camera_rotation`.
    - **New Behaviour:** `camera_rotation` field is removed from `App`. Rotation state is held internally by `Camera` and updated directly via the new `Camera::move_rotation` method using accumulated mouse deltas.
    - **Migration Note:** Replace calls to `Camera::camera_rotation(&mut camera_rotation, dx, dy)` with `camera.move_rotation(dx, dy)` directly on your `Camera` instance, or use `Camera::mouse_rotation` if manipulating an explicit `Quaternion<f32>` reference.

#### Maintenance & Internal

- **Add helper methods to `Camera`:** Add `move_rotation(&mut self, dx, dy)` to apply mouse rotation directly to instance state.
- **Clean up unused imports and constants:** Remove `Quaternion` import from `src/app.rs` (replaced with `Vector2`) and comment out unused `CAM_SPEED` / `SLOW_COEFF` constants in `src/game_objects/game_world.rs`.
- **Improve input documentation:** Add doc comments to `ButtonState` methods (`get_was_pressed`, `get_just_pressed`) and update doc text on `consume_button_down`.