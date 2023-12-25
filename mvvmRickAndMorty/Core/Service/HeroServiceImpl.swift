//
//  HeroServiceImpl.swift
//  mvvmRickAndMorty
//
//  Created by Anton Redkozubov on 21.12.2023.
//

import Foundation

public class HeroServiceImpl: HeroService {
    
    public func getResult(page: Int) async throws -> CharactersModel {
        let url = URL(string: URLManager.rickURLCreator(page: page))!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let heroes = try JSONDecoder().decode(CharactersModel.self, from: data)
        return heroes
    }
    
    public func getCharName(name: String) async throws -> CharactersModel {
        let url = URL(string: URLManager.charNameFinder(name: name))!
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let heroes = try JSONDecoder().decode(CharactersModel.self, from: data)
        return heroes
    }
}
