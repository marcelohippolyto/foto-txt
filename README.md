# Foto para TXT

Tire uma foto de um texto e receba o conteúdo como arquivo `.txt`. O reconhecimento roda no próprio celular, sem servidor.

O repositório tem duas versões:

| Versão | Onde | Como usar |
|---|---|---|
| **Web (PWA)** | `docs/` | Ative o GitHub Pages (branch `main`, pasta `/docs`), abra o link no celular e instale na tela inicial. Usa Tesseract.js. |
| **Android/iOS (Flutter)** | raiz do repositório | Rode o workflow **Build APK** em *Actions* e baixe o `app-release.apk`. Usa Google ML Kit. |

## Flutter
- Android: `flutter build apk --release` gera `build/app/outputs/flutter-apk/app-release.apk`.
- iOS: precisa de Mac com Xcode e dos passos de *Requirements > iOS* do pacote `google_mlkit_text_recognition`. Não testado.
- Reconhece só alfabeto latino (português, inglês, espanhol…).
