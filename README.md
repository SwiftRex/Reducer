<p align="center">
    <a href="https://github.com/SwiftRex/SwiftRex/"><img src="https://swiftrex.github.io/SwiftRex/markdown/img/SwiftRexBanner.png" alt="SwiftRex" /></a><br /><br />
    Unidirectional Dataflow for your favourite reactive framework<br /><br />
</p>

![Build Status](https://github.com/SwiftRex/SwiftRex/actions/workflows/swift.yml/badge.svg?branch=develop)
[![codecov](https://codecov.io/gh/SwiftRex/SwiftRex/branch/develop/graph/badge.svg)](https://codecov.io/gh/SwiftRex/SwiftRex)
[![Jazzy Documentation](https://swiftrex.github.io/SwiftRex/api/badge.svg)](https://swiftrex.github.io/SwiftRex/api/index.html)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/SwiftRex.svg)](https://cocoapods.org/pods/SwiftRex)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-orange.svg)](https://swiftpackageindex.com/SwiftRex/SwiftRex)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftRex%2FSwiftRex%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftRex/SwiftRex)
[![Platform support](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20Catalyst-252532.svg)](https://github.com/SwiftRex/SwiftRex)
[![License Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://github.com/SwiftRex/SwiftRex/blob/master/LICENSE)

If you've got questions, about SwiftRex or redux and Functional Programming in general, please [Join our Slack Channel](https://join.slack.com/t/swiftrex/shared_invite/zt-oko9h1z4-Nq4YsK2FbMJ~giN01sdDeQ).

# SwiftRex

This is part of ["SwiftRex library"](https://github.com/SwiftRex/SwiftRex). Please read the library documentation to have full context about what Reducer is used for.

SwiftRex is a framework that combines Unidirectional Dataflow architecture and reactive programming ([Combine](https://developer.apple.com/documentation/combine), [RxSwift](https://github.com/ReactiveX/RxSwift) or [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift)), providing a central state Store for the whole state of your app, of which your SwiftUI Views or UIViewControllers can observe and react to, as well as dispatching events coming from the user interactions.

This pattern, also known as ["Redux"](https://redux.js.org/basics/data-flow), allows us to rethink our app as a single [pure function](https://en.wikipedia.org/wiki/Pure_function) that receives user events as input and returns UI changes in response. The benefits of this workflow will hopefully become clear soon.

[API documentation can be found here](https://swiftrex.github.io/SwiftRex/api/index.html).

# Reducer

`Reducer` is a pure function wrapped in a monoid container, that takes an action and the current state to calculate the new state.

The ``MiddlewareProtocol`` pipeline can do two things: dispatch outgoing actions and handling incoming actions. But what they can NOT do is changing the app state. Middlewares have read-only access to the up-to-date state of our apps, but when mutations are required we use the ``MutableReduceFunction`` function:

```swift
(ActionType, inout StateType) -> Void
```

Which has the same semantics (but better performance) than old ``ReduceFunction``:

```swift
(ActionType, StateType) -> StateType
```

Given an action and the current state (as a mutable inout), it calculates the new state and changes it:

```
initial state is 42
action: increment
reducer: increment 42 => new state 43

current state is 43
action: decrement
reducer: decrement 43 => new state 42

current state is 42
action: half
reducer: half 42 => new state 21
```

The function is reducing all the actions in a cached state, and that happens incrementally for each new incoming action.

It's important to understand that reducer is a synchronous operations that calculates a new state without any kind of side-effect (including non-obvious ones as creating `Date()`, using DispatchQueue or `Locale.current`), so never add properties to the ``Reducer`` structs or call any external function. If you are tempted to do that, please create a middleware and dispatch actions with Dates or Locales from it. 

Reducers are also responsible for keeping the consistency of a state, so it's always good to do a final sanity check before changing the state, like for example check other dependant properties that must be changed together.

Once the reducer function executes, the store will update its single source-of-truth with the new calculated state, and propagate it to all its subscribers, that will react to the new state and update Views, for example.

This function is wrapped in a struct to overcome some Swift limitations, for example, allowing us to compose multiple reducers into one (monoid operation, where two or more reducers become a single one) or lifting reducers from local types to global types.

The ability to lift reducers allow us to write fine-grained "sub-reducer" that will handle only a subset of the state and/or action, place it in different frameworks and modules, and later plugged into a bigger state and action handler by providing a way to map state and actions between the global and local ones. For more information about that, please check [Lifting](#lifting).

A possible implementation of a reducer would be:
```swift
let volumeReducer = Reducer<VolumeAction, VolumeState>.reduce { action, currentState in
    switch action {
    case .louder:
        currentState = VolumeState(
            isMute: false, // When increasing the volume, always unmute it.
            volume: min(100, currentState.volume + 5)
        )
    case .quieter:
        currentState = VolumeState(
            isMute: currentState.isMute,
            volume: max(0, currentState.volume - 5)
        )
    case .toggleMute:
        currentState = VolumeState(
            isMute: !currentState.isMute,
            volume: currentState.volume
        )
    }
}
```

Please notice from the example above the following good practices:
- No `DispatchQueue`, threading, operation queue, promises, reactive code in there.
- All you need to implement this function is provided by the arguments `action` and `currentState`, don't use any other variable coming from global scope, not even for reading purposes. If you need something else, it should either be in the state or come in the action payload.
- Do not start side-effects, requests, I/O, database calls.
- Avoid `default` when writing `switch`/`case` statements. That way the compiler will help you more.
- Make the action and the state generic parameters as much specialised as you can. If volume state is part of a bigger state, you should not be tempted to pass the whole big state into this reducer. Make it short, brief and specialised, this also helps preventing `default` case or having to re-assign properties that are never mutated by this reducer.

```
                                                                                                                    ┌────────┐                                     
                                                       IO closure                                                ┌─▶│ View 1 │                                     
                      ┌─────┐                          (don't run yet)                       ┌─────┐             │  └────────┘                                     
                      │     │ handle  ┌──────────┐  ┌───────────────────────────────────────▶│     │ send        │  ┌────────┐                                     
                      │     ├────────▶│Middleware│──┘                                        │     │────────────▶├─▶│ View 2 │                                     
                      │     │ Action  │ Pipeline │──┐  ┌─────┐ reduce ┌──────────┐           │     │ New state   │  └────────┘                                     
                      │     │         └──────────┘  └─▶│     │───────▶│ Reducer  │──────────▶│     │             │  ┌────────┐                                     
    ┌──────┐ dispatch │     │                          │Store│ Action │ Pipeline │ New state │     │             └─▶│ View 3 │                                     
    │Button│─────────▶│Store│                          │     │ +      └──────────┘           │Store│                └────────┘                                     
    └──────┘ Action   │     │                          └─────┘ State                         │     │                                   dispatch    ┌─────┐         
                      │     │                                                                │     │       ┌─────────────────────────┐ New Action  │     │         
                      │     │                                                                │     │─run──▶│       IO closure        ├────────────▶│Store│─ ─ ▶ ...
                      │     │                                                                │     │       │                         │             │     │         
                      │     │                                                                │     │       └─┬───────────────────────┘             └─────┘         
                      └─────┘                                                                └─────┘         │                     ▲                               
                                                                                                      request│ side-effects        │side-effects                   
                                                                                                             ▼                      response                       
                                                                                                        ┌ ─ ─ ─ ─ ─                │                               
                                                                                                          External │─ ─ async ─ ─ ─                                
                                                                                                        │  World                                                   
                                                                                                         ─ ─ ─ ─ ─ ┘                                               
```

## Lifting
- [Lifting](#lifting)
    - [Lifting Reducer](#lifting-reducer)
        - [Lifting Reducer using closures:](#lifting-reducer-using-closures)
        - [Lifting Reducer using KeyPath:](#lifting-reducer-using-keypath)
    - [Optional transformation](#optional-transformation)
    - [Direction of the arrows](#direction-of-the-arrows)
    - [Use of KeyPaths](#use-of-keypaths)
    - [Functional Helpers](#functional-helpers)
    - [Xcode Snippets:](#xcode-snippets)

### Lifting

An app can be a complex product, performing several activities that not necessarily are related. For example, the same app may need to perform a request to a weather API, check the current user location using CLLocation and read preferences from UserDefaults.

Although these activities are combined to create the full experience, they can be isolated from each other in order to avoid URLSession logic and CLLocation logic in the same place, competing for the same resources and potentially causing race conditions. Also, testing these parts in isolation is often easier and leads to more significant tests. 

Ideally we should organise our `AppState` and `AppAction` to account for these parts as isolated trees. In the example above, we could have 3 different properties in our AppState and 3 different enum cases in our AppAction to group state and actions related to the weather API, to the user location and to the UserDefaults access.

This gets even more helpful in case we split our app in 3 types of ``Reducer`` and 3 types of ``MiddlewareProtocol``, and each of them work not on the full `AppState` and `AppAction`, but in the 3 paths we grouped in our model. The first pair of ``Reducer`` and ``MiddlewareProtocol`` would be generic over ``WeatherState`` and ``WeatherAction``, the second pair over ``LocationState`` and ``LocationAction`` and the third pair over ``RepositoryState`` and ``RepositoryAction``. They could even be in different frameworks, so the compiler will forbid us from coupling Weather API code with CLLocation code, which is great as this enforces better practices and unlocks code reusability. Maybe our CLLocation middleware/reducer can be useful in a completely different app that checks for public transport routes.

But at some point we want to put these 3 different types of entities together, and the ``StoreType`` of our app "speaks" `AppAction` and `AppState`, not the subsets used by the specialised handlers.

```swift
enum AppAction {
    case weather(WeatherAction)
    case location(LocationAction)
    case repository(RepositoryAction)
}
struct AppState {
    let weather: WeatherState
    let location: LocationState
    let repository: RepositoryState
}
```
Given a reducer that is generic over `WeatherAction` and `WeatherState`, we can "lift" it to the global types `AppAction` and `AppState` by telling this reducer how to find in the global tree the properties that it needs. That would be `\AppAction.weather` and `\AppState.weather`. The same can be done for the middleware, and for the other 2 reducers and middlewares of our app.

When all of them are lifted to a common type, they can be combined together using the diamond operator (`<>`) and set as the store handler.

> **_IMPORTANT:_** Because enums in Swift don't have KeyPath as structs do, we strongly recommend reading [Action Enum Properties](docs/markdown/ActionEnumProperties.md) document and implementing properties for each case, either manually or using code generators, so later you avoid writing lots and lots of error-prone switch/case. We also offer some templates to help you on that.

Let's explore how to lift reducers and middlewares. 

#### Lifting Reducer

``Reducer`` has AppAction INPUT, AppState INPUT and AppState OUTPUT, because it can only handle actions (never dispatch them), read the state and write the state.

The lifting direction, therefore, should be:
```
Reducer:
- ReducerAction? ← AppAction
- ReducerState ←→ AppState
```

Given:
```swift
//      type 1         type 2
Reducer<ReducerAction, ReducerState>
```

Transformations:
```
                                                                                 ╔═══════════════════╗
                                                                                 ║                   ║
                       ╔═══════════════╗                                         ║                   ║
                       ║    Reducer    ║ .lift                                   ║       Store       ║
                       ╚═══════════════╝                                         ║                   ║
                               │                                                 ║                   ║
                                                                                 ╚═══════════════════╝
                               │                                                           │          
                                                                                                      
                               │                                                           │          
                                                                                     ┌───────────┐    
                         ┌─────┴─────┐   (AppAction) -> ReducerAction?               │           │    
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │  Reducer  │   { $0.case?.reducerAction }                  │           │    
    Input Action         │  Action   │◀──────────────────────────────────────────────│ AppAction │    
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │           │   KeyPath<AppAction, ReducerAction?>          │           │    
                         └─────┬─────┘   \AppAction.case?.reducerAction              │           │    
                                                                                     └───────────┘    
                               │                                                           │          
                                                                                                      
                               │         get: (AppState) -> ReducerState                   │          
                                         { $0.reducerState }                         ┌───────────┐    
                         ┌─────┴─────┐   set: (inout AppState, ReducerState) -> Void │           │    
┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐    │  Reducer  │   { $0.reducerState = $1 }                    │           │    
        State            │   State   │◀─────────────────────────────────────────────▶│ AppState  │    
└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘    │           │   WritableKeyPath<AppState, ReducerState>     │           │    
                         └─────┬─────┘   \AppState.reducerState                      │           │    
                                                                                     └───────────┘    
                               │                                                           │          
```

##### Lifting Reducer using closures:
```swift
.lift(
    actionGetter: { (action: AppAction) -> ReducerAction? /* type 1 */ in 
        // prism3 has associated value of ReducerAction,
        // and whole thing is Optional because Prism is always optional
        action.prism1?.prism2?.prism3
    },
    stateGetter: { (state: AppState) -> ReducerState /* type 2 */ in 
        // property2: ReducerState
        state.property1.property2
    },
    stateSetter: { (state: inout AppState, newValue: ReducerState /* type 2 */) -> Void in 
        // property2: ReducerState
        state.property1.property2 = newValue
    }
)
```
Steps:
- Start plugging the 2 types from the Reducer into the 3 closure headers.
- For type 1, find a prism that resolves from AppAction into the matching type. **BE SURE TO RUN SOURCERY AND HAVING ALL ENUM CASES COVERED BY PRISM**
- For type 2 on the stateGetter closure, find lenses (property getters) that resolve from AppState into the matching type.
- For type 2 on the stateSetter closure, find lenses (property setters) that can change the global state receive to the newValue received. Be sure that everything is writeable.

##### Lifting Reducer using KeyPath:
```swift
.lift(
    action: \AppAction.prism1?.prism2?.prism3,
    state: \AppState.property1.property2
)
```
Steps:
- Start with the closure example above
- For action, we can use KeyPath from `\AppAction` traversing the prism tree
- For state, we can use WritableKeyPath from `\AppState` traversing the properties as long as all of them are declared as `var`, not `let`.

#### Functional Helpers
Identity:
- when some parts of your lift should be unchanged because they are already in the expected type
- lift that using `identity`, which is `{ $0 }`

#### Xcode Snippets:
```swift
// Reducer closure
.lift(
    actionGetter: { (action: AppAction) -> <#LocalAction#>? in action.<#something?.child#> },
    stateGetter: { (state: AppState) -> <#LocalState#> in state.<#something.child#> },
    stateSetter: { (state: inout AppState, newValue: <#LocalState#>) -> Void in state.<#something.child#> = newValue }
)

// Reducer KeyPath:
.lift(
    action: \AppAction.<#something?.child#>,
    state: \AppState.<#something.child#>
)
```

# Installation

Please use SwiftRex installation instructions, instead. Reducers are not supposed to be used independently from SwiftRex.
