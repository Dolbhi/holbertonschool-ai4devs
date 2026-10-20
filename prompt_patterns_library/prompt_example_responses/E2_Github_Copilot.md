### 2026-10-16

This update moves camera look input into the game update loop, buffering mouse movement and consuming it during gameplay. It also renames the camera mouse-rotation helper.

#### Features

- Buffer mouse movement in the app’s input state and apply it to the camera during gameplay, then clear the consumed movement.

#### Breaking Changes

- Rename the public `Camera::camera_rotation` helper to `Camera::mouse_rotation`. Update callers to use the new name.

