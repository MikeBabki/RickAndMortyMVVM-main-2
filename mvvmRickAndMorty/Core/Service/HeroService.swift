//
//  HeroService.swift
//  mvvmRickAndMorty
//
//  Created by Anton Redkozubov on 21.12.2023.
//

import Foundation

public protocol HeroService {
    func getResult(page: Int) async throws -> CharactersModel
    func getCharName(name: String) async throws -> CharactersModel
}
