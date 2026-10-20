# Code Review: Rust Raycasting Against Cuboids

Overall assessment: The code implements the standard slab-based ray–axis-aligned bounding box (AABB) intersection algorithm, but it has several potential correctness issues involving parallel rays, zero-length directions, transformed ray distances, and finite ray ranges.

The most significant concern is that the implementation assumes the ray's direction and distance remain consistent after transformations. That assumption does not hold for arbitrary model matrices, particularly when non-uniform scaling is involved.

## 1. Summary of findings

|Severity|Location|Issue|
|---|---|---|
|Critical|`box_intersection_raw`|Rays parallel to an axis can produce incorrect results when the origin lies outside the box on that axis.|
|High|`transform_model`|Transforming the direction without renormalising it changes the meaning of the intersection distance.|
|High|`box_intersection_raw`|A ray with zero direction components on all axes can return an infinite interval and be treated as an intersection.|
|High|`new` and `from_points`|Zero-length directions can produce NaN values or division by zero.|
|High|`box_intersection`|Negative or NaN distances are not validated, and the maximum-distance check is incomplete.|
|Medium|`advance`|Advancing beyond the remaining ray distance makes `distance` negative without preventing further use.|
|Medium|`transform_model`|The homogeneous coordinate is discarded without dividing by `w`, which is only safe under appropriate transformation assumptions.|
|Medium|`box_intersection_raw`|NaN values and malformed bounds can invalidate the intersection calculations.|

The severity ratings assume the code is used in a general-purpose raycasting system. Some issues may be acceptable if the caller guarantees valid inputs and uses only rigid transformations.

## 2. Detailed analysis

### Issue 1: Parallel rays can incorrectly intersect a box

Location: `box_intersection_raw`

```
if self.direction[i].is_zero() {
    continue;
}
```

The implementation skips an axis whenever the direction component is zero. However, a ray parallel to an axis must still be checked against the box's bounds on that axis.

Consider a box with bounds `(-1, -1, -1)` to `(1, 1, 1)` and a ray with:

- Origin: `(2, 0, 0)`
    
- Direction: `(0, 1, 0)`
    

The ray travels parallel to the Y-axis, but its X-coordinate is always `2`, outside the box.

The implementation skips the X-axis because the X direction is zero. It then computes the intersection interval using only the Y-axis, potentially reporting an intersection even though the ray can never enter the box.

Why this happens: Skipping the axis omits an essential constraint. A zero direction component means the ray never changes its coordinate on that axis, not that the axis is irrelevant.

Recommended fix: When a direction component is zero, return no intersection if the origin coordinate lies outside the corresponding bounds.

```
if self.direction[i] == 0.0 {
    if self.origin[i] < bounds.min[i]
        || self.origin[i] > bounds.max[i]
    {
        return (f32::INFINITY, f32::NEG_INFINITY);
    }

    continue;
}
```

The sentinel interval above represents an empty intersection. A cleaner design would return `Option<(f32, f32)>` from the raw intersection routine, allowing the function to report a miss explicitly.

For floating-point robustness, consider whether near-zero components should be treated as parallel. An arbitrary epsilon should be selected carefully, since treating a small but nonzero direction as zero changes the geometric result.

### Issue 2: Transforming a ray breaks its distance parameterisation

Location: `transform_model`

```
self.origin = (model * self.origin.extend(1.)).truncate();
self.direction = matrix_truncate(model) * self.direction;
```

The method transforms the origin and direction but does not normalise the transformed direction.

The documentation acknowledges that the resulting ray is not normalised, but other methods rely on a distance interpretation that can be ambiguous once the direction is no longer unit length.

For a ray parameterised as

\[ P(t) = O + tD \]

the parameter \(t\) represents physical distance only when \(D\) has unit length.

For example, if the original direction is `(1, 0, 0)` and a model transformation scales X by `2`, the transformed direction becomes `(2, 0, 0)`. An intersection at the transformed-space coordinate X = 4 is reached at parameter \(t = 2\), not at physical distance 4 in that space.

There is an important nuance: not normalising the transformed direction is often the correct choice when transforming a ray into an object's local coordinate system. It preserves the original ray parameter under an affine inverse transformation, provided the origin, direction, and parameter are handled consistently.

The problem is that the rest of this implementation does not make that contract explicit.

