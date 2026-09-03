# VALIDATION

## Nivel A — estructura

- Proyecto Xcode y scheme compartido presentes.
- Todos los Swift incluidos en Sources.
- Assets incluidos en Resources.
- `Info.plist` y permisos de cámara/fototeca presentes.
- Workflow de IPA presente.
- Scripts Windows presentes.
- Sin claves, credenciales ni dependencias externas.

## Nivel B — validación estática local

Se ejecuta antes de empaquetar el ZIP:

- `swiftc -parse` sobre todos los `.swift`.
- parse XML de `Info.plist` y scheme.
- parse JSON de catálogos de assets.
- parse YAML del workflow.
- revisión de referencias del `project.pbxproj`.
- búsqueda de nombres residuales de proyectos anteriores.

La validación estática no sustituye el type-checking de SwiftUI/SwiftData contra el SDK de iOS.

## Nivel C — compilación iOS autoritativa

GitHub Actions ejecuta `xcodebuild` Release para `iphoneos` y destino `generic/platform=iOS` con code signing desactivado. Solo un build Xcode correcto demuestra que el target compila completamente.


## Compatibilidad de destinos con Xcode 26.5

`xcodebuild -showdestinations` puede mostrar el destino físico como `Any iOS Device`
en lugar de imprimir literalmente `generic/platform=iOS`.

El workflow valida por tanto la existencia de un destino iOS físico y mantiene
`-destination 'generic/platform=iOS'` únicamente en el comando real de compilación.
