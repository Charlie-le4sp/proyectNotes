 
# proyeto notas flutter web y android

un proyecto personal de app echa en flutter para android y web me arte de las apps que uso para notas y listas de tareas , voy hacer una 😎, aqui detallare el paso a paso que echo para conseguirlo....


# proceso inicial , diseño , definir funcionalidades y plataformas

define que funcionalidades debe tener tu app , en mi caso hago lo siguiente :

1) ver que aplicaciones hay similares en el mercado y comparar que quiero poner asi:

- 🎯 un login simple con firebase autentication y google sign auth para el registro y acceso de cada usuario a su contenido.

- 🎯 para este caso , quiero que la app pueda crear notas y listas de tareas sincronizado con la nube desde cualquier lugar.... 

- 🎯 que los usuarios puedan personalizar la app  , desde poner el tema que quieran , hasta cambiar el fondo de la pantalla principal...

- 🎯 ver ejemplos de diseño de notas o aplicaciones con el mismo tema en dribble.com

- 🎯 tener un diseño minimalista y responsive...

- que sea para web y android ya que para IOS Y MAC no puedo desarrollar , soy pobre 😂


- - - - - - - - - - - - - - - - - -- - - - - - -

ahora bien , con eso en mente , empezemos , ya llevo varios dias XD 

1) ⚡creacion de proyecto flutter (usando VSCODE facil)

2) ⚡definir que storage puedo usar ya que no tengo un pero para pagar nada ni siquiera una tarjeta de credito 😖🤧, en este caso USARE cloudinary .

3) ⚡crear proyecto en firebase ya que necesito:

- FIRESTORE 
    - para los datos de usuario , y la informacion de las notas 
- FIREBASE AUTENTICATION
    - para el login de usuario OBVIO 😎,hay que tener en cuenta de que la informacion de cada usuario debe enviarse a FIRESTORE tambien.
- HOSTING
    - para desplegar la aplicacion sin mas...xd


4).⚡Define que clase de informacion necesitas guardar en FIRESTORE , en mi caso necesito hacer lo siguiente :

    - crear una coleccion padre llamada "users"
        la cual debe tener los siguientes campos:
            username: Nombre de usuario.
            uid: ID único del usuario.
            email: Correo electrónico.
            profilePicture: URL de la imagen de perfil.
     ademas cuando el usuario se registre que se
      creara automaticamente 2 colecciones en su documento , para la informacion de las notas 
      las cuales seran "notes " y "lists"(ya lo detallaremos mas adelante xd 👁️)

             

ahora bien , la idea es que cada vez que un usuario se registre se creara un documento con su informacion automaticamente  , en la coleccion "users" con sus 2 colecciones...esto ya lo hacemos con codigo xd

y para los campos de las notas sera asi :


- Subcolección notes (Notas):

        noteImage: URL de la imagen de la nota.
        title: Título de la nota.
        createdAt: Fecha de creación.
        description: Descripción de la nota.
        reminderDate: Fecha de recordatorio.
        isDeleted: Booleano para eliminación
        suave(funcionalidad de papelera)


- Subcolección lists (lista de tareas):

        title: Título de la lista.
        isCompleted: Booleano para completado.
        description: Descripción de la lista.
        listImage: URL de la imagen de la lista.
        createdAt: Fecha de creación.
        reminderDate: Fecha de recordatorio.

empiezo por crear el proyecto en firebase y conectarlo a mi proyecto asi que para esto realizo las configuraciones necesarias en firebase y pongo los paquetes necesarios:

    Firebase:
        firebase_core
        cloud_firestore
        firebase_auth
        cloudinary_public
        firebase_storage, firebase_core_web

    Iconos:
        cupertino_icons

    Animaciones:
        flutter_animate
        Almacenamiento:
        shared_preferences

    Componentes:

    provider
    image_pick

inicializo firebase en el main.dart del proyecto , y tambien configuro el index.html del proyecto en la carpeta web , para que funcione correctamente 









    
