# Unsent — Collaboration Guide

> This document is for contributors. It covers how to set up the project, where code lives, how to add new features, and the conventions we follow.
> Developer Team : Fidel Cavell, Habil, Theona Arlinton, Valentino Hartanto, M. Rezaldo
---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Architecture Rules](#architecture-rules)
4. [Adding a New Feature](#adding-a-new-feature)
5. [Branching & Git Workflow](#branching--git-workflow)
6. [Code Conventions](#code-conventions)
7. [Common Pitfalls](#common-pitfalls)

---

## Getting Started

**Requirements**
- Xcode 16+
- iOS/iPadOS 17+ deployment target
- Swift 5.10+

**Steps**
1. Clone the repo and open `Postbox.xcodeproj`.
2. Select a real device or simulator running iOS/iPadOS 17+.
3. Build and run. No external dependencies or downloads are required.

---

## Project Structure

### Folder Explanations

| Folder | Purpose |
|---|---|
| `App/` | The entry point of the app. Contains `PostboxApp.swift` (`@main`) and `AppFactory.swift` which is the single place responsible for wiring up dependencies (repositories → ViewModels). Nothing else belongs here. |
| `Features/` | Each subfolder is one self-contained feature of the app. A feature owns its own Views, ViewModels, and any models or components that are *exclusive* to it. If something is shared across features, it does not go here. |
| `Features/Journal/` | The core feature of the app — everything related to creating, editing, and viewing journal entries. |
| `Features/Journal/Components/` | Small SwiftUI subviews that belong only to the Journal feature (e.g. a canvas toolbar, a sticker picker). If a component is needed in another feature, move it to `Shared/Components/`. |
| `Features/Journal/Models/` | Data types or enums that are *only* used inside the Journal feature (e.g. a `CanvasTool` enum). Do not put `@Model` SwiftData classes here — those go in `Shared/Models/`. |
| `Features/Journal/ViewModels/` | The `JournalViewModel` that drives all Journal screens. One ViewModel per feature. |
| `Features/Journal/Views/` | The three screens of the Journal feature: the home list, the canvas editor, and the read-only detail view. |
| `Services/` | Long-lived, app-wide background services that are not tied to any single feature. Currently houses notification scheduling. Services are instantiated once (inside `AppFactory` if needed) and injected. |
| `Services/Notifications/` | Logic for scheduling and managing local notifications (e.g. "you haven't journaled in a while"). |
| `Assets.xcassets/` | Xcode asset catalog for the app icon, accent color, and any image/color assets used across the app. |
| `Shared/` | Everything that is reusable across more than one feature. Nothing here should depend on a specific feature. |
| `Shared/Components/` | Generic SwiftUI views used in multiple features (e.g. a custom button style, a loading spinner, a card container). |
| `Shared/Extensions/` | Swift extensions on system types (`Color`, `Date`, `String`, etc.) and SwiftUI environment keys. Naming convention: `TypeName+Purpose.swift`. |
| `Shared/Models/` | SwiftData `@Model` classes and shared `Codable` structs used across features. `Journal.swift` lives here because it is the core data entity of the whole app. |
| `Shared/Repositories/` | The data access layer. Repositories abstract SwiftData operations (fetch, insert, delete, save) so ViewModels never touch `ModelContext` directly. One repository per model. |
| `Shared/Utilities/` | Stateless pure helpers that don't fit as extensions — e.g. a date formatter singleton, a haptic feedback manager, or a file path resolver. |

---

### File Tree

```
Postbox/
├── App/
│   ├── PostboxApp.swift                   # @main entry point, SwiftData ModelContainer setup
│   └── AppFactory.swift                   # DI factory — creates all ViewModels
│
├── Features/
│   └── Journal/
│       ├── Components/                    # (empty)
│       ├── Models/                        # (empty)
│       ├── ViewModels/
│       │   └── JournalViewModel.swift
│       └── Views/
│           ├── JournalListView.swift
│           ├── JournalEditorView.swift
│           └── JournalDetailView.swift
│
├── Services/
│   └── Notifications/                     # (empty)
│
├── Assets.xcassets/
│
└── Shared/
    ├── Components/                        # (empty)
    ├── Extensions/
    │   └── AppFactory+Environment.swift
    ├── Models/
    │   └── Journal.swift
    ├── Repositories/
    │   └── JournalRepository.swift
    └── Utilities/                         # (empty)
```

---

## Architecture Rules

We follow **MVVM + Feature-Based + Repository** structure with `AppFactory` for dependency injection.

### 0. App entry lives in `App/`
`PostboxApp.swift` is the `@main` entry — do not move it. `AppFactory` is the single source of all ViewModel creation. It is injected into the SwiftUI environment once at the root via `AppFactory+Environment.swift`.

```swift
// PostboxApp.swift — inject factory at the root
WindowGroup {
    ContentView()
        .environment(\.appFactory, AppFactory(modelContext: container.mainContext))
}
.modelContainer(container)
```

### 1. ViewModels are created by `AppFactory`, never by Views directly

```swift
// ✅ Correct — factory creates the VM
viewModel = appFactory?.makeJournalViewModel()

// ❌ Wrong — View creates its own VM (bypasses DI, hard to test)
@State private var viewModel = JournalViewModel(repository: ...)
```

### 2. One ViewModel per feature; injected via `.environment()`
The **root view** of a feature creates the VM via `@State` and broadcasts it to children using `.environment()`. Children read it with `@Environment(ViewModelType.self)` — no init params needed.

```swift
// ✅ Root view (JournalListView) — owns and broadcasts the VM
struct JournalListView: View {
    @Environment(\.appFactory) private var appFactory
    @State private var viewModel: JournalViewModel?

    var body: some View {
        Group {
            if let viewModel { ... }
        }
        .environment(viewModel)
        .onAppear {
            guard viewModel == nil else { return }
            viewModel = appFactory?.makeJournalViewModel()
        }
    }
}

// ✅ Child view — reads from environment
struct JournalEditorView: View {
    @Environment(JournalViewModel.self) private var viewModel
}
```

### 3. ViewModels use `@Observable`, not `ObservableObject`
All ViewModels use the `@Observable` macro (iOS 17+). Do **not** use `ObservableObject`, `@Published`, `@StateObject`, or `@ObservedObject`.

```swift
// ✅ Correct
@Observable
final class JournalViewModel { ... }

// ❌ Wrong
final class JournalViewModel: ObservableObject {
    @Published var items: [Journal] = []
}
```

### 4. Persistence goes through the Repository
Views and ViewModels never touch `ModelContext` directly. All SwiftData operations go through `JournalRepository`.

```swift
// ✅ Correct — ViewModel delegates to repository
func save(_ journal: Journal) {
    repository.save(journal)
}

// ❌ Wrong — bypasses the repository
modelContext.insert(journal)
```

### 5. Shared models live in `Shared/Models/`
`@Model` classes and `Codable` structs used across features go in `Shared/Models/`. Do not define shared types inside a feature folder.

### 6. Views do no logic
Views call ViewModel methods only. They do not call repositories or services directly.

### 7. Extensions & utilities go in `Shared/`
Swift extensions on system types go in `Shared/Extensions/` using `TypeName+Purpose.swift` naming. Stateless helpers go in `Shared/Utilities/`.

---

## Adding a New Feature

Say you're adding an **Onboarding** screen. Follow these steps:

**1. Create the folder structure** *(the folders already exist for Onboarding — just add the files)*
```
Features/
└── Onboarding/
    ├── Views/
    │   └── OnboardingView.swift
    └── ViewModels/
        └── OnboardingViewModel.swift       # only if async logic is needed
```

**2. Scaffold the ViewModel** *(skip if the screen has no async logic)*
```swift
import Foundation

@Observable
final class OnboardingViewModel {
    // Add your state and logic here
}
```

**3. Add a factory method to `AppFactory`** *(only if a ViewModel was created)*
```swift
func makeOnboardingViewModel() -> OnboardingViewModel {
    OnboardingViewModel()
}
```

**4. Scaffold the root View**
```swift
import SwiftUI

struct OnboardingView: View {
    @Environment(\.appFactory) private var appFactory
    @State private var viewModel: OnboardingViewModel?

    var body: some View {
        Group {
            if let viewModel { ... }
        }
        .environment(viewModel)
        .onAppear {
            guard viewModel == nil else { return }
            viewModel = appFactory?.makeOnboardingViewModel()
        }
    }
}
```

**5. If you need a new shared model**, add it to `Shared/Models/`, not inside the feature folder.

---

## Branching & Git Workflow

```
main          — stable, always builds
develop       — integration branch, PRs merge here first
feature/xxx   — your work branch
fix/xxx       — bug fix branch
```

**Branch naming**
```
feature/journal-canvas-editor
feature/onboarding-flow
fix/save-animation-timing
```

**Typical flow**
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name

# ... do your work ...

git push origin feature/your-feature-name
# Open a PR → develop
```

**PR rules**
- Target `develop`, never `main` directly.
- PRs require at least one reviewer before merge.
- Must build without warnings on a real device or simulator.
- Include a short description of what changed and why.

---

## Code Conventions

| Topic | Convention |
|---|---|
| Naming | Swift API Design Guidelines — clear at call site |
| Async work | `async/await` + `Task { @MainActor in … }` |
| Observable | `@Observable` macro only — no `ObservableObject` or `@Published` |
| Error handling | Surface errors via a property on the ViewModel (e.g. `var errorMessage: String?`) |
| SwiftData | All access through `JournalRepository`, never raw `ModelContext` in Views/VMs |
| Previews | Every View should have a `#Preview` block |
| Comments | `// MARK: -` to section ViewModels |

**Async state mutation**
```swift
// ✅ Always mutate on MainActor
Task { @MainActor in
    self.isLoading = true
}

// ❌ Never mutate from a background thread
DispatchQueue.global().async {
    self.isLoading = true // data race
}
```

---

## Common Pitfalls

**Don't call `makeJournalViewModel()` in child views**
Only `JournalListView` (the root of the Journal feature) calls the factory. Child views (`JournalEditorView`, `JournalDetailView`) read the same instance via `@Environment`. Calling the factory in a child creates a disconnected VM with separate state.

**Don't use `@StateObject` or `@ObservedObject`**
Those belong to `ObservableObject`. Since all ViewModels use `@Observable`, use `@State` for ownership and `@Environment` for reading.

**Don't skip `.environment(viewModel)` when `viewModel` is optional**
If `.environment(viewModel)` is not called, child views will crash at runtime when they try to read `@Environment(JournalViewModel.self)`.

**Don't define shared data models inside a feature folder**
If a model is used by more than one feature, it belongs in `Shared/Models/`.

**`Journal.swift` currently has no properties**
The `Journal` SwiftData model is a scaffold. Add properties (e.g. canvas data, date, title) before writing any persistence logic.

---

Questions? Reach out in the team channel or open a GitHub Discussion.
