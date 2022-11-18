extension Reducer {
    /**
     A type-lifting method. The global state of your app is _Whole_, and the `Reducer` handles _Part_, that is a
     sub-state.

     Let's suppose you may want to have a `gpsReducer` that knows about the following `struct`:
     ```
     struct Location {
         let latitude: Double
         let longitude: Double
     }
     ```

     Let's call it _Part_. Both, this state and its reducer will be part of an external framework, used by dozens of
     apps. Internally probably the `Reducer` will receive some known `ActionType` and calculate a new location. On the
     main app we have a global state, that we now call _Whole_.

     ```
     struct MyGlobalState {
         let title: String?
         let listOfItems: [Item]
         let currentLocation: Location
     }
     ```

     As expected, _Part_ (`Location`) is a property of _Whole_ (`MyGlobalState`). This relationship could be less
     direct, for example there could be several levels of properties until you find the _Part_ in the _Whole_, like
     `global.firstLevel.secondLevel.currentLocation`, but let's keep it a single-level for this example.

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `lift` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.lift(
         action: \.self,
         state: \.currentLocation
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                             ↑ lift
     //           gpsReducer: Reducer<MyAction, Location>
     ```

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     Same strategy works for the `action`, as you can guess by the `action` KeyPath parameter. You can provide a KeyPath
     that takes a global action (_Whole_) and returns an optional local action (_Part_). It's optional because perhaps
     you want to ignore actions that are not relevant for this reducer.

     - Parameters:
       - action: a read-only key-path from global action into a local action, but it's optional because maybe this
                 reducer shouldn't care about certain actions. Because actions are usually enums, you can switch over
                 the enum and in case it's nothing you care about, you simply return nil in the closure. If you don't
                 want to lift this reducer in terms of `action`, just remove this parameter from the call.
       - state: a writable key-path from global state that traverses into a local state, by extracting only the part
                that it's relevant for this reducer. This will also be used to set the new local state into the global
                state once the reducer finishes it's operation. For example: `\.currentGame.scoreBoard`.
     - Returns: a `Reducer<GlobalAction, GlobalState>` that maps actions and states from the original specialised
                reducer into a more generic and global reducer, to be used in a larger context.
     */
    public func lift<GlobalActionType, GlobalStateType>(
        action: KeyPath<GlobalActionType, ActionType?>,
        state: WritableKeyPath<GlobalStateType, StateType>)
    -> Reducer<GlobalActionType, GlobalStateType> {
        .reduce { globalAction, globalState in
            guard let localAction = globalAction[keyPath: action] else { return }
            self.reduce(localAction, &globalState[keyPath: state])
        }
    }

    /**
     A type-lifting method. The global state of your app is _Whole_, and the `Reducer` handles _Part_, that is a
     sub-state.

     Let's suppose you may want to have a `gpsReducer` that knows about the following `struct`:
     ```
     struct Location {
         let latitude: Double
         let longitude: Double
     }
     ```

     Let's call it _Part_. Both, this state and its reducer will be part of an external framework, used by dozens of
     apps. Internally probably the `Reducer` will receive some known `ActionType` and calculate a new location. On the
     main app we have a global state, that we now call _Whole_.

     ```
     struct MyGlobalState {
         let title: String?
         let listOfItems: [Item]
         let currentLocation: Location
     }
     ```

     As expected, _Part_ (`Location`) is a property of _Whole_ (`MyGlobalState`). This relationship could be less
     direct, for example there could be several levels of properties until you find the _Part_ in the _Whole_, like
     `global.firstLevel.secondLevel.currentLocation`, but let's keep it a single-level for this example.

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `lift` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.lift(
         action: \.self,
         state: \.currentLocation
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                             ↑ lift
     //           gpsReducer: Reducer<MyAction, Location>
     ```

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     Same strategy works for the `action`, as you can guess by the `action` KeyPath parameter. You can provide a KeyPath
     that takes a global action (_Whole_) and returns an optional local action (_Part_). It's optional because perhaps
     you want to ignore actions that are not relevant for this reducer.

     - Parameters:
       - state: a writable key-path from global state that traverses into a local state, by extracting only the part
                that it's relevant for this reducer. This will also be used to set the new local state into the global
                state once the reducer finishes it's operation. For example: `\.currentGame.scoreBoard`.
     - Returns: a `Reducer<ActionType, GlobalState>` that maps actions and states from the original specialized
                reducer into a more generic and global reducer, to be used in a larger context.
     */
    public func lift<GlobalStateType>(
        state: WritableKeyPath<GlobalStateType, StateType>
    ) -> Reducer<ActionType, GlobalStateType> {
        .reduce { action, globalState in
            self.reduce(action, &globalState[keyPath: state])
        }
    }

    /**
     A type-lifting method. The global state of your app is _Whole_, and the `Reducer` handles _Part_, that is a
     sub-state.

     Let's suppose you may want to have a `gpsReducer` that knows about the following `struct`:
     ```
     struct Location {
         let latitude: Double
         let longitude: Double
     }
     ```

     Let's call it _Part_. Both, this state and its reducer will be part of an external framework, used by dozens of
     apps. Internally probably the `Reducer` will receive some known `ActionType` and calculate a new location. On the
     main app we have a global state, that we now call _Whole_.

     ```
     struct MyGlobalState {
         let title: String?
         let listOfItems: [Item]
         let currentLocation: Location
     }
     ```

     As expected, _Part_ (`Location`) is a property of _Whole_ (`MyGlobalState`). This relationship could be less
     direct, for example there could be several levels of properties until you find the _Part_ in the _Whole_, like
     `global.firstLevel.secondLevel.currentLocation`, but let's keep it a single-level for this example.

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `lift` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.lift(
         action: \.self,
         state: \.currentLocation
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                             ↑ lift
     //           gpsReducer: Reducer<MyAction, Location>
     ```

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     Same strategy works for the `action`, as you can guess by the `action` KeyPath parameter. You can provide a KeyPath
     that takes a global action (_Whole_) and returns an optional local action (_Part_). It's optional because perhaps
     you want to ignore actions that are not relevant for this reducer.

     - Parameters:
       - action: a read-only key-path from global action into a local action, but it's optional because maybe this
                 reducer shouldn't care about certain actions. Because actions are usually enums, you can switch over
                 the enum and in case it's nothing you care about, you simply return nil in the closure. If you don't
                 want to lift this reducer in terms of `action`, just remove this parameter from the call.
     - Returns: a `Reducer<GlobalAction, StateType>` that maps actions and states from the original specialized
                reducer into a more generic and global reducer, to be used in a larger context.
     */
    public func lift<GlobalActionType>(
        action: KeyPath<GlobalActionType, ActionType?>)
    -> Reducer<GlobalActionType, StateType> {
        lift(action: action, state: \.self)
    }
}
