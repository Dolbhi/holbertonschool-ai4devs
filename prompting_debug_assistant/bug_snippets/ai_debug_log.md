## Bug 1 – bug1.py
**AI Diagnosis**: The slice `word[-1:0:-1]` stops before index 0, so reverse is missing the first character
**Suggested Fix**: Change to `word[::-1]`.
**Alternative Fixes Tested**: None.
**Result**: Fix works as expected.

## Bug 2 – bug2.rs
**AI Diagnosis**: Missing comma after `places: Vec<(f32, f32)>` in the struct. `for person in self.people` tries to move the Vec out of `&mut self`. Even if you iterated by reference (`&self.people`), calling `self.add_home(...)` inside the loop would fail because it needs a mutable borrow of all of `self` while `self.people` is still borrowed.
**Suggested Fix**: Add missing comma and loop with index (`for i in 0..self.people.len()`).
**Alternative Fixes Tested**: None.
**Result**: Fix works as expected.

## Bug 3 – bug3.py
**AI Diagnosis**: `np.array` takes the data as its first argument and the `dtype` as its second. Here you've passed two separate tuples, so NumPy tries to interpret (s, c) as a data type and raises a `TypeError` (something like "Cannot interpret ... as a data type").
**Suggested Fix**: Change to `r = np.array(((c, -s), (s, c)))`.
**Alternative Fixes Tested**: None.
**Result**: Fix works as expected.

## Bug 4 – bug4.m
**AI Diagnosis**: `multiWaitbar` is a GUI call that keeps its state in a figure on the client. Workers have no display and can't update the client's waitbar. Depending on the worker, you get errors about figures, graphics handles, or persistent state.
**Suggested Fix**: Progress reporting from a parfor has to go through a `parallel.pool.DataQueue` that sends updates back to the client
**Alternative Fixes Tested**: None.
**Result**: Fix works as expected.