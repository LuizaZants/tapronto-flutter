# 🍽️ Tá Pronto!

**Aplicativo de receitas em Flutter com integração Firebase**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase)](https://firebase.google.com)
[![API](https://img.shields.io/badge/API-TheMealDB-orange)](https://www.themealdb.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)



---

## Sobre o Projeto

**Tá Pronto!** é um app de receitas desenvolvido em Flutter que consome a API pública **TheMealDB**, exibindo receitas organizadas por categorias, culinárias e ingredientes — com tradução automática para português. Utiliza **Firebase Authentication** para login de usuários e **Cloud Firestore** para persistência de receitas favoritas em tempo real.

---

## ✅ Requisitos Atendidos

| Critério | Status | Evidência |
|---------|--------|-----------|
| Aplicação exibindo dados de API | | `MealService` consome TheMealDB em todas as telas |
| Integração com Firebase | | Auth (login/cadastro) + Firestore (favoritos em tempo real) |
| README bem feito | | Este arquivo |
| Código-fonte Dart versionado | | Repositório GitHub com toda a pasta `lib/` |
| Desenho da arquitetura | | [`docs/architecture.svg`](docs/architecture.svg) |
| Prints da aplicação | | [`docs/screenshots/`](docs/screenshots/) |
| Link APK / versão web | | *Ver seção abaixo* |

---

## 🔗 Links

| Recurso | Link |
|---------|------|
| **Download APK** | `_link a ser adicionado após o build_` |
| **Versão Web** | `_link a ser adicionado após o deploy_` |
| **Repositório GitHub** | `_link a ser adicionado_` |

---

## Screenshots

| Login | Home | Detalhe | Favoritos |
|-------|------|---------|-----------|
| ![Login](docs/screenshots/01_login.png) | ![Home](docs/screenshots/02_home.png) | ![Detalhe](docs/screenshots/04_detail.png) | ![Favoritos](docs/screenshots/07_favorites.png) |

> Todos os prints estão em (docs/prints/) 

---

## Arquitetura

![Arquitetura do App](docs/architecture.svg)

### Camadas

```
lib/
├── main.dart                  # Entry point + Firebase init + MainNavigation
├── app_theme.dart             # Tema visual (cores, fontes Playfair + Lato)
├── firebase_options.dart      # Configuração Firebase
│
├── models/
│   └── meal_model.dart        # Modelo Meal (fromJson / toMap)
│
├── pages/
│   ├── login_page.dart        # Login e cadastro (Firebase Auth)
│   ├── home_page.dart         # Home: 9 categorias, destaques, seções
│   ├── detail_page.dart       # Detalhe: ingredientes, preparo, favoritar
│   ├── search_page.dart       # Busca por nome ou ingrediente
│   ├── catalog_page.dart      # Listagem por categoria ou culinária
│   └── favorites_page.dart    # Favoritos em tempo real (Firestore Stream)
│
├── services/
│   ├── meal_service.dart      # Chamadas TheMealDB + traduções PT/EN
│   ├── auth_service.dart      # Firebase Authentication
│   └── favorite_service.dart  # Cloud Firestore (favoritos)
│
└── widgets/
    ├── meal_card.dart         # Card de receita reutilizável
    ├── category_card.dart     # Card de categoria com imagem
    └── section_header.dart    # Cabeçalho de seção com divisória
```

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|-----------|--------|-----------|
| **Flutter** | ≥ 3.0 | Framework UI multiplataforma |
| **Dart** | ≥ 3.0 | Linguagem de programação |
| **TheMealDB API** | v1 (gratuita) | Dados de receitas, categorias e ingredientes |
| **Firebase Core** | ^3.1.0 | Inicialização do Firebase |
| **Firebase Auth** | ^5.1.0 | Autenticação por e-mail e senha |
| **Cloud Firestore** | ^5.1.0 | Banco NoSQL para favoritos em tempo real |
| **http** | ^1.2.0 | Requisições HTTP à API |
| **cached_network_image** | ^3.3.1 | Cache de imagens da API |
| **google_fonts** | ^6.2.0 | Fontes Playfair Display e Lato |

---

## Integração Firebase

### Firebase Authentication
- Login e cadastro por **e-mail e senha**
- `StreamBuilder<User?>` no `main.dart` controla o fluxo de autenticação
- Logout disponível na barra de navegação superior

### Cloud Firestore
- Coleção: `favoritos/{mealId}`
- Cada documento armazena `idMeal`, `strMeal`, `strMealThumb`, `strCategory`, `strArea`
- `FavoritesPage` usa **`StreamBuilder<QuerySnapshot>`** para atualização em tempo real
- `DetailPage` lê e escreve no Firestore ao clicar em "Salvar receita"

---

## API: TheMealDB

**Base URL:** `https://www.themealdb.com/api/json/v1/1`

| Endpoint | Uso no app |
|---------|-----------|
| `/search.php?s={nome}` | Busca por nome (SearchPage) |
| `/filter.php?i={ingrediente}` | Busca por ingrediente (SearchPage) |
| `/filter.php?c={categoria}` | Filtro por categoria (CatalogPage, HomePage) |
| `/filter.php?a={area}` | Filtro por culinária (CatalogPage) |
| `/lookup.php?i={id}` | Detalhe da receita (DetailPage, HomePage) |

**Tradução automática:** as instruções de preparo são traduzidas de EN → PT via `translate.googleapis.com`.

---

## Como Executar

### Pré-requisitos
- [Flutter SDK ≥ 3.0](https://docs.flutter.dev/get-started/install)
- [VS Code](https://code.visualstudio.com/) com extensão Flutter, ou [Android Studio](https://developer.android.com/studio)
- Conta no [Firebase Console](https://console.firebase.google.com) *(credenciais já configuradas no projeto)*

### 1. Clonar o repositório
```bash
git clone https://github.com/SEU_USUARIO/ta-pronto.git
cd ta-pronto
```

### 2. Instalar dependências
```bash
flutter pub get
```

### 3. Executar
```bash
# Android (emulador ou dispositivo conectado)
flutter run

# Web
flutter run -d chrome

# Listar dispositivos disponíveis
flutter devices
```

### 4. Gerar build

```bash
# APK Android (release)
flutter build apk --release
# Saída: build/app/outputs/flutter-apk/app-release.apk

# Web
flutter build web --release
# Saída: build/web/
```

---

## Usando no FlutLab

1. Acesse [flutlab.io](https://flutlab.io) e faça login
2. **New Project → Upload ZIP** — envie `ta_pronto-flutter`
3. Aguarde a instalação das dependências
4. Clique em **▶ Run → Android** ou **Web**
5. Para gerar APK: **Build → Android → APK**

---

## Estrutura Completa de Pastas

```
ta_pronto/
├── lib/                       # Todo o código-fonte Dart
├── android/                   # Configs Android + google-services.json
├── ios/                       # Configs iOS
├── web/                       # index.html, manifest.json
├── docs/
│   └── prints/                # Prints das telas do app
├── pubspec.yaml               # Dependências
└── README.md                  # Este arquivo
```

---

## Autor
Luiza Souza

Desenvolvido como trabalho acadêmico da disciplina de **Desenvolvimento Mobile com Flutter**.
