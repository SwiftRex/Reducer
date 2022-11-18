import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Reducer where StateType: Identifiable {
    /**
     A type-lifting method for collections. The global state of your app is _Whole_, and the `Reducer` handles an element
     that is inside of a collection, which itself is sub-state of the global. Let's call this single element _Part_.

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
         let knownLocations: [Location]
     }
     ```

     As expected, _Part_ (`Location`) is an element of the array `knownLocations`, which is property of _Whole_
     (`MyGlobalState`). This relationship could be less direct, for example there could be several levels of properties
     until you find the _Part_ in the _Whole_, like `global.firstLevel.secondLevel.knownLocations`, but let's keep it a
     single-level for this example.

     To resolve this single element, we not only have to find the path to the array, but we have to find the element
     inside of the array. There are three methods for doing so:
     1) the element is `Identifiable` (iOS 13 or later)
     2) the element has a `Hashable` property that makes it unique, so we can find it in the array using this identifier
     3) using the index of the element in the array

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `liftToCollection` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.liftToCollection(
         actionMap: \.actionKeyPathToATuple,
         state: \.knownLocations
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                                 ↑ lift
     //           gpsReducer: Reducer<LocationAction, Location>
     ```

     Different from simple `lift` to scalar, this one requires necessarily that you lift the action together with the state.
     That's because your action has to contain the ID or Index of the element we will modify. The `actionMap` KeyPath has to
     give us a tuple of either:
     - `(id, actionToSingleElement)`
     - `(index, actionToSingleElement)`

     The id or index is gonna be how we will search the array for the desired element, and only if we find it, we will run
     the `gpsReducer` for that specific element, using the action that has to do with single elements only.

     As `Location` doesn't have an `id` property we will have to either use index, implement `Identifiable` protocol or
     give another unique and `Hashable` property.

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     - Parameters:
       - actionMap: a read-only key-path from global action into a tuple: (id, local action), but it's optional because
                    maybe this reducer shouldn't care about certain actions.
       - stateCollection: a writable key-path from global state that traverses into a local state, by extracting only
                          the part that it's relevant for this reducer. This part needs to be a `MutableCollection`.
     - Returns: a `Reducer<GlobalAction, GlobalState>` that maps actions and states from the original local reducer, which
                is specialised in a single Element, into a more generic and global reducer, to be used in a larger context.
     */
    public func liftToCollection<GlobalAction, GlobalState, CollectionState: MutableCollection>(
        action actionMap: KeyPath<GlobalAction, (id: StateType.ID, action: ActionType)?>,
        stateCollection: WritableKeyPath<GlobalState, CollectionState>
    ) -> Reducer<GlobalAction, GlobalState> where CollectionState.Element == StateType {
        Reducer<GlobalAction, GlobalState>.reduce { action, state in
            guard let itemAction = action[keyPath: actionMap],
                  let itemIndex = state[keyPath: stateCollection].firstIndex(where: { $0.id == itemAction.id })
            else { return }

            self.reduce(itemAction.action, &state[keyPath: stateCollection][itemIndex])
        }
    }
}

extension Reducer {
    /**
     A type-lifting method for collections. The global state of your app is _Whole_, and the `Reducer` handles an element
     that is inside of a collection, which itself is sub-state of the global. Let's call this single element _Part_.

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
         let knownLocations: [Location]
     }
     ```

     As expected, _Part_ (`Location`) is an element of the array `knownLocations`, which is property of _Whole_
     (`MyGlobalState`). This relationship could be less direct, for example there could be several levels of properties
     until you find the _Part_ in the _Whole_, like `global.firstLevel.secondLevel.knownLocations`, but let's keep it a
     single-level for this example.

     To resolve this single element, we not only have to find the path to the array, but we have to find the element
     inside of the array. There are three methods for doing so:
     1) the element is `Identifiable` (iOS 13 or later)
     2) the element has a `Hashable` property that makes it unique, so we can find it in the array using this identifier
     3) using the index of the element in the array

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `liftToCollection` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.liftToCollection(
         actionMap: \.actionKeyPathToATuple,
         state: \.knownLocations
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                                 ↑ lift
     //           gpsReducer: Reducer<LocationAction, Location>
     ```

     Different from simple `lift` to scalar, this one requires necessarily that you lift the action together with the state.
     That's because your action has to contain the ID or Index of the element we will modify. The `actionMap` KeyPath has to
     give us a tuple of either:
     - `(id, actionToSingleElement)`
     - `(index, actionToSingleElement)`

     The id or index is gonna be how we will search the array for the desired element, and only if we find it, we will run
     the `gpsReducer` for that specific element, using the action that has to do with single elements only.

     As `Location` doesn't have an `id` property we will have to either use index, implement `Identifiable` protocol or
     give another unique and `Hashable` property.

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     - Parameters:
       - actionMap: a read-only key-path from global action into a tuple: (id, local action), but it's optional because
                    maybe this reducer shouldn't care about certain actions.
       - stateCollection: a writable key-path from global state that traverses into a local state, by extracting only
                          the part that it's relevant for this reducer. This part needs to be a `MutableCollection`.
       - identifier: a key-path to define who is the unique-identifier of the Element (it has to be `Hashable`)
     - Returns: a `Reducer<GlobalAction, GlobalState>` that maps actions and states from the original local reducer, which
                is specialised in a single Element, into a more generic and global reducer, to be used in a larger context.
     */
    public func liftToCollection<GlobalAction, GlobalState, CollectionState: MutableCollection, ID: Hashable>(
        action actionMap: KeyPath<GlobalAction, (id: ID, action: ActionType)?>,
        stateCollection: WritableKeyPath<GlobalState, CollectionState>,
        identifier: KeyPath<StateType, ID>
    ) -> Reducer<GlobalAction, GlobalState> where CollectionState.Element == StateType {
        Reducer<GlobalAction, GlobalState>.reduce { action, state in
            guard let itemAction = action[keyPath: actionMap],
                  let itemIndex = state[keyPath: stateCollection].firstIndex(where: { $0[keyPath: identifier] == itemAction.id })
            else { return }

             self.reduce(itemAction.action, &state[keyPath: stateCollection][itemIndex])
        }
    }
}

