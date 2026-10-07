## Bug 1 – bug1.py
**Intended Behavior**: Given a string checks if it is a palindrome, if not print all letters and whether they match their corresponding reversed letter.  
**Issue Type**: Off-by-one error.  
**Notes**: The function fails to include the last term of the input when listing matches.  

## Bug 2 – bug2.rs
**Intended Behavior**: The function `give_homes` adds a new place for each person in the world.  
**Issue Type**: Lifetime error.  
**Notes**: world self is borrowed for iterating over people and can not be passed mutably to add_home function.

## Bug 3 – bug3.py
**Intended Behavior**: The function should rotate a given 2D vector by the given angle in radians and returns the result
**Issue Type**: Logical error.  
**Notes**: Only returns the first component of the resulting vector.

## Bug 4 – bug4.m
**Intended Behavior**: Given a particle and polarisation direction, returns 3 arrays containing the excitation wavelengths, and calculated scattering and extinction cross-section. During scattering and extinction calculation a progress bar should show the remaining wavelengths left to calculate.
**Issue Type**: Runtime exception.
**Notes**: After completing several calculations an exception is thrown at line 45 involving the multiWaitBar.