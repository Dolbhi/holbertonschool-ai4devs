## Bug 1 – bug1_fixed.py
**Test**: Pass a palindrome as assert that the accept message was printed
- **Input**: "racecar"
- **Expected Output**: print "Palindrome Verified ✅" in console
- **Actual Output**: print "Palindrome Verified ✅" in console
- **Result**: Pass

## Bug 2 – bug2_fixed.rs
**Test**: First check if the code compiles then create a world instance and call `give_home` and assert that a home was added for each person.
- **Input**: `World` instance with people = vec![1., -1.] and world = vec![].
- **Expected Output**: world.places = vec![(1., 0.), (0., 1.)]
- **Actual Output**: world.places = vec![(1., 0.), (0., 1.)]
- **Result**: Pass

## Bug 3 - bug3_fixed.py
**Test**: Pass a vector and a right angle and assert that the returned vector is a 90 degree rotated copy
- **Input**: vec = np.array([0, 1]), rads = np.pi/2
- **Expected Output**: [-1, 0]
- **Actual Output**: [-1.000000e+00  6.123234e-17]
- **Result**: Pass

## Bug 4 - bug4_fixed.m
**Test**: Pass a particle with a known scattering and extinction and assert the calculated scattering and extinction matches. Also assert that a progress bar appears and functions correctly during calculations.
- **Input**: p = truncated cube mesh, pol = [1, 0, 0]
- **Expected Output**: Tuple of wavelengths, scattering and extinction coefficients which when plotted shows a clear peak around 600 nm. A progress bar window appears during calculation and fills completely once calculation is complete.
- **Actual Output**: Tuple of wavelengths, scattering and extinction coefficients which when plotted shows a clear peak around 600 nm. A progress bar window appears during calculation and fills completely once calculation is complete.
- **Result**: Pass