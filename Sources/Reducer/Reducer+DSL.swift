import Foundation

/**
 DSL Builder for Reducer compose
 */
@resultBuilder public struct ReducerBuilder {
    /**
     DSL Builder for Reducer compose
     - Parameter rs: the reducers to be combined/
     - Returns: the composed reducer that will run all the inner reducers sequentially/
     */
    public static func buildBlock<Action, State>(_ rs: Reducer<Action, State>...) -> Reducer<Action, State> {
        .reduce { action, state in
            rs.forEach { $0.reduce(action, &state) }
        }
    }
}

extension Reducer {
    /**
     Composes two or more reducers in series, to be evaluated from the top to the bottom for each incoming action.

     When composing reducer A with reducer B, when an action X arrives, first it will be forwarded to
     reducer A together with the initial state. This reducer may return a slightly (or completely) changed state from
     that operation, and this state will then be forwarded to reducer B together with the same action X. If you change
     the order, results may vary as you can imagine. Monoids don't necessarily hold the commutative axiom, although
     sometimes they do.

     For example you can compose reducers like this:
     ```
     Reducer.compose {
         Reducer
            .login
            .lift(action: \.loginAction, state: \.loginState)

         Reducer
            .lifecycle
            .lift(action: \.lifecycleAction, state: \.lifecycleState)

         Reducer.app

         Reducer.reduce { action, state in
             // some inline reducer
         }
     }
     ```

     - Parameter content: a result builder (DSL) having zero or more reducers to be composed sequentially
     - Returns: a composed reducer `(ActionType, inout StateType) -> Void` equivalent to running all the internal
                reducers in series
     */
    public static func compose(@ReducerBuilder content: () -> Reducer) -> Reducer {
        content()
    }
}
