The refactor can be extracted into a standalone function that accepts the required world, collider, transform, frame, and raycast data references. The function preserves the existing bounding-box generation, overlap visualization, contact visualization, rigidbody velocity lines, and frame upload behavior.

### 1. Replace the marked block with a function call

```
update_debug_render_data(
    world,
    transforms,
    colliders,
    frame,
    raycast_data,
);
```

### 2. Add the extracted function to the same file

```
fn update_debug_render_data(
    world: &World,
    transforms: &Transforms,
    colliders: &Colliders,
    frame: &mut Frame,
    raycast_data: Option<([f32; 3], [f32; 3])>,
) {
    // Currently possible to exceed the bounding box rendering buffer
    // limit with approximately 12 colliders.
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

    // Show the raycast hit.
    if let Some((min, max)) = raycast_data {
        bounding_boxes.push(GPUAABB {
            min: min.into(),
            max: max.into(),
            color: [1., 0., 1., 1.],
        });
    }

    // Show potential overlaps.
    for (coll_1, coll_2) in colliders.get_potential_overlaps() {
        let bounds_1 = coll_1.calc_bounding(transforms);
        let bounds_2 = coll_2.calc_bounding(transforms);

        let centre = bounds_1.centre();
        let min_cast: [f32; 3] =
            (centre - Vector3::new(0.1, 0.1, 0.1)).into();
        let max_cast: [f32; 3] =
            (centre + Vector3::new(0.1, 0.1, 0.1)).into();

        bounding_boxes.push(GPUAABB {
            min: min_cast.into(),
            max: max_cast.into(),
            color: [0., 1., 0., 1.],
        });

        let centre = bounds_2.centre();
        let min_cast: [f32; 3] =
            (centre - Vector3::new(0.1, 0.1, 0.1)).into();
        let max_cast: [f32; 3] =
            (centre + Vector3::new(0.1, 0.1, 0.1)).into();

        bounding_boxes.push(GPUAABB {
            min: min_cast.into(),
            max: max_cast.into(),
            color: [1., 1., 0., 1.],
        });
    }

    // Show collision contacts.
    let contacts = colliders.get_last_contacts();
    let mut coll_lines = vec![];

    for (position, normal, age, penetration) in contacts {
        let color = if *age == 0 {
            [0., 0., 1., 1.]
        } else {
            [0., 1., 1., 1.]
        };

        // Contact point.
        let min_cast: [f32; 3] =
            (position - Vector3::new(0.03, 0.03, 0.03)).into();
        let max_cast: [f32; 3] =
            (position + Vector3::new(0.03, 0.03, 0.03)).into();

        bounding_boxes.push(GPUAABB {
            min: min_cast.into(),
            max: max_cast.into(),
            color,
        });

        let min: [f32; 3] = (*position).into();

        // The normal points out from rb_1, and the position is on rb_1.
        // Therefore, rb_2's penetration point is opposite the normal.
        let max: [f32; 3] =
            (position - normal * *penetration).into();

        coll_lines.push(GPUAABB {
            min: min.into(),
            max: max.into(),
            color,
        });
    }

    // Draw rigidbody velocity vectors.
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
            .map(|corner| {
                let v: Vector3<f32> = corner.into();
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

    frame.update_box_data(bounding_boxes.into_iter(), lines.into_iter());
}
```

### Important adjustments

The example above illustrates the extraction, but the original code's `self.bounds_debug_depth` introduces a dependency on the owning type. For a compilable refactor, pass that value explicitly and use the actual project types for `World`, `Transforms`, `Colliders`, and `Frame`.

For example, if `bounds_debug_depth` belongs to the current application struct, the signature should include:

```
fn update_debug_render_data(
    world: &World,
    transforms: &Transforms,
    colliders: &Colliders,
    frame: &mut Frame,
    raycast_data: Option<([f32; 3], [f32; 3])>,
    bounds_debug_depth: Option<usize>,
)
```

Then replace `self.bounds_debug_depth` inside the extracted function with `bounds_debug_depth`.

Behavior preserved: the extracted function retains the existing debug colors, depth filtering, overlap and contact markers, velocity-vector calculations, and final `update_box_data` call. The concrete type names and imports should be adapted to the definitions in your project.