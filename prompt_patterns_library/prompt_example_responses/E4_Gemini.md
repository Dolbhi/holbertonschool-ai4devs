The refactored code extracts the debug bounding box and line gathering logic into a helper method `gather_debug_boxes_and_lines`.

### Updated Closure Snippet

Rust

```
	// gather debug bounding boxes to draw
	if self.bounds_debug_depth == Some(colliders.tree_depth()) {
		self.bounds_debug_depth = None;
	}

	let (bounding_boxes, lines) = self.gather_debug_boxes_and_lines(
		colliders,
		transforms,
		raycast_data,
		world,
	);
	frame.update_box_data(bounding_boxes.into_iter(), lines.into_iter());

	// point lights
```

### Extracted Helper Function

Add this helper method to the `impl` block containing `self` (or as a standalone function in the same module by removing `&self`):

Rust

```
impl MyStruct {
	fn gather_debug_boxes_and_lines(
		&self,
		colliders: &Colliders,
		transforms: &Transforms,
		raycast_data: Option<([f32; 3], [f32; 3])>,
		world: &World,
	) -> (Vec<GPUAABB>, Vec<GPUAABB>) {
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
			bounding_boxes.push(GPUAABB {
				min: min.into(),
				max: max.into(),
				color: [1., 0., 1., 1.],
			});
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
			.chain(coll_lines)
			.collect();

		(bounding_boxes, lines)
	}
}
```

### Refactoring Notes

- Replaced `bounding_boxes.insert(bounding_boxes.len(), ...)` with `bounding_boxes.push(...)`.
    
- Collected the lazy `lines` iterator pipeline inside the extracted function so it returns clean, fully-evaluated `Vec<GPUAABB>` structures to pass to `frame.update_box_data`.