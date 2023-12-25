//
//  ViewController.swift
//  mvvmRickAndMorty
//
//  Created by Макар Тюрморезов on 29.11.2023.
//

import UIKit
import Combine
import MBProgressHUD
import ComposableArchitecture

class MainViewController: UIViewController {
    
    // MARK: - UIView
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MainTableHeroesCell.self, forCellReuseIdentifier: MainTableHeroesCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Private propetries
    
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: [CharacterSet] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Public propetries
    
    public var store: StoreOf<MainFeature>? {
        didSet {
            guard let store else  { return }
            bind(store: store)
        }
    }
    
    // MARK: - Lifecycle - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        store?.send(.onAppear)
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    //MARK: - Private method
    
    private func bind(store: StoreOf<MainFeature>) {
        store.publisher.removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state: state)
            }.store(in: &cancellables)
        store.publisher.data
            .sink(receiveValue: { [weak self] in self?.dataSource = $0 ?? [] })
            .store(in: &self.cancellables)
    }
    
    private func render(state: MainFeature.State) {
        switch state.state {
        case .idle:
            break
        case .loading:
            MBProgressHUD.showAdded(to: self.view, animated: true)
        case .loaded:
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tableView.reloadData()
            }
        case .error:
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}

// MARK: - Extention for layout

extension MainViewController {
    private func setupUI() {
        
        view.backgroundColor = .white
        title = "Rick and Morty!"
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Extention for TableView DataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableHeroesCell.id, for: indexPath) as! MainTableHeroesCell
        let modelForCell = dataSource[indexPath.row]
        cell.configure(withModel: modelForCell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        store?.send(.onNextPage(indexPath.row))
    }
}

// MARK: - Extention for TableView Delegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store?.send(.onDetailScreen(indexPath.item))
    }
}
