//
//  MainFeature.swift
//  mvvmRickAndMorty
//
//  Created by Anton Redkozubov on 21.12.2023.
//

import Foundation
import ComposableArchitecture
import MBProgressHUD

@Reducer
struct MainFeature {
    
    // MARK: - Enums

    struct State: Equatable {
        enum State: Equatable {
            case idle
            case loading
            case loaded
            case error
        }
        
        var state = State.idle
        var pageNumber = 1
        var data: [CharacterSet]? = []
        var pagesNum = CharactersModel()
    }
    
    // MARK: - Event's
    
    enum Action: Equatable {
        case onAppear
        case onLoaded(CharactersModel)
        case onNextPage(Int)
        case onDetailScreen(Int)
        case onError
    }
    
    // MARK: - Private properies
    
    private let service: HeroService
    private var flow: MainFlowController?
    
    // MARK: - Init
    
    init(service: HeroService, flow: MainFlowController) {
        self.service = service
        self.flow = flow
    }

    // MARK: - State Machine
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.state = .loading
                let number = state.pageNumber
                return .run { send in
                    do {
                        let data = try await service.getResult(page: number)
                        await send(.onLoaded(data))
                    }
                    catch {
                        await send(.onError)
                    }
                }
            case .onLoaded(let data):
                state.pageNumber += 1
                state.data?.append(contentsOf: data.results ?? [])
                state.pagesNum = data
                state.state = .loaded
                return .none
            case .onNextPage(let indexPath):
                    if state.pageNumber != state.pagesNum.info?.pages && indexPath == (state.data?.count ?? 18) - 2 {
                        return .run { send in
                            await send(.onAppear)
                        }
                    }
                return .none
            case .onDetailScreen(let index):
                flow?.goToDetailScreen(state.data?[index].name ?? "")
                return .none
            case .onError:
                state.state = .error
                return .none
            }
        }
    }
}