In particular:

- `calc_point` treats the argument as the ray parameter.
- `advance` moves by `distance * direction`.
- `box_intersection` compares the parameter against `self.distance`.
- `cuboid_intersection` transforms a clone but retains the original distance limit.

These operations are consistent only if `distance` is defined in the same parameter space as the direction.

Recommended fix: Choose and document one of two contracts:

1. World-distance contract: Keep directions normalised and convert intersection distances appropriately when transforming between spaces.
    
2. Ray-parameter contract: Allow unnormalised directions after transformation and ensure `distance` always represents the maximum parameter \(t\), not an arbitrary physical distance.
    

For local-space intersection testing, the second approach is often preferable because it avoids incorrect distance comparisons under non-uniform scaling. Ensure the initial ray is normalised if its parameter is intended to represent world-space distance.

### Issue 3: A zero direction vector can be reported as a hit

Location: `box_intersection_raw` and `box_intersection`

```
let mut closest = f32::NEG_INFINITY;
let mut furthest = f32::INFINITY;
```

If all three direction components are zero, the loop skips every axis. The returned interval is therefore:

```
(f32::NEG_INFINITY, f32::INFINITY)
```

The subsequent logic in `box_intersection` can interpret this interval as an intersection and return `Some(0.0)`, even though the ray does not travel anywhere.

This can happen with an invalid ray created by `new` or with a zero-length segment.

Recommended fix: Reject zero-length directions before intersection testing. This should be done when constructing the ray and, ideally, validated at the intersection boundary as well.

The intersection routine should also distinguish between a valid stationary point query and a ray. If stationary point queries are needed, implement them as a separate operation.

### Issue 4: Zero-length directions cause NaN values

Locations: `new` and `from_points`

In `new`:

```
direction: direction.normalize(),
```

In `from_points`:

```
let distance = direction.magnitude();

Self {
    origin: start,
    direction: direction / distance,
    distance,
}
```

Both methods can receive a zero-length direction.

For `from_points`, if `start == end`, then:

\[ \text{distance} = 0 \]

The code subsequently divides the zero vector by zero. This can produce NaN components.

Similarly, normalising a zero vector in `new` is not a safe way to construct a valid ray.

NaN values are particularly troublesome in the slab algorithm because comparisons involving NaN are false. The algorithm can consequently return a miss or produce an invalid interval, depending on the inputs and execution path.

Recommended fix: Validate inputs and make invalid construction explicit. One option is to return `Option<Self>` or `Result<Self, RayError>` from constructors.

```
pub fn from_points(start: Vector, end: Vector) -> Option<Self> {
    let direction = end - start;
    let distance = direction.magnitude();

    if !distance.is_finite() || distance <= 0.0 {
        return None;
    }

    Some(Self {
        origin: start,
        direction: direction / distance,
        distance,
    })
}
```

Apply equivalent validation in `new`. If the application permits infinite ray lengths, distinguish that intentional case from NaN values and invalid directions.

### Issue 5: The maximum-distance check is incomplete

Location: `box_intersection`

```
if close <= far && close <= self.distance {
    if close < 0. {
        if far < 0. {
            None
        } else {
            Some(0.)
        }
    } else {
        Some(close)
    }
}
```

The method checks whether the entry parameter is less than or equal to the maximum distance. However, it does not validate the maximum distance itself or ensure that the returned entry point is within a valid ray interval.

For example, consider a ray starting inside the box with `distance = -1.0`. Since the entry parameter is negative, the function can return `Some(0.0)` even though the ray has a negative maximum distance.

A negative maximum distance is usually invalid for a forward ray segment.

There is also an API ambiguity: should a ray starting inside the box count as an intersection at distance zero, or should the method return the exit distance? The current implementation explicitly chooses zero. That is appropriate for some collision queries, but not for all raycasting applications.

Recommended fix: Define the accepted parameter interval explicitly. For a forward ray segment, this is normally

\[ 0 \leq t \leq \text{distance} \]

with a special policy for rays whose origin is already inside the box.

At minimum, reject negative or NaN maximum distances. If `distance` is allowed to be infinite, accept positive infinity intentionally.

### Issue 6: `advance` can invalidate the ray's range

Location: `advance`

