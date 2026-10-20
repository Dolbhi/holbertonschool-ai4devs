# Prompt Testing Examples
## Example 1 - Feature Example
### Prompt:
Generate code implementing a feature using the rust crate egui with these requirements:

**Functional**: A UI element containing a dynamic list of buttons labelled with words which when clicked adds their corresponding word to a text box. At the top of the element is a tick box which turns all buttons into editable text fields which allows the corresponding word to be edited. 
**Non-functional**: The UI should be quick and responsive as well as intuitive to use.

Provide:
1. Commented code snipped of the implemented feature
2. Explanation of functions used and how they work
3. Alternative methods of implementation
### 1. ChatGPT
**AI Output**: [[E1_ChatGPT]]
**Feedback**: Complete, relatively short code for implementing feature, with both broad conceptual overview as well as line by line explanation. However, it does use an old version of egui (0.32, while the current version is 0.36)
### 2. Gemini
**AI Output**: [[E1_Gemini]]
**Feedback**: Fast response, full code with key function explanation. No conceptual overview and minor syntax error in code.
### 3. Claude
**AI Output**: [[E1_Claude]]
**Feedback**: Thoroughly commented code, organised explanation of functions, good conceptual overview. Using old version of egui.
### 4. Github Copilot
**AI Output**: [[E1_Github_Copilot]]
**Feedback**: Relatively short complete and well commented code with function explanation. Using old egui version with no conceptual overview. Limited alternatives.
## Example 2 - Generate Change Log
### Prompt
Act as a Technical Writer and Lead Developer. Generate a clear, structured Changelog from the provided git diff.

Target Audience: Internal Developers

Format Guidelines:
1. Follow Conventional Commits grouping standards:
   - Features (New functionality)
   - Bug Fixes (Fixes for existing issues)
   - Performance Improvements (Speed, memory, or efficiency gains)
   - Breaking Changes (Deprecations or incompatible API changes)
   - Maintenance & Internal (Refactoring, CI/CD, dependencies)
1. Entry Format: Use bullet points. Start each item with an imperative action verb (e.g., "Add", "Fix", "Update", "Remove").
2. For Breaking Changes: Highlight the old behaviour, the new behaviour, and a brief migration note.
3. Omit Noise: Filter out trivial commits (e.g., typos, merge conflict resolution, formatting changes) unless explicitly relevant.

