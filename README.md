# NSCA Daily - Academia de Capellanes Escolares

Una aplicación móvil Flutter para la **National School Chaplain Association (NSCA)** que proporciona una plataforma de aprendizaje en línea completa para capellanes escolares.

## 📱 Descripción

NSCA Daily es una aplicación educativa que permite a los capellanes escolares acceder a cursos especializados, reportes diarios, y recursos de formación continua. La aplicación integra un sistema de gestión de aprendizaje (LMS) con funcionalidades específicas para el trabajo pastoral en entornos educativos.

## 🔗 Enlaces del Proyecto

- **Repositorio**: [https://github.com/Angello-27/nsca_daily.git](https://github.com/Angello-27/nsca_daily.git)
- **Plataforma Web**: [https://www.nscaacademy.org/](https://www.nscaacademy.org/)
- **Organización**: [National School Chaplain Association](https://www.nationalschoolchaplainassociation.org/)

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

```text
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
   git clone https://github.com/Angello-27/nsca_daily.git
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

- `BASE_URL`: [https://www.nscaacademy.org/](https://www.nscaacademy.org/) (configurada en `constants.dart`)
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

### **Información de Contacto**

- **Email**: [info@campuschaplains.org](mailto:info@campuschaplains.org)
- **Teléfono**: 405.831.3299
- **Website**: [https://www.nscaacademy.org/](https://www.nscaacademy.org/)
- **Dirección**: P.O. Box 720746, Norman OK 73070

### **Horarios de Atención**

- **Lunes a Viernes**: 8:00 AM - 6:00 PM (CST)

### **Enlaces Útiles**

- [NSCA Academy](https://www.nscaacademy.org/) - Plataforma de aprendizaje
- [National School Chaplain Association](https://www.nationalschoolchaplainassociation.org/) - Organización principal

## 🔄 Actualizaciones

- **Versión actual**: 0.1.0
- **Última actualización**: 3 de enero de 2025
- **Próximas características**:
  - Mejoras en la interfaz de usuario
  - Nuevas funcionalidades de reportes
  - Optimización de rendimiento
  - Integración con más plataformas de video

---

## 👥 Equipo de NSCA

**National School Chaplain Association (NSCA)** fue establecida para promover a los capellanes escolares como miembros legítimos y necesarios del personal escolar a través de estándares nacionales para capellanes escolares.

NSCA es un ministerio de capellanía cristiana que proporciona cuidado espiritual, consejería y apoyo comunitario práctico a estudiantes de Pre-K hasta 12º grado, maestros y sus familias, independientemente de edad, raza, credo, sexo, origen nacional, religión, orientación sexual, discapacidad, estado civil o estatus socioeconómico.

Nuestros capellanes capacitados y certificados proporcionan consejo, educación, defensa, habilidades de mejora de vida y entrenamiento de recuperación, sirviendo como un puente entre los entornos seculares y espirituales de la vida comunitaria en todo Estados Unidos.

### **Visión**

Un capellán certificado en cada campus escolar.

### **Misión**

Proporcionar apoyo espiritual y emocional a maestros, estudiantes, personal y sus familias.

### **Principios**

Mostramos a Cristo en lo que decimos y hacemos. Encontramos a las personas donde están, sin importar las circunstancias, para mostrar compasión y amor tal como lo haría Jesús.

---

**Desarrollado con ❤️ por el equipo de NSCA