```
pub fn advance(&mut self, distance: f32) {
    self.origin += self.direction * distance;
    self.distance -= distance;
}
```

The method assumes that the supplied distance is valid. It does not prevent:

- Advancing farther than the remaining range.
- Advancing by a negative value, which moves the origin backwards and increases the remaining range.
- Passing NaN or infinite values.
- Passing a physical distance when `direction` is not normalised.

For example, if the ray has `distance = 5.0` and `advance(8.0)` is called, its remaining distance becomes `-3.0`.

Recommended fix: Define whether advancing beyond the remaining range is permitted. If not, reject the operation or clamp the requested advancement. Validate the argument and ensure the direction and advancement units agree.

A checked API could return `Result<(), RayError>` when the advancement is invalid, rather than silently creating an inconsistent ray.

### Issue 7: Homogeneous coordinates are discarded without perspective division

Location: `transform_model`

```
self.origin = (model * self.origin.extend(1.)).truncate();
```

Extending the origin with `1.0` and then truncating the transformed vector assumes the transformation is affine, so that the resulting homogeneous coordinate remains `1.0`.

This is normally valid for translation, rotation, scaling, and shear matrices. It is not generally valid for projective transformations, where the resulting homogeneous coordinate may differ from one.

For a projective matrix, the transformed point generally needs to be divided by its resulting `w` coordinate. However, transforming a ray through a projective transformation is more involved than merely dividing the origin: the ray's parameterisation and direction must also be handled correctly.

Recommended fix: If the method is intended for object model matrices, explicitly require an affine transformation and validate that assumption where practical. If projective transformations are required, implement the appropriate point and ray transformation mathematics rather than simply truncating the result.

### Issue 8: Non-finite values and malformed bounds are not handled

Locations: `new`, `from_points`, and `box_intersection_raw`

The code assumes that all ray components and bounding-box bounds are valid finite values, except that positive infinity may be intentional for the ray range.

However, it does not reject NaN components, infinite coordinates, or bounds where a minimum exceeds the corresponding maximum.

For example, a bounding box with `min.x > max.x` is malformed. The intersection algorithm does not validate it and may return unexpected results.

The same problem applies to NaN components in the origin or direction, which can silently invalidate comparisons.

Recommended fix: Validate bounds when constructing `BoundingBox`, and validate ray inputs when constructing `Ray`. Reject NaN values explicitly. Allow infinities only where they are part of the intended API contract.

## 3. Additional considerations

### Issue 9: Exact zero checks may be numerically fragile

Location: `box_intersection_raw`

```
if self.direction[i].is_zero() {
```

The check detects an exactly zero component. A direction component that is extremely small but nonzero will instead be used in the division:

```
let low = (bounds.min[i] - self.origin[i]) / self.direction[i];
```

This can produce extremely large intersection parameters or overflow to infinity.

This is not necessarily a bug: a very small nonzero component still represents a valid direction. However, it may cause numerical instability in some applications.

Recommended fix: Keep exact-zero handling for mathematically correct slab intersection, unless your application's precision requirements justify treating small components as parallel. If using a tolerance, document it and consider the scale of the scene. An arbitrary epsilon can incorrectly discard legitimate intersections.

### Issue 10: The transformed ray's maximum range needs a clear contract

Location: `cuboid_intersection`

```
let mut cub_space_ray = self.clone();
cub_space_ray.transform_model(inv_cuboid_model);
cub_space_ray.box_intersection(
    &BoundingBox::new((-1., -1., -1.), (1., 1., 1.))
)
```

This method transforms the ray into cuboid-local coordinates and checks it against a unit cube. The approach is sound for an appropriately defined inverse affine transformation, but the meaning of the returned distance deserves special attention.

If the direction remains unnormalised after transformation, the returned value is a ray parameter, not necessarily the Euclidean distance between the original ray origin and the hit point in local coordinates.

For an affine inverse transformation, retaining the unnormalised direction can preserve the original ray parameter. Consequently, do not automatically normalise the transformed direction: doing so without adjusting the range can introduce a different bug.

Recommended fix: Document whether `cuboid_intersection` returns a world-distance value or a ray parameter. If the input ray is normalised and the inverse transformation is affine, preserving the transformed direction's magnitude allows the intersection parameter to remain comparable to the original ray's distance limit.

