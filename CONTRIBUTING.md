## :wrench: Clonación y configuración del repositorio

> [!NOTE]
> Para disfrutar de un buen ambiente para **programar en local** necesita:
> [Gradle](https://gradle.org/) viene de forma portable como wrapper.
> [Docker](https://www.docker.com/) y [Git](https://git-scm.com/) son necesarios.
> Java JDK 21 (portable para gradle con [Foojay Toolchains Plugin](https://github.com/gradle/foojay-toolchains)).

Sigue estos pasos para clonar el repositorio:

Abre una terminal y ejecuta los siguientes comandos:

### 1. Clonar el repositorio

```bash
git clone https://github.com/kingg22/api-vacunas-panama.git
```

### 2. Abrir la carpeta donde fue clonado el repositorio

### 3. Crear un entorno propio para deploy

> [!NOTE]
> Puede utilizar un archivo env o docker secrets, ambas deben utilizar los nombres dados en .env.example al menos que
> modifique application.properties
>
> Debe utilizar 2 archivos env el docker.env para colocar las ip internas de docker y .env para utilizarlo de forma
> externa.
> Si se decide por usar docker secrets puede eliminar el uso de env_file en
> docker-compose.yaml

1. Crear el par de llaves del certificado RSA. Abra una **terminal de git** (Git Bash) en el proyecto y ejecute:
    ``` bash
    openssl genrsa -out private.pem 4096
    openssl rsa -in private.pem -pubout -out public.pem
    ```
2. Colocar en JWT_PRIVATE y JWT_PUBLIC el contenido de cada archivo correspondiente. (Opcional solo para programar local)

   Utilizando Docker secrets: Puede colocar sus archivos al final del docker-compose, estos deben estar en la misma
   carpeta
    ``` dockerfile
    secrets:
      JWT_PUBLIC_KEY:
        file: public.pem
      JWT_PRIVATE_KEY:
        file: private.pem
    ```

3. Configurar su contraseña sa debe crear un archivo llamado **db.env** donde ***solo coloque la contraseña en texto plano***.
4. Crear la docker images de la API con su IDE o terminal con gradlew. _TODO update this with quarkus_
   ```bash
   ./gradlew clean
   ```
   Este proceso puede demorar un poco la primera vez, se recomienda el flag skip tests para disminuir el tiempo de
   espera.
5. Por último para JWT_EXPIRATION_TIME, JWT_REFRESH_TIME, JWT_ISSUER puede personalizarlo a su gusto.

> [!TIP]
> En resumen debe crear el certificado RSA para JWT (1), contraseña para sa de la base de datos (3).
> El resto de variables tienen valores por defectos para utilizar la API fuera de docker.

### 4. Levantar todos los contenedores:

``` bash
docker compose up -d
```

### 5. Verificación

Con un cliente como [Postman](https://www.postman.com/) puede probar los endpoint con http://localhost:8080

Observación: Si cambia el puerto que se expone en docker-compose.yaml debe apuntar a este nuevo puerto.

> [!IMPORTANT]
> ¿Qué se espera de su configuración? Utilice docker secrets con los nombres dados.

Cualquier error verificar la versión del Java JDK 21, tu archivo .env o docker secrets configurados para cada servicio,
certificado RSA mínima 2056, la base de datos vacunas esté creada con éxito con todos sus objetos y con las credenciales
correctas, el login tiene su usuario con los permisos mínimos requeridos, la contraseña de sa es válida según los
requisitos mínimos de SQL Server y no contenga caracteres especiales (puede causar conflictos con los scripts de
configuración), ningún contenedor está en bucle de reinicio por errores, colocar gradle --debug y des
comentar el bloque de líneas relacionadas a logs en application.properties para encontrar cuál es el error si es el
contenedor de la API, eliminar el health_check en el service bd-vacunas y su dependencia en la API.

> [!NOTE]
> En docker compose utilizamos images latest en todos los servicios, Redis y RabbitMQ pueden cambiarse a su versión sin
> dashboard de manejo para reducir su tamaño y en entornos productivos.

# Comandos importantes

1. Cambiar jvm daemon de gradle:
    ```bash
   ./gradlew updateDaemonJvm --jvm-version=21 --jvm-vendor=graalvm
   ```