Output Requirements:
- Title: Release version or date header (e.g., ## YYYY-MM-DD)
- Summary: A 1-2 sentence executive summary of the release focus.
- Grouped Categories: Only include sections that have relevant changes.

Input Data:
```diff
diff --git a/src/app.rs b/src/app.rs
index fcfbebb..fc2f600 100644
--- a/src/app.rs
+++ b/src/app.rs
@@ -7,7 +7,7 @@ use std::{
     time::{Duration, Instant},
 };
 
-use cgmath::{InnerSpace, Matrix3, One, Quaternion, Vector3, Vector4};
+use cgmath::{InnerSpace, Matrix3, Vector2, Vector3, Vector4};
 use legion::*;
 
 // use rand::Rng;
@@ -40,7 +40,6 @@ struct Graphics {
 pub struct App {
     graphics: Option<Graphics>,
     world: Arc<Mutex<GameWorld>>,
-    camera_rotation: Quaternion<f32>,
     game_thread: GameWorldThread,
     inputs: InputState,
     game_state: GameState,
@@ -74,7 +73,6 @@ impl App {
             graphics: None,
             inputs: InputState::default(),
             world,
-            camera_rotation: Quaternion::one(),
             game_thread,
             game_state: Default::default(),
             last_frame_time: Instant::now(),
@@ -168,6 +166,18 @@ impl App {
                         ..
                     } = &mut *self.world.lock().unwrap();
                     transforms.update_interpolation(*last_delta_time);
+                    /*
+                    ~~ Can occur in any order ~~
+                    input events modifies app.inputs
+
+                    logic update modifies world.inputs <== POTENTIAL BUGS
+
+                    world.inputs = app.inputs
+                    render update modifies world.inputs
+                    app.inputs = world.inputs
+                    ~~~
+                    Currently changes to world.inputs are discarded
+                    */
                     *inputs = self.inputs.clone();
 
                     // update basic mat swap
@@ -255,7 +265,8 @@ impl App {
                     // send inputs to game world
                     if self.game_state == GameState::Playing {
                         // inputs.movement = self.inputs.get_move();
-                        camera.set_rotation(self.camera_rotation);
+                        camera.move_rotation(inputs.mouse_move.x, inputs.mouse_move.y);
+                        inputs.mouse_move = [0., 0.].into();
 
                         // allow moving while frozen
                         if self
@@ -685,10 +696,8 @@ impl ApplicationHandler for App {
         event: winit::event::DeviceEvent,
     ) {
         if let DeviceEvent::MouseMotion { delta } = event {
-            if self.game_state == GameState::Playing {
-                Camera::camera_rotation(&mut self.camera_rotation, delta.0 as f32, delta.1 as f32);
-            }
-        }
+            self.inputs.mouse_move += Vector2::new(delta.0 as f32, delta.1 as f32);
+        };
     }
 }
 
diff --git a/src/game_objects/camera.rs b/src/game_objects/camera.rs
index 1817d73..10256cb 100644
--- a/src/game_objects/camera.rs
+++ b/src/game_objects/camera.rs
@@ -21,7 +21,8 @@ pub struct Camera {
 }
 
 impl Camera {
-    pub fn camera_rotation(current: &mut Quaternion<f32>, dx: f32, dy: f32) {
+    /// Rotate a given rotation based on mouse movements
+    pub fn mouse_rotation(current: &mut Quaternion<f32>, dx: f32, dy: f32) {
         let old_pitch = Rad::atan(current.v.x / current.s);
         let delta_pitch = clamp(
             Rad(-dy * MOUSE_SENSITIVITY),
@@ -37,6 +38,9 @@ impl Camera {
     pub fn set_rotation(&mut self, rotation: Quaternion<f32>) {
         self.rotation = rotation;
     }
+    pub fn move_rotation(&mut self, dx: f32, dy: f32) {
+        Self::mouse_rotation(&mut self.rotation, dx, dy);
+    }
     // pub fn rotate(&mut self, dx: f32, dy: f32) {
     //     Self::camera_rotation(&mut self.rotation, dx, dy);
     // }
diff --git a/src/game_objects/game_world.rs b/src/game_objects/game_world.rs
index f84fc9d..1ff8eb4 100644
--- a/src/game_objects/game_world.rs
+++ b/src/game_objects/game_world.rs
@@ -10,8 +10,8 @@ use super::{
 };
 use legion::*;
 
-pub const CAM_SPEED: f32 = 6.;
-pub const SLOW_COEFF: f32 = 0.1;
+// pub const CAM_SPEED: f32 = 6.;
+// pub const SLOW_COEFF: f32 = 0.1;
 
 macro_rules! run_update_mut {
     ($game_world:expr, $type:ty) => {
diff --git a/src/input.rs b/src/input.rs
index e70aa39..95b8d61 100644
--- a/src/input.rs
+++ b/src/input.rs
@@ -134,14 +134,16 @@ impl ButtonState {
         self.just_pressed
     }
 
+    /// True if button was held down last frame
     pub fn get_was_pressed(&self) -> bool {
         self.was_pressed
     }
+    /// True if button switched from pressed to not pressed last frame
     pub fn get_just_pressed(&self) -> bool {
         self.just_pressed
     }
 
-    /// get button_down and reset it (kinda like an Option::take() actually)
+    /// get just_pressed and reset it (kinda like an Option::take() actually)
     pub fn consume_button_down(&mut self) -> bool {
         if self.just_pressed {
             self.just_pressed = false;
```

### 1. ChatGPT
**AI Output**: [[E2_ChatGPT]]
**Feedback:** Accurate explanation of each change and reasoning and useful notes on the consequences of the change, documentation changes also documented and explained. Slightly lengthy.
### 2. Gemini
**AI Output**: [[E2_Gemini]]
**Feedback:** Well structured change log with helpful section of breaking changes. Instead of simply listing changes, they are explained relative to the overarching goal.
### 3. Claude
**AI Output**: [[E2_Claude]]
**Feedback:** Change-by-change explanation, good summary of breaking changes. Camera changing only in a certain state listed as bug fix however notes acknowledges that I could be a feature. Slightly lengthy.
### 4. Github Copilot
**AI Output**: [[E2_Github_Copilot]]
**Feedback:** Very short conceptual overview.
## Example 3 - Verify Code
### Prompt
**Role**: Senior Developer
**Task**: Analyse the given code for a ray struct for raycasting against cuboids, searching for any issues or bugs.
**Input Placeholder**:
```rust
use super::BoundingBox;
use crate::physics::{matrix_truncate, Vector};
use cgmath::{InnerSpace, Matrix4, Zero};

#[derive(Clone)]
pub struct Ray {
    pub origin: Vector,
    pub direction: Vector,
    pub distance: f32,
}
  
impl Ray {
    /// creates ray with normalised direction
    pub fn new(origin: Vector, direction: Vector, distance: f32) -> Self {
        Self {
            origin,
            direction: direction.normalize(),
            distance,
        }
    }
  
    /// creates ray with normalised direction
    pub fn from_points(start: Vector, end: Vector) -> Self {
        let direction = end - start;
        let distance = direction.magnitude();
        Self {
            origin: start,
            direction: direction / distance,
            distance,
        }
    }
  
    /// Assumes model is normalised
    ///
    /// Resulting ray is not normalised
    pub fn transform_model(&mut self, model: &Matrix4<f32>) {
        // self.origin += model.w.truncate();
        self.origin = (model * self.origin.extend(1.)).truncate();
        self.direction = matrix_truncate(model) * self.direction;
    }
  
    /// convert distance returned by intersection dectection to point on ray
    pub fn calc_point(&self, distance: f32) -> Vector {
        self.origin + self.direction * distance
    }
  
    /// translate origin by distance * self.direction, reduce self.distance accordingly
    pub fn advance(&mut self, distance: f32) {
        self.origin += self.direction * distance;
        self.distance -= distance;
    }
  
    /// Gives distance to intercept point on cuboid
    ///
    /// see also: `box_intersection`
    pub fn cuboid_intersection(&self, inv_cuboid_model: &Matrix4<f32>) -> Option<f32> {
        let mut cub_space_ray = self.clone();
        cub_space_ray.transform_model(inv_cuboid_model);
        cub_space_ray.box_intersection(&BoundingBox::new((-1., -1., -1.), (1., 1., 1.)))
    }
  
    /// only gives result on valid intersect and only returns distance to entering intersect
    ///
    /// multiply returned distance by ray.direction to get ray displacement (see also: `calc_point`
    pub fn box_intersection(&self, bounds: &BoundingBox) -> Option<f32> {
        let (close, far) = self.box_intersection_raw(bounds);
  
        if close <= far && close <= self.distance {
            if close < 0. {
                if far < 0. {
                    // intercepting completely behind ray
                    None
                } else {
                    // ray origin in box
                    Some(0.)
                }
            } else {
                // normal interception
                Some(close)
            }
        } else {
            None
        }
    }
  
    /// self.distance is unused here
    pub fn box_intersection_raw(&self, bounds: &BoundingBox) -> (f32, f32) {
        let mut closest = f32::NEG_INFINITY;
        let mut furthest = f32::INFINITY;
  
        for i in 0..3 {
            if self.direction[i].is_zero() {
                continue;
            }
  
            let low = (bounds.min[i] - self.origin[i]) / self.direction[i];
            let high = (bounds.max[i] - self.origin[i]) / self.direction[i];
  
            let (close, far) = if low < high { (low, high) } else { (high, low) };
  
            if close > closest {
                closest = close
            };
            if far < furthest {
                furthest = far
            };
        }
        (closest, furthest)
    }
}
```
**Language**: Rust
**Expected Output**: Description and explanation of possible bugs or unintended behaviour that may arise from the given code.
### 1. ChatGPT
**AI Output**: [[E3_ChatGPT]]
**Feedback**: Summary of issues found + through explanation with examples. Understood many undocumented contracts such as distance in world-space or parameter-space after transformations.
### 2. Gemini
**AI Output**: [[E3_Gemini]]
### 3. Claude
**AI Output**: [[E3_Claude]]
### 4. Github Copilot
**AI Output**: [[E3_Github_Copilot]]

## Example 4 - Factor Function
### Prompt
**Role**: Senior Developer
**Task**: Refactor lines between `// #REFACTOR_START` and `// #REFACTOR_END` into a separate function that will be inserted in the same file.
**Input Placeholder**:
```rust
update(&mut graphics.renderer, |renderer, image_i, context| {
	let GameWorld {
		world,
		resources: GameResources {
			transforms,
			colliders,
			camera,
			fixed_seconds,
			last_delta_time,
			inputs,
		},
		..
	} = &mut *self.world.lock().unwrap();
	transforms.update_interpolation(*last_delta_time);
	*inputs = self.inputs.clone();

	// update basic mat swap
	if inputs.q.consume_button_down() {
		let mut query =
			<(&mut MaterialSwapper<()>, &mut RenderObject<()>)>::query();

		query.for_each_mut(world, |(swapper, render_object)| {
			let next_mat = swapper.swap_material();
			// println!("Swapped mat: {:?}", next_mat);
			render_object.material = next_mat;
		});
	}

	// add new cube (not a system YET)
	if inputs.o.consume_button_down() {
		// create unit cube at cam position and rotation
		let cam_transform = transforms
			.get_transform(&camera.transform)
			.unwrap()
			.get_local_transform();
		let pos = *cam_transform.translation;
		let rot = *cam_transform.rotation;

		let transform = transforms
			.add_transform(TransformCreateInfo::from(pos).set_rotation(rot));

		let mut rigidbody = RigidBody::new(transform);
		// rigidbody.gravity_multiplier = 0.0;
		rigidbody.set_moi_as_cuboid((1., 1., 1.).into());
		let rigidbody = Arc::new(RwLock::new(rigidbody));

		let collider = CuboidCollider::new(transform, Some(rigidbody.clone()), 2., 1.7);
		let inserted_collider = colliders.add(collider, transforms);

		let mut resource_loader =
			graphics.resources.begin_retrieving(context, renderer);
		let red_material =
			resource_loader.load_solid_material([1., 0., 0., 1.], true);
		let ro = resource_loader.load_ro(
			crate::render::resource_manager::MeshID::Cube,
			red_material.0,
			true,
		);

		load_object!(world, transform, inserted_collider, ro, rigidbody);
	}

	// raycast
	let cam_model = transforms.get_global_model(&camera.transform).unwrap();
	let raycast_result = colliders.raycast(
		transforms,
		cam_model.w.truncate(),
		-cam_model.z.truncate(),
		20.,
	);
	let mut raycast_data = None;
	if let Some((point, coll)) = raycast_result {
		let min_cast: [f32; 3] = (point - Vector3::new(0.1, 0.1, 0.1)).into();
		let max_cast: [f32; 3] = (point + Vector3::new(0.1, 0.1, 0.1)).into();
		raycast_data = Some((min_cast, max_cast));

		if inputs.lmb.consume_button_down() {
			if let Some(rigidbody) = coll.get_rigidbody() {
				let _ = rigidbody.write().unwrap().apply_impulse_global(
					point,
					-1.5 * cam_model.z.truncate().normalize(),
					transforms,
				);
			}
		}
	}

	// send inputs to game world
	if self.game_state == GameState::Playing {
		// inputs.movement = self.inputs.get_move();
		camera.move_rotation(inputs.mouse_move.x, inputs.mouse_move.y);
		inputs.mouse_move = [0., 0.].into();

		// only move cam directly if it is unparented
		if transforms.get_transform(&camera.transform).unwrap().get_parent().is_none() {
			// move cam
			inputs.move_transform(
				transforms.get_transform_mut(&camera.transform).unwrap(),
				Instant::now()
				.duration_since(self.last_frame_time)
				.as_secs_f32(),
				6.,
				0.1,
			);
		}
	}
	self.inputs = inputs.clone();
	camera.sync_transform(transforms);

	//  Render uploads
	// TODO: have `deferred_renderer` provide this method since it defines the RO types
	// P.S. Could also have a generic method to handle any RO type
	// P.P.S Could also have a generic method to handle any world queries with iteration???
	{
		// update basic render objects
		// println!("==== RENDER OBJECT DATA ====");
		<(&TransformID, &mut RenderObject<()>)>::query().for_each_mut(world, |(transform_id, render_object)| {
			render_object.update_and_upload(transform_id, transforms);
		});

		// println!("==== RENDER COLORED DATA ====");
		<(&TransformID, &mut RenderObject<Vector4<f32>>)>::query().for_each_mut(world, |(transform_id, render_object)| {
			render_object.update_and_upload(transform_id, transforms);
		});
		
	}

	// get frame data struct for upload
	let frame = renderer.prepare_frame(image_i);
	frame.update_global_data(GPUGlobalData::from_camera(camera, extends));

	// gather debug bounding boxes to draw
	if self.bounds_debug_depth == Some(colliders.tree_depth()) {
		self.bounds_debug_depth = None;
	}
	// #REFACTOR_START
	{
		// currently possible to exceed the bounding box rendering buffer limit with like 12 colliders
		let mut bounding_boxes: Vec<GPUAABB> =
			if let Some(debug_depth) = self.bounds_debug_depth {
				colliders
					.bounds_iter()
					.filter(|(_, depth)| *depth == debug_depth)
					.map(|(bounds, depth)| {
						let mag = 1. / (depth as f32 + 1.);
						let min_cast: [f32; 3] = bounds.min.into();
						let max_cast: [f32; 3] = bounds.max.into();
						GPUAABB {
							min: min_cast.into(),
							max: max_cast.into(),
							color: [1., mag, mag, 1.],
						}
					})
					.collect()
			} else {
				colliders
					.bounds_iter()
					.map(|(bounds, depth)| {
						let mag = 1. / (depth as f32 + 1.);
						let min_cast: [f32; 3] = bounds.min.into();
						let max_cast: [f32; 3] = bounds.max.into();
						GPUAABB {
							min: min_cast.into(),
							max: max_cast.into(),
							color: [1., mag, mag, 1.],
						}
					})
					.collect()
			};
		if let Some((min, max)) = raycast_data {
			bounding_boxes.insert(
				bounding_boxes.len(),
				GPUAABB {
					min: min.into(),
					max: max.into(),
					color: [1., 0., 1., 1.],
				},
			);
		}
		// show overlaps
		for (coll_1, coll_2) in colliders.get_potential_overlaps() {
			let bounds_1 = coll_1.calc_bounding(transforms);
			let bounds_2 = coll_2.calc_bounding(transforms);

			let centre = bounds_1.centre();
			let min_cast: [f32; 3] = (centre - Vector3::new(0.1, 0.1, 0.1)).into();
			let max_cast: [f32; 3] = (centre + Vector3::new(0.1, 0.1, 0.1)).into();
			bounding_boxes.push(GPUAABB {
				min: min_cast.into(),
				max: max_cast.into(),
				color: [0., 1., 0., 1.],
			});

			let centre = bounds_2.centre();
			let min_cast: [f32; 3] = (centre - Vector3::new(0.1, 0.1, 0.1)).into();
			let max_cast: [f32; 3] = (centre + Vector3::new(0.1, 0.1, 0.1)).into();
			bounding_boxes.push(GPUAABB {
				min: min_cast.into(),
				max: max_cast.into(),
				color: [1., 1., 0., 1.],
			});
		}
		// show contacts
		let contacts = colliders.get_last_contacts();
		let mut coll_lines = vec![];
		for (position, normal, age, penetration) in contacts {
			// colour
			let color = if *age == 0 {
				[0., 0., 1., 1.]
			} else {
				[0., 1., 1., 1.]
			};

			// contact point
			let min_cast: [f32; 3] =
				(position - Vector3::new(0.03, 0.03, 0.03)).into();
			let max_cast: [f32; 3] =
				(position + Vector3::new(0.03, 0.03, 0.03)).into();
			bounding_boxes.push(GPUAABB {
				min: min_cast.into(),
				max: max_cast.into(),
				color,
			});

			let min: [f32; 3] = (position.clone()).into();
			// normal points out from rb_1, position is on rb_1, so rb_2's pen point is opposite from normal dir
			let max: [f32; 3] = (position - normal * *penetration).into();

			coll_lines.push(GPUAABB {
				min: min.into(),
				max: max.into(),
				color,
			});
		}

		// lines (currently only vel lines in red and bivel in blue)
		let mut query = <(&TransformID, &Arc<RwLock<RigidBody>>)>::query();
		let lines = query
			.iter(world)
			.map(|(transform_id, rigidbody)| {
				// let a = RwLock::new(RigidBody::new(*transform_id));
				let read = rigidbody.try_read().unwrap();
				let model = transforms.get_global_model(transform_id).unwrap();
				let pos = model[3].truncate();
				let rotation = Matrix3::from_cols(
					model[0].truncate(),
					model[1].truncate(),
					model[2].truncate(),
				);

				[
					[-1., -1., -1.],
					[1., -1., -1.],
					[-1., 1., -1.],
					[-1., -1., 1.],
					[-1., 1., 1.],
					[1., -1., 1.],
					[1., 1., -1.],
					[1., 1., 1.],
				]
				.map(|c| {
					let v: Vector3<f32> = c.into();
					let d = rotation * v;
					let p = d + pos;
					GPUAABB {
						min: Into::<[f32; 3]>::into(p).into(),
						max: Into::<[f32; 3]>::into(
							p + read.point_velocity(d) * 0.2,
						)
						.into(),
						color: [1., 0., 0., 1.],
					}
				})
			})
			.flatten()
			.chain(coll_lines);
		// .collect::<Vec<Vec<GPUAABB>>>()
		// .into_iter()
		// .flatten();

		frame.update_box_data(bounding_boxes.into_iter(), lines.into_iter());
	}
	// #REFACTOR_END

	// point lights
	let mut point_query = <(&TransformID, &PointLightComponent)>::query();
	let point_lights = point_query.iter(world).map(|(t, pl)| {
		let pos = transforms.get_lerp_model(t).unwrap()[3];
		pl.clone().into_light(pos.truncate() / pos.w)
	});
	frame.update_point_lights(point_lights);

	// directional lights
	// let mut dl_query = <(&TransformID, &DirectionalLightComponent)>::query();
	let angle = *fixed_seconds / 4.;
	let direction =
		cgmath::InnerSpace::normalize(cgmath::vec3(angle.sin(), -1., angle.cos()));
	let dir = DirectionLight {
		color: [0.5, 0.5, 0., 1.],
		direction: direction.extend(1.).into(),
	};
	frame.update_directional_lights([dir].into_iter());

	// ambient light
	renderer
		.lighting_system
		.set_ambient_color([0.1, 0.1, 0.1, 1.]);
});
```
**Language**: Rust
**Expected Output**: Code is replaced by a function call while maintaining the same behaviour.
### 1. ChatGPT
**AI Output**: [[E4_ChatGPT]]
### 2. Gemini
**AI Output**: [[E4_Gemini]]
### 3. Claude
**AI Output**: [[E4_Claude]]
### 4. Github Copilot
**AI Output**: [[E4_Github_Copilot]]

## Example 5 - Insert Comments
### Prompt
### 1. ChatGPT
**AI Output**: [[E5_ChatGPT]]
### 2. Gemini
**AI Output**: [[E5_Gemini]]
### 3. Claude
**AI Output**: [[E5_Claude]]
### 4. Github Copilot
**AI Output**: [[E5_Github_Copilot]]