This assumes that the input ray's direction was initially normalised and that `distance` represents the corresponding ray parameter.

## 4. Recommended corrected intersection algorithm

The most important correction is to handle parallel axes properly and reject invalid direction vectors. The following implementation shows a safer approach while preserving the existing API's convention of returning the entry parameter, or zero when the ray starts inside the box.

```
pub fn box_intersection_raw(
    &self,
    bounds: &BoundingBox,
) -> Option<(f32, f32)> {
    let mut closest = f32::NEG_INFINITY;
    let mut furthest = f32::INFINITY;

    for i in 0..3 {
        let origin = self.origin[i];
        let direction = self.direction[i];
        let min = bounds.min[i];
        let max = bounds.max[i];

        // Reject invalid values and malformed bounds.
        if !origin.is_finite()
            || !direction.is_finite()
            || !min.is_finite()
            || !max.is_finite()
            || min > max
        {
            return None;
        }

        // A stationary ray is not a valid ray.
        if direction == 0.0 {
            if origin < min || origin > max {
                return None;
            }

            // This axis imposes no further constraint.
            continue;
        }

        let t1 = (min - origin) / direction;
        let t2 = (max - origin) / direction;

        closest = closest.max(t1.min(t2));
        furthest = furthest.min(t1.max(t2));

        // The intervals no longer overlap.
        if closest > furthest {
            return None;
        }
    }

    // Reject a direction that is zero on all axes.
    if self.direction.magnitude2() == 0.0 {
        return None;
    }

    Some((closest, furthest))
}
```

This is an illustrative improvement, not a complete drop-in replacement for every existing caller. It rejects infinite box bounds, for example, which may or may not suit your application. It also changes the raw method's return type from `(f32, f32)` to `Option<(f32, f32)>`, so callers must be updated.

The public intersection method would then apply the forward-ray and maximum-range rules explicitly:

```
pub fn box_intersection(
    &self,
    bounds: &BoundingBox,
) -> Option<f32> {
    if !self.distance.is_finite()
        || self.distance < 0.0
        || !self.origin.x.is_finite()
        || !self.origin.y.is_finite()
        || !self.origin.z.is_finite()
    {
        return None;
    }

    let (close, far) = self.box_intersection_raw(bounds)?;

    if far < 0.0 || close > self.distance {
        return None;
    }

    Some(close.max(0.0))
}
```

This version deliberately rejects an infinite ray range; remove that restriction if positive infinity is a supported use case. It also assumes the ray direction is valid and finite, as checked by the raw routine.

## 5. Suggested testing strategy

The following test cases would help establish correctness and prevent regressions.

|Test case|Expected result|
|---|---|
|Ray passes through the centre of the box|Hit at the expected entry parameter|
|Ray misses the box entirely|`None`|
|Ray is parallel to an axis and outside that axis's bounds|`None`|
|Ray is parallel to an axis and inside its bounds|Intersection determined by the other axes|
|Ray starts inside the box|`Some(0.0)` under the current API contract|
|Ray points away from the box|`None`|
|Ray reaches the box exactly at its maximum range|Hit at the maximum range|
|Ray's maximum range ends before the box|`None`|
|Ray has a zero-length direction|Rejected|
|Ray contains NaN or infinite coordinates|Rejected according to the chosen input policy|
|Box has reversed bounds|Rejected|
|Ray intersects a non-uniformly scaled cuboid|Correct hit parameter, consistent with the documented distance contract|
|Ray advances beyond its remaining range|Rejected or handled according to the API contract|

## Final recommendation

I would prioritise the fixes in this order:

1. Fix parallel-axis handling. This is a direct geometric correctness bug that can produce false-positive intersections.
    
2. Reject invalid and zero-length directions. Otherwise, NaN values and stationary rays can produce unreliable results.
    
3. Clarify the ray parameterisation. Define how `direction`, `distance`, `transform_model`, `calc_point`, and `advance` interact.
    
4. Validate the finite ray range. Make sure intersection results respect the valid forward interval.
    
5. Validate transformation and bounding-box assumptions. Document affine-only transformations and enforce valid bounds.
    

The slab algorithm itself is a suitable choice for cuboid raycasting. The primary issues arise from edge-case handling and the relationship between coordinate transformations and distance semantics, rather than from the overall algorithm.