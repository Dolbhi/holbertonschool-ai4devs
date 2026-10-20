I’ve moved the block between the markers into a function, `upload_debug_boxes`, and replaced it with one call. Your snippet doesn’t show the concrete type names, so I guessed them (marked below).

### Call site

rust

```rust
	// gather debug bounding boxes to draw
	if self.bounds_debug_depth == Some(colliders.tree_depth()) {
		self.bounds_debug_depth = None;
	}
	upload_debug_boxes(
		frame,
		world,
		transforms,
		colliders,
		self.bounds_debug_depth,
		raycast_data,
	);
```

### New function (same file, outside the closure)

rust

```rust
fn upload_debug_boxes(
	frame: &mut Frame,                        // type returned by `renderer.prepare_frame`
	world: &World,                            // legion::World
	transforms: &TransformStorage,            // type behind `transforms`
	colliders: &ColliderSet,                  // type behind `colliders`
	bounds_debug_depth: Option<usize>,        // match the type of `tree_depth()`
	raycast_data: Option<([f32; 3], [f32; 3])>,
) {
	// currently possible to exceed the bounding box rendering buffer limit with like 12 colliders
	let mut bounding_boxes: Vec<GPUAABB> =
		if let Some(debug_depth) = bounds_debug_depth {
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
		let min_cast: [f32; 3] = (position - Vector3::new(0.03, 0.03, 0.03)).into();
		let max_cast: [f32; 3] = (position + Vector3::new(0.03, 0.03, 0.03)).into();
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
					max: Into::<[f32; 3]>::into(p + read.point_velocity(d) * 0.2).into(),
					color: [1., 0., 0., 1.],
				}
			})
		})
		.flatten()
		.chain(coll_lines);

	frame.update_box_data(bounding_boxes.into_iter(), lines.into_iter());
}
```

### Notes

- **Parameters:** The block reads `colliders`, `transforms`, `world`, `raycast_data`, `frame` and `self.bounds_debug_depth`. It only reads the depth, so I pass it by value. The reset to `None` stays at the call site, before the call, to keep the order of operations.
- **Types to adjust:** `Frame`, `World`, `TransformStorage`, `ColliderSet` and the integer type of `bounds_debug_depth` are placeholders. Replace them with your real types, for example the actual return type of `prepare_frame`.
- **Borrows:** `transforms`, `colliders` and `world` come from `&mut *self.world.lock().unwrap()`, so they are `&mut` references. They auto-reborrow as shared references at the call, which works because the block only reads them. If the compiler complains, write `&*transforms` and `&*colliders` explicitly.
- **Removed:** I dropped the commented-out lines (`// let a = ...` and the `.collect::<Vec<...>>` remnants). They had no effect, so behaviour is unchanged.