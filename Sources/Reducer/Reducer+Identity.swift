extension Reducer {
    /**
     No-op reducer. Composing it with any other reducer will not change anything from the other reducer behaviour, regardless if the identity reducer
     is on the left-hand side or the right-hand side or this composition. This is the neutral element in a monoidal composition.

     Therefore:
     ```
        .compose( Reducer<ActionType, StateType>, .identity )
     == .compose( .identity, Reducer<ActionType, StateType> )
     == Reducer<ActionType, StateType>
     ```

     This is useful for composition purposes, for example when you call a function `Array.reduce` in an array of Reducers and you need a no-op start:
     ```
     [reducer1, reducer2].reduce(.identity) { accumulator, nextReducer in
        Reducer.compose(accumulator, nextReducer)
     }
     // .identity won't have any behaviour and the final composition ".identity >>> reducer1, reducer2" will be as if .identity wasn't there.
     ```

     The implementation of this reducer, as one should expect, simply ignores the action and returns the state unchanged
     */
    public static var identity: Reducer<ActionType, StateType> {
        .init { _, _ in }
    }
}
