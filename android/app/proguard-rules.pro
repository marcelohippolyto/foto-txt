# O plugin do ML Kit referencia os reconhecedores de chinês, japonês, coreano
# e devanágari, mas o app só usa o latino. Sem isto o R8 falha no build release.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
