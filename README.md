# Sumaticket

Sumaticket es una app nativa para iPhone que digitaliza tickets mediante la cámara, extrae sus datos con OCR local y organiza el gasto automáticamente.

## Funciones incluidas

- Cámara para fotografiar tickets.
- Importación alternativa desde Fotos.
- OCR local con Apple Vision, sin API externa.
- Detección automática de establecimiento, importe total y fecha.
- Propuesta automática de categoría general.
- Pantalla **¿Es correcto?** antes de guardar, con todos los campos editables.
- Agrupación automática por establecimiento.
- Agrupación por categorías generales: comida, supermercado, ropa, gasolina, juegos, tecnología, hogar, salud, transporte, servicios, ocio, viajes, educación y otros.
- Total global de todos los tickets activos.
- Total de cada establecimiento al entrar en su categoría.
- Total de cada categoría general al entrar en ella.
- Buscador de tickets y establecimientos.
- Imagen original del ticket y texto OCR almacenados localmente.
- Papelera de 30 días con recuperación y borrado definitivo.
- Limpieza automática de tickets caducados en la papelera.
- Interfaz SwiftUI con Liquid Glass en iOS 26 y material translúcido equivalente en iOS 17-25.
- Apariencia Sistema / Claro / Noche.
- SwiftData para persistencia local.

## Privacidad

No existe backend, cuenta, telemetría ni claves API. El reconocimiento de texto se ejecuta con Vision en el dispositivo y la información se guarda en SwiftData.

## Requisitos

- iPhone con iOS 17 o superior.
- Para generar la IPA desde Windows: Git + cuenta de GitHub.
- Para instalar: AltServer + AltStore Classic.

## Subida a GitHub desde Windows

`SUBIR_A_GITHUB.bat` es reejecutable. Antes de subir:
- hace `fetch` de `origin`;
- integra `origin/main` mediante `pull --rebase` cuando comparte historial;
- admite un repositorio remoto inicializado por separado mediante `--allow-unrelated-histories`;
- nunca usa `push --force`;
- si existe un conflicto, se detiene y muestra cómo resolverlo.

## Compilación

El workflow `.github/workflows/build-ipa.yml` realiza un build Release real para `iphoneos`, sin firma, genera `Sumaticket-iPhone.ipa`, valida el ZIP y publica también su SHA-256.

Consulta `INSTALACION_WINDOWS.md` para el flujo completo.
