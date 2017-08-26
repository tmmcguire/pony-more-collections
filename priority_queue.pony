type CompareFn[A] is {(box->A!,box->A!): Compare} val

class PriorityQueue[A: Any #read]
  """
  A priority queue implemented as a binary heap in an array. See
  http://algs4.cs.princeton.edu/24pq/.

  Greater elements (from the comparison function) will be available
  first from the queue.

  Example usage:

  ```pony
  // comparison function: higher is earlier
  let cmp: {(USize,USize):Compare} val = 
    {(l:USize,r:USize):Compare =>
      if l < r then Less
      elseif r < l then Greater
      else Equal end}

  // create a queue, using cmp as the comparison function
  let pq: PriorityQueue[USize] = PriorityQueue[USize](cmp)

  // insert some values
  pq.insert(4)
  pq.insert(5)
  pq.insert(3)
  pq.insert(5)

  // examine the highest-priority element, 5
  pq()

  // remove the highest priority element
  pq.remove()
  ```
  """

  // In the binary heap, the left child of index i is located at index 2i +
  // 1; the right child is at index 2i + 2. The parent is therefore at (i - 1)/2.

  let _array: Array[A]
  let _cmp: CompareFn[A]

  new create(cmp: CompareFn[A], initial: USize = 0) =>
    """
    Create a priority queue using cmp as the comparison function, with
    enough space for initial elements.

    Greater elements (from the comparison function) will be available
    first from the queue.
    """
    _array = Array[A](initial)
    _cmp = cmp

  fun size(): USize =>
    """
    Returns the number of elements in the queue.
    """
    _array.size()

  fun space(): USize =>
    """
    Returns the number of positions in the queue, including those in use.
    """
    _array.space()

  fun ref reserve(len: USize) =>
    """
    Reserve space for len elements, including whatever elements are
    already in the queue. Space grows geometrically.
    """
    _array.reserve(len)

  fun ref compact() =>
    """
    Try to remove unused space, making it available for garbage collection. The
    request may be ignored.
    """
    _array.compact()

  fun apply(): this->A ? =>
    """
    Get the first element of the queue.

    Throws if the queue is empty.
    """
    _array.apply(0)?

  fun ref insert(a: A) =>
    """
    Insert element a into the queue.
    """
    try
      _array.push(a)
      _swim(_array.size() - 1)?
    end

  fun ref remove(): A^ ? =>
    """
    Remove and return the first element of the queue.

    Throws if the queue is empty.
    """
    let last = _array.size() - 1
    _array(0)? = _array(last)? = _array(0)?
    let value = _array.delete(last)?
    if _array.size() > 0 then _sink(0)? end
    consume value
    
  fun is_heap(k: USize = 0): Bool =>
    """
    Return true if the queue satisfies the heap property: each element
    is guaranteed to be equal to or larger than the elements at two
    child positions.
    """
    let n = size()
    if k > n then return true end
    let lft = _left(k)
    let rht = _right(k)
    try
      if (lft < n) and (_compare(k, lft)? == Less) then
        return false
      elseif (rht < n) and (_compare(k, rht)? == Less) then
        return false
      else
        is_heap(lft) and is_heap(rht)
      end
    else
      false
    end

  fun ref _swim(k: USize) ? =>
    // Bottom-up reheapify (swim). If the heap order is violated because
    // a node's key becomes larger than that node's parents key, then we
    // can make progress toward fixing the violation by exchanging the
    // node with its parent. After the exchange, the node is larger than
    // both its children (one is the old parent, and the other is smaller
    // than the old parent because it was a child of that node) but the
    // node may still be larger than its parent. We can fix that violation
    // in the same way, and so forth, moving up the heap until we reach a
    // node with a larger key, or the root.
    //
    // Throws if k is out of range.
    var k' = k
    while (k' > 0) do
      let par = _parent(k)
      match _compare(par, k')?
      | Less => _array(par)? = _array(k')? = _array(par)?
                k' = par
      else
        break
      end
    end

  fun ref _sink(k: USize) ? =>
    // Top-down heapify (sink). If the heap order is violated because
    // a node's key becomes smaller than one or both of that node's
    // children's keys, then we can make progress toward fixing the
    // violation by exchanging the node with the larger of its two
    // children. This switch may cause a violation at the child; we fix
    // that violation in the same way, and so forth, moving down the
    // heap until we reach a node with both children smaller, or the
    // bottom.
    //
    // Throws if k is out of range.
    var k' = k
    let n = size()
    while _left(k') < n do
      var chld = _left(k')
      if (chld < (n - 1))
          and (_compare(chld, chld + 1)? == Less) then
        chld = chld + 1
      end
      match _compare(k', chld)?
      | Less => _array(k')? = _array(chld)? = _array(k')?
                k' = chld
      else
        break
      end
    end

  // Useful utilities.

  fun _compare(lft: USize, rht: USize): Compare ? =>
    _cmp(_array(lft)?, _array(rht)?)

  fun _parent(k: USize): USize => (k - 1) / 2
  fun _left(k: USize): USize => (2 * k) + 1
  fun _right(k: USize): USize => (2 * k) + 2
