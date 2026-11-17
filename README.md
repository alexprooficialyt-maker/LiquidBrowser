# 🌐 LiquidBrowser

**Navegador web nativo para iPhone** — SwiftUI + WebKit + Liquid Glass (iOS 26)
30 funciones | Zero IA | Privacidad real

---

## 📁 Estructura del proyecto

```
LiquidBrowser/
├── App/                    ← Entry point y estado global
├── DesignSystem/           ← Liquid Glass, iconos vectoriales, colores
│   └── Icons/
├── Models/                 ← BrowserTab, Space, Bookmark, HistoryItem, Download
├── ViewModels/             ← BrowserViewModel, TabManager, BookmarkManager…
├── Views/
│   ├── Onboarding/         ← Flujo de bienvenida (3 pasos)
│   ├── Browser/            ← Pantalla principal, barra flotante, pestañas
│   └── Tools/              ← Historial, Marcadores, Descargas, Lectura, Ajustes
├── Resources/
│   ├── Info.plist          ← Permisos y metadatos
│   └── LiquidBrowser.entitlements
├── project.yml             ← Para generar el .xcodeproj con XcodeGen
├── codemagic.yaml          ← Build en la nube → genera el .ipa
└── ExportOptions.plist     ← Opciones de exportación del .ipa
```

---

## 🚀 Cómo generar el `.ipa` desde Windows (sin Mac)

### OPCIÓN A — Codemagic (recomendada, gratis 500 min/mes)

#### Paso 1 — Requisitos previos
- Cuenta gratuita en [codemagic.io](https://codemagic.io)
- Cuenta en [github.com](https://github.com) (gratuita)
- Apple ID gratuito (para instalar solo en tu iPhone)
- **Opcional**: Apple Developer Account ($99/año) para distribuir

#### Paso 2 — Subir el código a GitHub

1. Abre **GitHub Desktop** o instálalo desde [desktop.github.com](https://desktop.github.com)
2. Crea un nuevo repositorio: `File → New Repository`
   - Name: `LiquidBrowser`
   - Local path: `D:\App Navegador Iphone`
3. Haz commit de todos los archivos y pulsa **Publish repository**

#### Paso 3 — Conectar Codemagic

1. Entra en [codemagic.io](https://codemagic.io) → **Sign up with GitHub**
2. Pulsa **Add application** → selecciona tu repo `LiquidBrowser`
3. Codemagic detectará automáticamente el `codemagic.yaml`

#### Paso 4 — Certificado de firma (Code Signing)

> Para instalar solo en **tu iPhone** (sin App Store):
> No necesitas la Developer Account de pago. Usa **Apple ID gratuito**:

1. En Codemagic → tu app → **Settings → Code signing**
2. Sube un certificado de desarrollo (`development`)
3. Sube el Provisioning Profile de tu dispositivo

> Si no tienes certificado, Codemagic puede gestionarlo automáticamente
> con su integración de Apple Developer (si tienes la cuenta de $99).

#### Paso 5 — Lanzar el build

1. En Codemagic → pulsa **Start new build**
2. Selecciona branch: `main`
3. Espera ~10-15 minutos ☕
4. Descarga el `.ipa` desde el panel de artefactos

#### Paso 6 — Instalar en tu iPhone

**Sin Apple Developer Account (método gratuito):**
- Usa [AltStore](https://altstore.io) → instala el `.ipa` directamente en tu iPhone

**Con Apple Developer Account:**
- Usa [Apple Configurator 2](https://apps.apple.com/app/apple-configurator-2/id1037126344) (macOS)
- O envíalo a TestFlight para pruebas

---

### OPCIÓN B — GitHub Actions (también gratis)

Añade este archivo a tu repo como `.github/workflows/build.yml`:

```yaml
name: Build IPA
on: [push]
jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Instalar XcodeGen
        run: brew install xcodegen
      - name: Generar proyecto
        run: xcodegen generate
      - name: Build
        run: |
          xcodebuild -project LiquidBrowser.xcodeproj \
                     -scheme LiquidBrowser \
                     -sdk iphonesimulator \
                     -configuration Debug \
                     build | xcpretty
```

---

## 🛠️ Si tienes acceso a un Mac (el método más directo)

```bash
# 1. Instalar XcodeGen
brew install xcodegen

# 2. Ir a la carpeta del proyecto
cd "ruta/a/LiquidBrowser"

# 3. Generar el .xcodeproj
xcodegen generate

# 4. Abrir en Xcode
open LiquidBrowser.xcodeproj

# 5. Seleccionar tu iPhone → Product → Archive → Distribute App
```

---

## ⚙️ Personalización rápida

| Ajuste | Dónde |
|--------|-------|
| Bundle ID | `project.yml` → `PRODUCT_BUNDLE_IDENTIFIER` |
| Nombre app | `Resources/Info.plist` → `CFBundleDisplayName` |
| Color acento | App → Ajustes → Color de acento |
| Motor de búsqueda | App → Ajustes → Motor |
| Team ID (firma) | `ExportOptions.plist` → `teamID` |

---

## 📋 Fases del proyecto

| Fase | Contenido | Estado |
|------|-----------|--------|
| Fase 1 | DesignSystem + Onboarding | ✅ Completo |
| Fase 2 | Models + ViewModels + BrowserView | ✅ Completo |
| Fase 3 | Info.plist + Build config + Instrucciones | ✅ Completo |

---

## 🔒 Permisos que usa la app

| Permiso | Para qué |
|---------|----------|
| Face ID / Touch ID | Bloquear pestañas privadas |
| Fotos (solo escritura) | Guardar capturas de pantalla de páginas |
| Internet | Navegar 🌐 |
| Archivos locales | Gestor de descargas |

---

## 📌 Notas técnicas

- **Target mínimo**: iOS 17.0
- **Framework web**: WebKit (`WKWebView`)
- **Bloqueador**: `WKContentRuleList` con 10 reglas nativas
- **Persistencia**: `@AppStorage` + `UserDefaults` + `URLSession`
- **Arquitectura**: MVVM con `@Observable` (Swift 5.9+)
- **Sin dependencias externas** — 100% Swift nativo
