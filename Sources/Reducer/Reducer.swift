/**
 An entity that calculates the new state when given current state and an incoming action `(Action, inout State) -> Void`.

 An app triggers several actions over time, either coming from user input (button tap, scroll, pinch gesture), from sensors (CoreLocation, NFC,
 HealthKit), communication protocols (CoreBluetooth, networking, WebSocket), databases (CoreData, Realm), timers and many more.
 An app also starts with an initial state, right after its cold launch.
 For each action that arrives, the state can be modified, and this is exactly what a `Reducer` does: folds all actions that arrived since the app
 launch, plus the initial state, into the current state. One at the time.
 The shape of a `Reducer` could be represented as `(Action, State) -> State`, or given the incoming action and the latest known state, calculate the
 new state.
 For the sake of performance, and keeping the same semantics, the SwiftRex `Reducer` is represented as `(Action, inout State) -> Void`, avoiding
 unnecessary copies and allowing performance tuning for arrays or other big collections.
 A `Reducer` can focus in a small part, and be composed with other reducers. The order of this composition matters, because the state will be modified
 in the order as the reducers were composed, but you should avoid two reducers changing the same domain. If you can't avoid, mind the order.
 A `Reducer` can also focus in a subset of your full AppAction and AppState, and be "lifted" from the subset to the whole, for example it's focused on
 LoginAction and LoginState, then lifted to the whole AppAction and AppState by providing the KeyPath where the subset LoginAction is in the
 AppAction, and where the subset LoginState is in the AppState.
 */
public struct Reducer<ActionType, StateType> {
    /**
     Execute the wrapped reduce function. You must provide the parameters `action: ActionType` (the action to be
     evaluated during the reducing process) and an `inout` version of the latest `state: StateType`, (the current
     state in your single source-of-truth).
     State will be mutated in place (`inout`) and finish with the calculated new state.
     */
    public let reduce: (ActionType, inout StateType) -> Void

    /**
     Reducer initialiser takes only the underlying function `(ActionType, inout StateType) -> Void` that is the reducer
     function itself.
     - Parameters:
       - reduce: a pure function that calculates the new state from an action and the current state.
     */
    public static func reduce(_ reduce: @escaping (ActionType, inout StateType) -> Void) -> Reducer {
        Reducer(reduce: reduce)
    }

    init(reduce: @escaping (ActionType, inout StateType) -> Void) {
        self.reduce = reduce
    }
}
