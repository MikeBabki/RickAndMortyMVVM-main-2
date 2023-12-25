//
//  Coordinato.swift
//  mvvmRickAndMorty
//
//  Created by Макар Тюрморезов on 03.12.2023.
//

import Foundation
import UIKit
import ComposableArchitecture

final class MainFlowController: UINavigationController {
    
    // MARK: - Public methods
    
    func goToDetailScreen(_ heroName: String) {

        let detailView = DetailInfoVeiwController()
        detailView.store = .init(initialState: SecondVCFeature.State(), reducer: {
            SecondVCFeature(service: HeroServiceImpl(), flow: self, heroName: heroName)
        })
                let backButton = UIBarButtonItem(title: self.title, style: .plain, target: nil, action: nil)
                backButton.tintColor = .black
                self.navigationBar.topItem?.backBarButtonItem = backButton
        pushViewController(detailView, animated: true)
    }
    
    // MARK: - Private methods
    
    private func goToMainScreen() {
        let vc = MainViewController()
        vc.store = .init(initialState: MainFeature.State(), reducer: {
            MainFeature(service: HeroServiceImpl(), flow: self)
        })
        self.pushViewController(vc, animated: false)
    }

    // MARK: - Init
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        goToMainScreen()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
