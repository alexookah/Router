

# Router

<img src="assets/router-hero.svg" alt="Router" width="100%" />

Una biblioteca ligera de navegación para SwiftUI que desacopla la lógica de enrutamiento de las vistas. Construida sobre `@Observable` para iOS 17+.

<img width="320" height="703" alt="output_1776425725010" src="assets/demo.gif" />

## ¿Por qué Router?

La mayoría de las bibliotecas de enrutamiento para SwiftUI limitan la navegación a un solo `NavigationStack`. Router va más allá:

- **Cualquier pantalla, desde cualquier lugar** — Define una sola enumeración de rutas que englobe las rutas por función, y cualquier pantalla puede agregarse, presentarse como una hoja o mostrarse como una superposición de pantalla completa desde cualquier pestaña. Sin pasar enrutadores entre vistas, sin cableado manual.
- **Navegación jerárquica** — Los enrutadores forman una cadena padre-hijo cuando se presentan modales. `NavigationTarget` te permite dirigir las acciones a cualquier punto de la jerarquía: presenta en la raíz, agrega al padre o apila en el hijo más profundo.
- **Swift moderno** — Construido sobre `@Observable` y `@Environment`, no sobre `ObservableObject` y `@EnvironmentObject` heredados.
- **Enlaces profundos con soporte para pestañas** — Maneja enlaces profundos que cambian de pestaña y navegan dentro de ellas, utilizando un solo modificador `.onDeepLink`.

## Características

- **Enrutamiento seguro de tipos** mediante enumeraciones `Routable`: cada caso mapea a una vista
- **Navegación con push, hojas y superposiciones de pantalla completa** con un solo `Router<Destination>` genérico
- **NavigationTarget** — enruta a `.current`, `.parent`, `.root` o `.deepest` en una jerarquía
- **Enrutamiento entre pestañas** — enrutadores inyectados mediante `@Environment`, accesibles desde cualquier vista hija
- **Opciones de presentación de hojas** — detents, indicador de arrastre
- **Botones de descarte configurables** — mostrar/ocultar, posición izquierda/derecha, mostrar en vistas agregadas dentro de modales
- **Enlaces profundos** — el modificador `.onDeepLink` maneja tanto URLs externas como llamadas internas de `openURL`
- **Gestión automática de enrutadores hijos** — los modales obtienen su propio enrutador, que se limpia al descartarse

## Requisitos

- iOS 17+
- macOS 14+
- Swift 6.0+

## Instalación

### Administrador de Paquetes Swift

Agrega a tu `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexookah/Router.git", from: "1.0.0")
]
```

O en Xcode: Archivo > Agregar dependencias de paquetes y pega la URL del repositorio.

## Inicio rápido

### 1. Define tus rutas

```swift
import Router

enum HomeRoute: Routable {
    case home
    case detail(String)
    case settings

    func destination() -> some View {
        switch self {
        case .home: HomeView()
        case let .detail(id): DetailView(id: id)
        case .settings: SettingsView()
        }
    }
}
```

### 2. Envuelve tu contenido en RoutingView

```swift
struct ContentView: View {
    @State var router = Router<HomeRoute>()

    var body: some View {
        RoutingView(router) { router in
            router.start(.home)
        }
    }
}
```

### 3. Navega desde cualquier vista hija

El enrutador se inyecta automáticamente en el entorno de SwiftUI:

```swift
struct HomeView: View {
    @Environment(Router<HomeRoute>.self) var router

    var body: some View {
        Button("Show Detail") {
            router.push(route: .detail("123"))
        }

        Button("Open Settings Sheet") {
            router.presentSheet(
                route: .settings,
                options: .init(detents: [.medium, .large])
            )
        }

        Button("Open Settings Full Screen") {
            router.present(route: .settings)
        }
    }
}
```

## API de Navegación

### Push

```swift
router.push(route: .detail("123"))
router.push(route: .detail("123"), target: .root) // push on root router
```

### Sheet

```swift
router.presentSheet(route: .settings)
router.presentSheet(
    route: .settings,
    options: .init(detents: [.medium, .large], dragIndicator: .visible),
    dismissOptions: .init(showDismissButton: true)
)
```

### Full-Screen Cover

> `present()` es exclusivo de iOS. macOS no tiene un equivalente para superposición de pantalla completa: usa `presentSheet(...)` en macOS.

```swift
router.present(route: .settings)
router.present(
    route: .settings,
    dismissOptions: .init(
        showDismissButton: true,
        dismissButtonPosition: .left,
        showDismissButtonOnPush: true  // show X on views pushed within the modal
    )
)
```

### Pop & Dismiss

```swift
router.pop()                // go back one
router.pop(last: 3)         // go back three
router.popToRoot()           // clear the stack

router.dismissChild()        // dismiss current sheet/fullScreenCover
router.dismiss()             // ask parent to dismiss this modal
router.dismissOrPopToRoot() // smart dismiss
router.dismissAllFromRoot()  // dismiss entire hierarchy
```

