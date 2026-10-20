### 2026-10-16

**Summary**

Refactor camera input handling to process mouse movement through the game world's input state, centralizing camera rotation updates in the camera component. Improve input-state documentation and clarify button transition semantics.

#### Features

- **Integrate mouse movement into game input processing:** Accumulate mouse-motion events in `App.inputs.mouse_move` and apply them to the camera during the game update when the game is in the `Playing` state.
- **Add camera rotation movement API:** Introduce `Camera::move_rotation(dx, dy)` to update the camera's current rotation using mouse movement, delegating rotation calculations to `Camera::mouse_rotation()`.

#### Maintenance & Internal

- **Rename the camera rotation helper:** Rename `Camera::camera_rotation()` to `Camera::mouse_rotation()` to better describe its responsibility for calculating rotation from mouse deltas.
- **Remove application-level camera rotation state:** Eliminate `App.camera_rotation` and its initialization, making the camera component responsible for maintaining its rotation.
- **Reset mouse movement after processing:** Clear `inputs.mouse_move` after applying camera rotation to prevent accumulated mouse deltas from being reapplied across frames.
- **Clarify button-state semantics:** Document `get_was_pressed()` and `get_just_pressed()` to distinguish held-button state from button transitions, and correct the `consume_button_down()` documentation to reference `just_pressed`.
- **Disable unused camera movement constants:** Comment out `CAM_SPEED` and `SLOW_COEFF` in `game_world.rs`, as they are currently unused.

#### Developer Notes
- **Review input-state synchronization:** The current update flow copies `App.inputs` into `GameWorld.inputs`, potentially discarding changes made to the world's input state during logic or rendering updates. Revisit ownership and synchronization if both states need to be mutable.
- **Verify mouse-input lifecycle:** Mouse motion is now accumulated regardless of game state, but camera rotation is applied only while playing. Confirm whether retaining accumulated mouse movement while paused or outside gameplay is intentional.