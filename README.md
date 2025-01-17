 # Notes & Task App - Flutter (Web & Android) 📝

### Descripción 📌
Este proyecto es una aplicación de notas y listas de tareas desarrollada en Flutter, diseñada para funcionar en Android y la web. La idea surgió al buscar una solución más personalizada y práctica frente a las opciones disponibles en el mercado. 

El objetivo principal es ofrecer:
- Un diseño moderno y minimalista.
- Funcionalidades prácticas y sincronización en la nube.
- Personalización y acceso desde cualquier lugar.

---

## Características principales 🚀

1. **Autenticación de usuario:**
   - Inicio de sesión con **Firebase Authentication**.
   - Autenticación con Google.
   - Creación de perfiles únicos para cada usuario.

2. **Gestión de notas y tareas:**
   - Crear y sincronizar notas y listas en la nube.
   - Configuración de recordatorios y papelera de reciclaje.
   - Personalización de la app, incluyendo:
     - **Temas claros y oscuros**.
     - **Fondos personalizados**.

3. **Almacenamiento y sincronización:**
   - Uso de **Firebase Firestore** para almacenar datos.
   - Gestión de imágenes con **Cloudinary** y **Firebase Storage**.
   - Sincronización en tiempo real para acceso desde cualquier dispositivo.

4. **Diseño e interfaz de usuario:**
   - Diseño minimalista, moderno y responsivo.
   - Inspiración en ejemplos de diseño de [Dribbble](https://dribbble.com/).
   - Animaciones atractivas con **Lottie** y **Flutter Animate**.

5. **Estructura de datos en Firebase:**
   - **Colección de usuarios ("users"):**
     - Campos: `username`, `email`, `profilePicture`, `uid`.
     - Subcolecciones:
       - **Notas ("notes")**: título, descripción, recordatorios, fecha de creación, imagen, etc.
       - **Listas ("lists")**: título, descripción, estado de completado, imagen, etc.

6. **Soporte multiidioma:**
   - Idiomas disponibles: Español e Inglés.
   - Archivos JSON para traducciones.

7. **Soporte adicional:**
   - Funcionalidad **offline**.
   - Navegación fluida entre páginas.
   - Indicadores de carga y gestión de estados.

---

## Recursos utilizados 📚

- **Firebase:**
  - Firestore.
  - Authentication.
  - Hosting.
- **Almacenamiento:**
  - Cloudinary.
  - SharedPreferences.
- **Paquetes y herramientas:**
  - `flutter_animate`, `provider`, `image_picker`, entre otros.

---

## Estado actual del proyecto 🛠️
El proyecto está **en desarrollo** y las funciones principales ya están implementadas:
- Autenticación de usuarios.
- Creación y sincronización de notas y listas.
- Soporte para web y Android.

### Próximos pasos:
- Agregar nuevas funcionalidades y mejoras de diseño.
- Optimizar la experiencia de usuario.

---

## ¿Cómo contribuir? 🤝
¡Toda contribución es bienvenida! Puedes hacer un fork del repositorio, realizar mejoras y enviar un pull request. No dudes en reportar problemas o sugerir nuevas ideas.

---

### Capturas de pantalla 📸
![Preview](assets/images/recursos/send_email.png)

---

## Licencia 📜
Este proyecto está bajo la licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---