### Manipulación de la pila

```swift
router.replaceStack(with: [.home, .detail("1"), .detail("2")])
router.replaceLast(with: .detail("3"))
router.lastPathIs(.detail("3")) // true
```

## Jerarquía del enrutador

Cuando presentas una hoja o una superposición de pantalla completa, Router crea automáticamente un **enrutador hijo** para el modal. Esto forma una cadena padre-hijo:

```
Root Router (tab)
  └── Child Router (sheet)
        └── Child Router (full-screen cover inside the sheet)
```

Cada hijo tiene una referencia a su padre. Cuando se descarta un modal, su enrutador hijo se limpia automáticamente.

### NavigationTarget

`NavigationTarget` te permite dirigir las acciones de navegación a cualquier punto de esta jerarquía:

| Target | Description |
|--------|-------------|
| `.current` | This router (default) |
| `.parent` | The parent router |
| `.child` | The child router |
| `.root` | The top-most router in the chain |
| `.deepest` | The furthest child (leaf) in the chain |

```swift
// From inside a sheet, push on the parent's navigation stack
router.push(route: .detail("1"), target: .parent)

// From anywhere, present on the root router
router.presentSheet(route: .settings, target: .root)

// Stack a modal on top of an existing modal
router.presentSheet(route: .profile, target: .deepest)
```

Esto permite el enrutamiento entre pestañas y el apilamiento de modales sin pasar los enrutadores manualmente.

## Enrutamiento entre pestañas

Usa una sola enumeración de rutas que englobe las rutas por función. Cada pestaña obtiene su propio enrutador y cualquier vista puede navegar entre pestañas:

```swift
// Define a top-level route
enum AppRoute: Routable {
    case home(HomeRoute)
    case profile(ProfileRoute)
    case search(SearchRoute)

    func destination() -> some View {
        switch self {
        case let .home(route): route.destination()
        case let .profile(route): route.destination()
        case let .search(route): route.destination()
        }
    }
}

typealias AppRouter = Router<AppRoute>

// One router per tab
struct MainTabView: View {
    @State var homeRouter = AppRouter()
    @State var profileRouter = AppRouter()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                RoutingView(homeRouter) { $0.start(.home(.home)) }
            }
            Tab("Profile", systemImage: "person") {
                RoutingView(profileRouter) { $0.start(.profile(.profile)) }
            }
        }
    }
}

// From any child view — present a profile screen from the home tab
struct HomeView: View {
    @Environment(AppRouter.self) var router

    var body: some View {
        Button("View Profile") {
            router.presentSheet(route: .profile(.profile), target: .root)
        }
    }
}
```

## Enlaces profundos

El modificador `.onDeepLink` maneja URLs de fuentes externas (Safari, notificaciones push) y llamadas internas de `openURL`. Devuelve `true` si la URL fue gestionada, `false` para pasarla al sistema.

```swift
TabView(selection: $selectedTab) {
    // tabs...
}
.onDeepLink { url in
    guard url.scheme == "myapp",
          let host = url.host else { return false }

    switch host {
    case "home":
        selectedTab = .home
        if let id = url.pathComponents.dropFirst().first {
            homeRouter.push(route: .home(.detail(id)))
        }
    case "profile":
        selectedTab = .profile
    default:
        return false
    }
    return true
}
```

## Opciones del botón de descarte

Controla el botón de descarte en los modales:

```swift
// Full-screen cover with dismiss button on the left (default)
router.present(route: .settings)

// Dismiss button on the right
router.present(
    route: .settings,
    dismissOptions: .init(dismissButtonPosition: .right)
)

// Show dismiss button on pushed views within a modal
router.present(
    route: .settings,
    dismissOptions: .init(
        showDismissButton: true,
        showDismissButtonOnPush: true
    )
)

// Sheet with dismiss button (sheets hide it by default since they have swipe-to-dismiss)
router.presentSheet(
    route: .settings,
    dismissOptions: .init(showDismissButton: true)
)
```

## App de ejemplo

El proyecto de Xcode `ExampleRouterDemo` demuestra todas las características con una aplicación de 4 pestañas:

- **Inicio** — navegación push, superposiciones de pantalla completa, enrutamiento entre pestañas
- **Apilamiento** — presenta hojas sobre hojas usando `target: .deepest`, descarta todo con `dismissAllFromRoot()`
- **Perfil** — superposición de pantalla completa con posicionamiento del botón de descarte
- **Enlaces profundos** — URLs de enlaces profundos clicables que activan el cambio de pestaña y la navegación

Para ejecutarlo, abre `ExampleRouterDemo/ExampleRouterDemo.xcodeproj` — el paquete Router ya está incluido como una dependencia local.

## Licencia

MIT

---

Si encuentras útil Router, dale una :star: — ayuda a otros a descubrir el proyecto.
