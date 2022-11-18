import Foundation
import Reducer

struct ActionScopedById<ActionType: Equatable>: Equatable {
    let id: Int
    let action: ActionType

    var tuple: (id: Int, action: ActionType) { (id: id, action: action) }
}

struct ActionScopedByIndex<ActionType: Equatable>: Equatable {
    let index: Int
    let action: ActionType

    var tuple: (index: Int, action: ActionType) { (index: index, action: action) }
}

enum AppAction: Equatable {
    case foo
    case bar(Bar)
    case scoped(ActionScopedById<Bar>)

    enum Bar: Equatable {
        case alpha
        case bravo
        case charlie
        case delta
        case echo

        var alpha: Void? {
            if case .alpha = self { return () }
            return nil
        }

        var bravo: Void? {
            if case .bravo = self { return () }
            return nil
        }

        var charlie: Void? {
            if case .charlie = self { return () }
            return nil
        }

        var delta: Void? {
            if case .delta = self { return () }
            return nil
        }

        var echo: Void? {
            if case .echo = self { return () }
            return nil
        }
    }

    var foo: Void? {
        if case .foo = self { return () }
        return nil
    }

    var bar: Bar? {
        if case let .bar(bar) = self { return bar }
        return nil
    }

    var scoped: ActionScopedById<Bar>? {
        get {
            if case let .scoped(action) = self { return action }
            return nil
        }
        set {
            guard case .scoped = self, let newValue = newValue else { return }
            self = .scoped(newValue)
        }
    }
}

enum ActionForScopedTests {
    case toIgnore
    case somethingScopedById(ActionScopedById<String>)
    case somethingScopedByIndex(ActionScopedByIndex<String>)

    var toIgnore: Void? {
        if case .toIgnore = self { return () }
        return nil
    }

    var somethingScopedById: ActionScopedById<String>? {
        if case let .somethingScopedById(action) = self { return action }
        return nil
    }

    var somethingScopedByIndex: ActionScopedByIndex<String>? {
        if case let .somethingScopedByIndex(action) = self { return action }
        return nil
    }
}

struct TestState: Equatable {
    var value = UUID()
    var name = ""
}

struct AppState: Equatable {
    let testState: TestState
    var list: [Item]

    struct Item: Equatable, Identifiable {
        let id: Int
        var name: String
    }
}

let createNameReducer: () -> Reducer<AppAction, TestState> = {
    .reduce { action, state in
        switch action {
        case .foo: state.name = "foo"
        case .bar(.alpha): state.name = "alpha"
        case .bar(.bravo): state.name = "bravo"
        case .bar(.charlie): state.name = "charlie"
        case .bar(.delta): state.name = "delta"
        case .bar(.echo): state.name = "echo"
        case .scoped: state.name = "scoped"
        }
    }
}

let createReducerMock: () -> (Reducer<AppAction, TestState>, ReducerMock<AppAction, TestState>) = {
    let mock = ReducerMock<AppAction, TestState>()

    return (Reducer.reduce { action, state in
        mock.reduceCallsCount += 1
        mock.reduceReceivedArguments = (action: action, currentState: state)
        state = mock.reduceClosure.map { $0(action, state) } ?? mock.reduceReturnValue
    }, mock)
}

class ReducerMock<ActionType, StateType> {
    // MARK: - reduce

    var reduceCallsCount = 0
    var reduceCalled: Bool {
        reduceCallsCount > 0
    }
    var reduceReceivedArguments: (action: ActionType, currentState: StateType)?
    var reduceReturnValue: StateType!
    var reduceClosure: ((ActionType, StateType) -> StateType)?
}
