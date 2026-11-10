## Task 1 - CRUD Endpoint
**Requirements**: Implement POST /users with validation.  
**Inputs**: JSON {name, email}  
**Outputs**: Stored user with ID  
**Acceptance Criteria**:
- Returns 201 on success  
- Returns 400 on invalid email

## Task 2 - Raycasting
**Requirements**: Perform raycasting on a given cuboid (in rust)
**Inputs**: ray (direction, distance, start point), 4x4 matrix (transformation given to a unit cube to get the target cuboid)
**Outputs**: collision point (if any)
**Acceptance Criteria**:
- Correctly returns ray entry point on cuboid
- Returns `None` if ray does not interscet
- Correctly detects no interscetion if ray does not reach the cuboid within the given distance
- Returns the starting point if it is inside the cuboid

## Task 2 - Doubly linked list loop
**Requirements**: Implement a doubly linked list in rust containing generic elements
**Associated Functions**: List creation, item insertion before index, item removal at index, mutable and immutable item borrows at index
**Acceptance Criteria**:
- Given a immutable borrow of a list item, the next and previous item in the list can be borrowed immutably
- No infinite function call stack when dropping list
- The previous item of the first item is the last item and the next item of the last item is the first, forming a loop