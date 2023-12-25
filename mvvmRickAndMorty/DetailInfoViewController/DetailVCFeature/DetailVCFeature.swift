//
//  DetailVCFeature.swift
//  mvvmRickAndMorty
//
//  Created by Макар Тюрморезов on 21.12.2023.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SecondVCFeature {
    
    struct State: Equatable {
        enum State: Equatable {
            case idle
            case loading
            case loaded(CharactersModel)
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
            case onLoading(CharactersModel)
            case onError
        }
        
        // MARK: - Private properies
        
        private let service: HeroService
        private var flow: MainFlowController?
        private var name: String?  
        
        // MARK: - Init
        
    init( service: HeroService, flow: MainFlowController, heroName: String) {
            self.service = service
            self.flow = flow
            self.name = heroName
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
                            let data = try await service.getCharName(name: name ?? "")
                            await send(.onLoading(data))
                            
                        }
                        catch {
                            await send(.onError)
                        }
                }
                    case .onLoading (let data):
                        state.pageNumber += 1
                        state.data?.append(contentsOf: data.results ?? [])
                        state.pagesNum = data
                        state.state = .loaded(data)
                        return .none
                            
                case .onError:
                    state.state = .error
                    return .none
                }
            }
        }
    }

