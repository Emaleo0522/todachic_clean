# TODAChic v1.6.1 - Instrucciones de Deploy

## 📦 Archivo de Deploy
**`todachic_v1.6.1_FINAL.zip`** (8.6 MB)

## 🚀 Cómo subir a Netlify

### Opción 1: Drag & Drop (Recomendado)
1. Ve a [netlify.com](https://netlify.com)
2. Extrae el ZIP: `todachic_v1.6.1_FINAL.zip`
3. Arrastra la carpeta `build/web/` (no el ZIP) al área de deploy
4. ¡Listo!

### Opción 2: Manual Upload
1. Extrae `todachic_v1.6.1_FINAL.zip`
2. Ve a la carpeta `build/web/`
3. Selecciona todos los archivos dentro
4. Súbelos a Netlify

## ✅ Contenido del ZIP
- `index.html` - Página principal
- `main.dart.js` - App compilada v1.6.1
- `flutter_service_worker.js` - Cache nuevo (868668521)
- `version.json` - Versión 1.6.1+8 correcta
- `_redirects` - Routing para Netlify
- `assets/` - Recursos de la app
- `canvaskit/` - Engine de Flutter
- `icons/` - PWA icons

## 🔧 Fixes Incluidos v1.6.1
✅ QR View - Sin botón "Imprimir" en móvil
✅ QR Download - Descarga directa PNG en móvil
✅ QR Scanner - Cámara por defecto en móvil
✅ Service Worker - Cache completamente renovado
✅ Versión - Actualizada correctamente

## 📱 Testing Post-Deploy
1. **Web**: Verificar que muestra v1.6.1
2. **Móvil**: 
   - Ver QR → Sin botón imprimir
   - Descargar PNG → Descarga directa
   - Scanner → Cámara por defecto

## 🏠 Para continuar en casa
- Archivo: `todachic_v1.6.1_FINAL.zip`
- Proyecto: TODAChic - Sistema gestión tienda
- Estado: Listo para deploy con QR móvil corregido
- Documentación: `TRABAJO_REALIZADO.md`

¡El build está completamente funcional y listo para producción!