extension Reducer {
    /**
     A type-lifting method for collections. The global state of your app is _Whole_, and the `Reducer` handles an element
     that is inside of a collection, which itself is sub-state of the global. Let's call this single element _Part_.

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
         let knownLocations: [Location]
     }
     ```

     As expected, _Part_ (`Location`) is an element of the array `knownLocations`, which is property of _Whole_
     (`MyGlobalState`). This relationship could be less direct, for example there could be several levels of properties
     until you find the _Part_ in the _Whole_, like `global.firstLevel.secondLevel.knownLocations`, but let's keep it a
     single-level for this example.

     To resolve this single element, we not only have to find the path to the array, but we have to find the element
     inside of the array. There are three methods for doing so:
     1) the element is `Identifiable` (iOS 13 or later)
     2) the element has a `Hashable` property that makes it unique, so we can find it in the array using this identifier
     3) using the index of the element in the array

     Because our `Store` understands _Whole_ (`MyGlobalState`) and our `gpsReducer` understands _Part_ (`Location`), we
     must `liftToCollection` the `Reducer` to the _Whole_ level, by using:

     ```
     let globalStateReducer = gpsReducer.liftToCollection(
         actionMap: \.actionKeyPathToATuple,
         state: \.knownLocations
     )
     // where:
     //   globalStateReducer: Reducer<MyAction, MyGlobalState>
     //                                                 ↑ lift
     //           gpsReducer: Reducer<LocationAction, Location>
     ```

     Different from simple `lift` to scalar, this one requires necessarily that you lift the action together with the state.
     That's because your action has to contain the ID or Index of the element we will modify. The `actionMap` KeyPath has to
     give us a tuple of either:
     - `(id, actionToSingleElement)`
     - `(index, actionToSingleElement)`

     The id or index is gonna be how we will search the array for the desired element, and only if we find it, we will run
     the `gpsReducer` for that specific element, using the action that has to do with single elements only.

     As `Location` doesn't have an `id` property we will have to either use index, implement `Identifiable` protocol or
     give another unique and `Hashable` property.

     Now this reducer can be used within our `Store` or even composed with others. It also can be used in other apps as
     long as we have a way to lift it to the world of _Whole_.

     - Parameters:
       - actionMap: a read-only key-path from global action into a tuple: (index, local action), but it's optional because
                    maybe this reducer shouldn't care about certain actions.
       - stateCollection: a writable key-path from global state that traverses into a local state, by extracting only
                          the part that it's relevant for this reducer. This part needs to be a `MutableCollection`.
     - Returns: a `Reducer<GlobalAction, GlobalState>` that maps actions and states from the original local reducer, which
                is specialised in a single Element, into a more generic and global reducer, to be used in a larger context.
     */
    public func liftToCollection<GlobalAction, GlobalState, CollectionState: MutableCollection>(
        action actionMap: KeyPath<GlobalAction, (index: CollectionState.Index, action: ActionType)?>,
        stateCollection: WritableKeyPath<GlobalState, CollectionState>
    ) -> Reducer<GlobalAction, GlobalState> where CollectionState.Element == StateType {
        Reducer<GlobalAction, GlobalState>.reduce { action, state in
            guard let itemAction = action[keyPath: actionMap],
                  state[keyPath: stateCollection].inBounds(itemAction.index)
            else { return }

            self.reduce(itemAction.action, &state[keyPath: stateCollection][itemAction.index])
        }
    }
}

extension Collection {
    func inBounds(_ index: Index) -> Bool {
        index < endIndex && index >= startIndex
    }
}
