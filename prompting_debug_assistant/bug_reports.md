## Bug Report – bug1.py
- **Summary**: Off-by-one error in slicing.
- **Root Cause**: The slice `word[-1:0:-1]` stops before index 0, so reverse is missing the first character.
- **Resolution**: Change to `word[::-1]`.
- **Lesson Learned**: Take care with slicing and test functions properly.

## Bug Report – bug2.rs
- **Summary**: Invalid move preventing compilation.
- **Root Cause**: `for person in self.people` tries to move the Vec out of `&mut self`.
- **Resolution**: Change to loop with index (`for i in 0..self.people.len()`).
- **Lesson Learned**: Keep track of ownership when doing iteration.

## Bug Report – bug3.py
- **Summary**: Wrong function parameters.
- **Root Cause**: Matrixed passed as 2 separate tuples to `np.array` instead of a single tuple of tuples.
- **Resolution**: Change to `r = np.array(((c, -s), (s, c)))`.
- **Lesson Learned**: Read documentation on function signature properly before use.

## Bug Report – bug4.m
- **Summary**: Multithreading error.
- **Root Cause**: `multiWaitbar` is a GUI call that keeps its state in a figure on the client. Thread workers can't update the client's waitbar.
- **Resolution**: Progress reporting from a parfor has to go through a `parallel.pool.DataQueue` that sends updates back to the client
- **Lesson Learned**: Keep track of global states and where they are stored when using multithreading.