# Instalación desde Windows

## 1. Crear un repositorio vacío en GitHub

Crea un repositorio para Sumaticket. No añadas README desde GitHub si vas a subir directamente este proyecto.

## 2. Subir el proyecto

Ejecuta:

```text
SUBIR_A_GITHUB.bat
```

La primera vez pedirá la URL HTTPS del repositorio. En ejecuciones posteriores reutilizará `origin`.

## 3. Obtener la IPA

En GitHub:

1. Abre **Actions**.
2. Entra en **Build Sumaticket IPA**.
3. Espera a que finalice correctamente.
4. Descarga el artefacto **Sumaticket-iPhone**.
5. Dentro estarán:
   - `Sumaticket-iPhone.ipa`
   - `Sumaticket-iPhone.ipa.sha256`

Si el build falla, descarga **xcode-diagnostics**. Incluye el log completo y el `.xcresult` para localizar el error real de Xcode.

## 4. Instalar con AltStore Classic

1. Instala AltServer en Windows.
2. Instala AltStore Classic en el iPhone mediante AltServer.
3. Activa **Modo desarrollador** en el iPhone si iOS lo solicita.
4. Abre AltStore en el iPhone.
5. Usa **My Apps > +** y selecciona `Sumaticket-iPhone.ipa`.
6. AltStore firmará la app localmente con tu Apple ID y la instalará.

Con una cuenta Apple gratuita las apps firmadas por sideloading normalmente necesitan renovarse periódicamente mediante AltStore/AltServer.

## Seguridad

No guardes contraseñas de Apple, certificados, perfiles de aprovisionamiento ni claves privadas en GitHub. Este proyecto no los necesita para producir la IPA sin firmar.
