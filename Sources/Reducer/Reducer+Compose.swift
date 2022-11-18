extension Reducer {
    /**
     Composes two or more reducers in series, to be evaluated from the left to the right for each incoming action.

     When composing reducer A with reducer B, when an action X arrives, first it will be forwarded to
     reducer A together with the initial state. This reducer may return a slightly (or completely) changed state from
     that operation, and this state will then be forwarded to reducer B together with the same action X. If you change
     the order, results may vary as you can imagine. Monoids don't necessarily hold the commutative axiom, although
     sometimes they do. What they necessarily hold is the associativity axiom, which means that if you compose A and B,
     and later C, it's exactly the same as if you compose A to a previously composed B and C:
     `.compose(.compose(A, B), C) == .compose(A, .compose(B, C))`. So please don't worry about surrounding your reducers with parenthesis:
     ```
     let globalReducer = .compose(firstReducer, secondReducer, thirdReducer, andSoOn)
     ```

     - Parameters:
       - first: First reducer `(ActionType, inout StateType) -> Void`, let's call it `f(x)`
       - others: Second, Third, nth reducers `(ActionType, inout StateType) -> Void`, let's call it `g(x)`
     - Returns: a composed reducer `(ActionType, inout StateType) -> Void` equivalent to `g(f(x))`
     */
    public static func compose(_ first: Reducer, _ others: Reducer...) -> Reducer {
        .reduce { action, state in
            first.reduce(action, &state)
            others.forEach { $0.reduce(action, &state) }
        }
    }
}
