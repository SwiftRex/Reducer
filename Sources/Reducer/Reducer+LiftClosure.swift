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
         actionGetter: { $0 },
         stateGetter: { global in global.currentLocation },
         stateSetter: { global, part in global.currentLocation = path }
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                             ↑ lift
     //           gpsReducer: Reducer<MyAction, Location>
     ```

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     Same strategy works for the `action`, as you can guess by the `actionGetter` parameter. You can provide a function
     that takes a global action (_Whole_) and returns an optional local action (_Part_). It's optional because perhaps
     you want to ignore actions that are not relevant for this reducer.

     - Parameters:
       - actionGetter: a way to convert a global action into a local action, but it's optional because maybe this
                       reducer shouldn't care about certain actions. Because actions are usually enums, you can switch
                       over the enum and in case it's nothing you care about, you simply return nil in the closure. If
                       you don't want to lift this reducer in terms of `action`, just provide the identity function
                       `{ $0 }` as input.
       - stateGetter: a way to read from a global state and extract only the part that it's relevant for this reducer,
                      by traversing the tree of the global state until you find the property you want, for example:
                      `{ $0.currentGame.scoreBoard }`
       - stateSetter: a way to write back into the global state once you finished reducing the _Part_, so now you have
                      a new part that was calculated by this reducer and you want to set it into the global state, also
                      provided as the first parameter as an `inout` property:
                      `{ globalState, newScoreBoard in globalState.currentGame.scoreBoard = newScoreBoard }`
     - Returns: a `Reducer<GlobalAction, GlobalState>` that maps actions and states from the original specialised
                reducer into a more generic and global reducer, to be used in a larger context.
     */
    public func lift<GlobalActionType, GlobalStateType>(
        actionGetter: @escaping (GlobalActionType) -> ActionType?,
        stateGetter: @escaping (GlobalStateType) -> StateType,
        stateSetter: @escaping (inout GlobalStateType, StateType) -> Void)
    -> Reducer<GlobalActionType, GlobalStateType> {
        .reduce { globalAction, globalState in
            guard let localAction = actionGetter(globalAction) else { return }
            var localState = stateGetter(globalState)
            self.reduce(localAction, &localState)
            stateSetter(&globalState, localState)
        }
    }
}
