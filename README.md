# NSCA Daily - Academia de Capellanes Escolares

Una aplicación móvil Flutter para la **National School Chaplain Association (NSCA)** que proporciona una plataforma de aprendizaje en línea completa para capellanes escolares.

## 📱 Descripción

NSCA Daily es una aplicación educativa que permite a los capellanes escolares acceder a cursos especializados, reportes diarios, y recursos de formación continua. La aplicación integra un sistema de gestión de aprendizaje (LMS) con funcionalidades específicas para el trabajo pastoral en entornos educativos.

## ✨ Características Principales

### 🎓 **Sistema de Cursos**
- **Catálogo de cursos** especializados en capellanía escolar
- **Bundles de cursos** agrupados por temáticas
- **Cursos gratuitos y de pago** con diferentes niveles
- **Reproductor de video** integrado (Vimeo, YouTube)
- **Descarga offline** de contenido para acceso sin conexión
- **Seguimiento de progreso** y certificaciones

### 📊 **Reportes Diarios**
- **Formularios de reporte** para actividades diarias
- **Estadísticas de estudiantes** (demografía, temas, resultados)
- **Información de personal docente** y facultad
- **Registro de crisis** y reuniones con padres
- **Análisis de porcentajes** por temas tratados

### 👤 **Gestión de Usuario**
- **Autenticación segura** con verificación de dispositivo
- **Perfil personalizable** con información profesional
- **Sistema de roles** y permisos
- **Integración con redes sociales** (Facebook, Twitter, LinkedIn)

### 🏠 **Dashboard Integrado**
- **WebView integrado** con el blog de NSCA
- **Navegación por pestañas** intuitiva
- **Acceso rápido** a funciones principales
- **Notificaciones** y actualizaciones

## 🛠️ Tecnologías Utilizadas

### **Frontend**
- **Flutter 3.35.3** - Framework de desarrollo multiplataforma
- **Dart 3.9.2** - Lenguaje de programación
- **Provider** - Gestión de estado
- **Material Design** - Sistema de diseño

### **Backend Integration**
- **HTTP Client** - Comunicación con API REST
- **Shared Preferences** - Almacenamiento local
- **SQLite** - Base de datos local para contenido offline

### **Multimedia**
- **Video Player** - Reproductor de videos
- **Vimeo Embed Player** - Integración con Vimeo
- **YouTube Player** - Integración con YouTube
- **WebView Flutter** - Contenido web integrado

### **Funcionalidades Adicionales**
- **Image Picker** - Selección de imágenes
- **URL Launcher** - Apertura de enlaces externos
- **Share Plus** - Compartir contenido
- **Connectivity Plus** - Detección de conectividad
- **Lottie** - Animaciones

## 📁 Estructura del Proyecto

```
lib/
├── constants.dart          # Configuraciones y colores
├── main.dart              # Punto de entrada de la aplicación
├── models/                # Modelos de datos
│   ├── course.dart        # Modelo de curso
│   ├── user.dart          # Modelo de usuario
│   ├── bundle.dart        # Modelo de bundle
│   ├── daily_report.dart  # Modelo de reporte diario
│   └── ...
├── providers/             # Gestión de estado
│   ├── auth.dart          # Autenticación
│   ├── courses.dart       # Gestión de cursos
│   ├── bundles.dart       # Gestión de bundles
│   └── ...
├── screens/               # Pantallas de la aplicación
│   ├── home_screen.dart   # Pantalla principal
│   ├── tabs_screen.dart   # Navegación por pestañas
│   ├── auth_screen.dart   # Autenticación
│   ├── courses_screen.dart # Catálogo de cursos
│   └── ...
└── widgets/               # Componentes reutilizables
```

## 🚀 Instalación y Configuración

### **Prerrequisitos**
- Flutter SDK 3.7.2 o superior
- Dart SDK 3.9.2 o superior
- Android Studio / Xcode
- Dispositivo físico o emulador

### **Pasos de Instalación**

1. **Clonar el repositorio**
   ```bash
   git clone [URL_DEL_REPOSITORIO]
   cd nsca_daily
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar la base de datos**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 🔧 Configuración

### **Variables de Entorno**
- `BASE_URL`: URL base de la API (configurada en `constants.dart`)
- Configuración de colores y temas en `constants.dart`

### **Permisos Requeridos**
- **Android**: Internet, Almacenamiento, Cámara
- **iOS**: Internet, Galería de fotos, Cámara

## 📱 Plataformas Soportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 11.0+)
- ✅ **Web** (Chrome, Safari, Firefox)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Windows** (Windows 10+)
- ✅ **Linux** (Ubuntu 18.04+)

## 🎨 Diseño y UX

- **Paleta de colores** personalizada para NSCA
- **Tipografía Google Sans** para mejor legibilidad
- **Navegación intuitiva** con bottom navigation
- **Responsive design** para diferentes tamaños de pantalla
- **Modo offline** para contenido descargado

## 📊 Funcionalidades del Sistema

### **Autenticación**
- Login/Registro con validación
- Recuperación de contraseña
- Verificación de dispositivo
- Gestión de sesiones

### **Cursos**
- Catálogo completo de cursos
- Filtros y búsqueda
- Progreso de aprendizaje
- Certificaciones

### **Reportes**
- Formularios de reporte diario
- Estadísticas detalladas
- Exportación de datos
- Historial de reportes

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es propiedad de la **National School Chaplain Association (NSCA)**. Todos los derechos reservados.

## 📞 Soporte

Para soporte técnico o consultas sobre la aplicación, contacta a:
- **Email**: [email de soporte]
- **Website**: [https://www.nationalschoolchaplainassociation.org](https://www.nationalschoolchaplainassociation.org)

## 🔄 Actualizaciones

- **Versión actual**: 0.1.0
- **Última actualización**: [Fecha]
- **Próximas características**: [Lista de features planificadas]

---

**Desarrollado con ❤️ para la National School Chaplain Association**