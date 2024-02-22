//
//  HomeViewModel.swift
//  FunchApp
//
//  Created by Geon Woo lee on 2/17/24.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    
    enum Action: Equatable {
        case load
        case matching
        case feedback
        
        case presentation(PresentationAction)
        
        enum PresentationAction: Equatable, Identifiable {
            var id: UUID { UUID() }
            
            case profile
        }
    }
    
    enum PresentationState: Equatable, Identifiable {
        var id: UUID { UUID() }
        
        case profile
        case matchResult(MatchingInfo)
    }
    
    @Published var presentation: PresentationState?
    /// 코드 검색 텍스트 필드
    @Published var searchCodeText: String = ""
    /// 내 프로필
    @Published var profile: Profile?
    /// 매치 실패 시 알러트
    @Published var showingAlert: Bool = false
    
    private var container: DependencyType
    private var useCase: HomeUseCaseType
    
    init(container: DependencyType, useCase: HomeUseCaseType) {
        self.container = container
        self.useCase = useCase
    }

    func send(action: Action) {
        switch action {
        case .load:
            useCase.fetchProfile { [weak self] profile in
                guard let self else { return }
                self.profile = profile
                self.container.services.userService.profiles.append(profile)
            }
            
        case .matching:
            guard let profile else { return }
            useCase.searchUser(
                requestId: profile.id,
                targetUserCode: searchCodeText
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let matchingInfo):
                    presentation = .matchResult(matchingInfo)
                case .failure(_):
                    showingAlert = true
                }
            }
            
        case .feedback:
            container.services.openURLSerivce.execute(type: .feedback)
        
        case let .presentation(presentationAction):
            switch presentationAction {
            case .profile:
                presentation = .profile
            }
        }
    }
}
