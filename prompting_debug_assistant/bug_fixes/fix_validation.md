## Bug 1 – bug1_fixed.py
- **Input**: "correct"
- **Expected Output**:
c ❌ t
o ❌ c
r ❌ e
r ✅ r
e ❌ r
c ❌ o
t ❌ c
- **Actual Output**:
c ❌ t
o ❌ c
r ❌ e
r ✅ r
e ❌ r
c ❌ o
t ❌ c
✔

## Bug 2 – bug2_fixed.rs
- **Input**: `World` instance with people = vec![1., -1.] and world = vec![].
- **Expected Output**: world = vec![(1., 0.), (0., 1.)]
- **Actual Output**: world = vec![(1., 0.), (0., 1.)] ✔

## Bug 3 - bug3_fixed.py
- **Input**: vec = np.array([0, 1]), rads = np.pi/2
- **Expected Output**: [-1, 0]
- **Actual Output**: [-1.000000e+00  6.123234e-17] ✔

## Bug 4 - bug4_fixed.m
- **Input**: p = truncated cube mesh, pol = [1, 0, 0]
- **Expected Output**: Tuple of wavelengths, scattering and extinction coefficients which when plotted shows a clear peak around 600 nm. A progress bar window appears during calculation and fills completely once calculation is complete.
- **Actual Output**: Tuple of wavelengths, scattering and extinction coefficients which when plotted shows a clear peak around 600 nm. A progress bar window appears during calculation and fills completely once calculation is complete. ✔