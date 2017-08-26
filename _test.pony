use "ponytest"

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_TestPQCreate)
    test(_TestPQRemove)

class Util
  let cmp: {(USize,USize):Compare} val = 
    {(l:USize,r:USize):Compare =>
      if l < r then Less
      elseif r < l then Greater
      else Equal
      end}

class iso _TestPQCreate is UnitTest
  fun name(): String => "PQ creation"
  fun apply(h: TestHelper) =>
    let pq: PriorityQueue[USize] = PriorityQueue[USize](Util.cmp)
    h.assert_true(pq.is_heap())
    pq.insert(4)
    h.assert_true(pq.is_heap())
    pq.insert(5)
    h.assert_true(pq.is_heap())
    pq.insert(3)
    h.assert_true(pq.is_heap())
    pq.insert(4)
    h.assert_true(pq.is_heap())

class iso _TestPQRemove is UnitTest
  fun name(): String => "PQ remove"
  fun apply(h: TestHelper) ? =>
    let pq: PriorityQueue[USize] = PriorityQueue[USize](Util.cmp)
    pq.insert(4)
    pq.insert(5)
    pq.insert(3)
    pq.insert(4)
    h.assert_true(pq.is_heap())
    h.assert_eq[USize](pq.remove()?, 5)
    h.assert_eq[USize](pq.remove()?, 4)
    h.assert_eq[USize](pq.remove()?, 4)
    h.assert_eq[USize](pq.remove()?, 3)
    h.assert_eq[USize](pq.size(), 0)

