//
//  ProfileViewModel.swift
//  FunchApp
//
//  Created by Geon Woo lee on 2/17/24.
//

import SwiftUI
import Combine

final class ProfileViewModel: ObservableObject {
    
    enum Action {
        case load
        case loadFailed
        case deleteProfile
        case feedback
    }
    
    enum PresentationState {
        case onboarding
    }
    
    @Published var presentation: PresentationState?
    @Published var profile: Profile?
    @Published var dismiss: Bool = false
    
    private var container: DependencyType
    private var useCase: DeleteProfileUseCase
    private var inject = Inject()
    
    private var cancellables = Set<AnyCancellable>()
    
    struct Inject {
        let openUrl: OpenURLProviderType = OpenURLProvider.shared
    }
    
    init(container: DependencyType, useCase: DeleteProfileUseCase) {
        self.container = container
        self.useCase = useCase
    }
    
    func send(action: Action) {
        switch action {
        case .load:
            guard let profile = container.services.userService.profiles.last else {
                self.send(action: .loadFailed)
                return
            }
            self.profile = profile
            
        case .loadFailed:
            dismiss = true
            
        case .deleteProfile:
            guard let userId = profile?.id else {
                // TODO: 내가 프로필이 없다면 ?
                return
            }
            
            useCase.execute(requestId: userId)
                .sink { _ in
                    
                } receiveValue: { [weak self] deletedId in
                    guard let self else { return }
                    self.container.services.userService.profiles = []
                    self.presentation = .onboarding
                }
                .store(in: &cancellables)
            
        case .feedback:
            do {
                try inject.openUrl.feedback()
            } catch {
                
            }
        }
    }
}
