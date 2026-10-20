## Code review: `Ray` (raycasting against cuboids)

The overall slab-method approach is sound, and the `t` parameter is preserved correctly through `transform_model`. There is one significant correctness bug, a few degenerate-input problems, and some semantic hazards.

### 1. Rays parallel to a slab always pass that axis (real bug)

rust

```rust
if self.direction[i].is_zero() {
    continue;
}
```

For an axis where the direction component is zero, the ray never leaves its current slab on that axis. If the origin is **outside** `[min[i], max[i]]` on that axis, the ray can never hit the box. Skipping the axis ignores this, so you get false positives.

Example: a ray at `(5, 0, 0)` travelling along `+y` should miss a box spanning `[-1, 1]` on x, but this code will report a hit.

**Fix:** reject when the origin is outside the slab.

rust

```rust
if self.direction[i].is_zero() {
    if self.origin[i] < bounds.min[i] || self.origin[i] > bounds.max[i] {
        return (f32::INFINITY, f32::NEG_INFINITY); // guaranteed miss (close > far)
    }
    continue;
}
```

Alternatively, drop the `continue` and let IEEE division produce `±inf`. That works except when the origin lies exactly on a face, which gives `0/0 = NaN`, so the explicit check above is safer.

### 2. Zero or degenerate direction

- `Ray::new` with a zero-length direction produces NaN, because `normalize()` divides by zero.
- `from_points(a, a)` gives `distance = 0` and `direction = 0/0 = NaN`.
- If direction is all zeros (or the NaN-skipping path leaves it that way), `box_intersection_raw` returns `(-inf, +inf)`. `box_intersection` then returns `Some(0.)`, meaning “always hits”.

Guard in the constructors (return `Option`, or fall back to a default direction), and treat NaN/zero directions as a miss.

### 3. NaN handling is accidental

Comparisons with NaN are always false. In `box_intersection_raw`, a NaN `close`/`far` is silently ignored by the `>` / `<` updates, and `low < high` with NaN falls into the `else` branch. This can mask errors and produce a hit or miss by accident. Origins lying exactly on a face with zero direction components are the most likely trigger.

### 4. `distance` semantics are fragile

- **After `transform_model`:** the direction is no longer unit length, so `distance` is no longer a Euclidean length. It is a `t`-parameter bound. The comparison `close <= self.distance` works inside `cuboid_intersection` only because `self` was normalised beforehand. If a ray is transformed twice, or a pre-transformed ray is passed in, the check is wrong. The docs mention “not normalised” but not that `distance` changes meaning.
- **`advance`:** nothing prevents `distance` going negative. With a negative distance, `close <= self.distance` fails for everything except an origin-inside case, which can behave inconsistently. Clamp it or return an `Option`.
- **`advance` also assumes a normalised direction.** After `transform_model` it will still be internally consistent in `t` units, but not in world units.

### 5. Edge-case semantics worth confirming

- **Origin inside the box returns `Some(0.)`.** That is reasonable, but it differs from “distance to entering intersect” as the doc states. Callers may not expect an exit-only case to look like a hit at 0.
- **Grazing hits count** (`close <= far`), so a ray touching an edge or corner is a hit. Float error makes this inconsistent either way, so use an epsilon if it matters.
- **Rays that start exactly on a face** and point away can return `Some(0.)` or `None` depending on float rounding.

### 6. Minor points

- `is_zero()` is an exact comparison, so tiny non-zero components yield huge but finite `t` values. That is usually fine, but it contrasts with the exact-zero special case, which behaves differently (bug 1).
- `cuboid_intersection` clones the whole ray just to transform it. Transforming only `origin` and `direction` avoids the copy.
- The parameter name `inv_cuboid_model` makes the caller responsible for passing the inverse. Passing the forward model silently gives wrong results, so it’s worth documenting more loudly or taking the model and inverting internally.
- `matrix_truncate` isn’t shown. It must return the upper-left 3×3 without translation, or direction vectors will be transformed incorrectly.
- The commented-out `self.origin += model.w.truncate()` is dead code and can go. The doc comment on `box_intersection` has an unclosed parenthesis. `from_points` repeats the “creates ray with normalised direction” comment from `new`.
- `Ray` derives only `Clone`. `Debug` (and possibly `Copy`) would help.

### Priority

1. Fix the parallel-axis false positive (#1).
2. Handle zero or NaN directions (#2, #3).
3. Clarify or enforce `distance` semantics (#4).
4. Everything else is polish.