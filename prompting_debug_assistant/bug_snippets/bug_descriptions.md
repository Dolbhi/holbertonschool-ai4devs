## Bug 1 – bug1.py
**Intended Behavior**: Returns the given list with elements in reverse order.  
**Issue Type**: Off-by-one error.  
**Notes**: The function fails to include the first term of the input.  

## Bug 2 – bug2.rs
**Intended Behavior**: give_homes adds a new place for each person in the world.  
**Issue Type**: Lifetime error.  
**Notes**: world self is borrowed for iterating over people and can not be passed mutably to add_home function.

## Bug 3 – bug3.py
**Intended Behavior**: rotate rotates a 2D vector by the given angle in radians and returns the result
**Issue Type**: Logical error.  
**Notes**: Returns a float instead of a vector.