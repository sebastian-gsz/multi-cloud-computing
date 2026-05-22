**``Cymbal banck workload identity federation``**

- El propósito de este proyecto es demostrar cómo configurar la federación de identidades de la carga de trabajo en Google Cloud Platform (GCP) para Cymbal Bank.
- Esto permite a las aplicaciones que se ejecutan fuera de GCP (por ejemplo, en AWS, Azure, o un entorno local) autenticarse de forma segura y acceder a los recursos de GCP sin necesidad de claves de cuentas de servicio.

- **``Componentes principales``**

    - **`iam.tf`**: Define los roles de IAM y las vinculaciones de políticas necesarias.
    - **`main.tf`**: Contiene la configuración principal del proveedor de Terraform y los recursos de Workload Identity Federation.
    - **`output.tf`**: Especifica los valores de salida que se pueden utilizar después de la implementación de Terraform.
    - **`providers.tf`**: Declara los proveedores de Terraform (por ejemplo, `google`) y sus configuraciones.
    - **`variables.tf`**: Almacena las variables de entrada para el proyecto de Terraform.
    - **`.github/workflows/deploy.yml`**: Un ejemplo de flujo de trabajo de GitHub Actions que podría utilizar la federación de identidades de la carga de trabajo para la implementación continua.

- **``Configuración``**

    - Antes de desplegar este proyecto, asegúrate de tener una cuenta de servicio de GCP con los permisos necesarios y Terraform instalado.
    - El archivo `variables.tf` debe ser configurado con los valores específicos de tu entorno.

- **``Despliegue``**

    - Inicializa Terraform en el directorio del proyecto: **`terraform init`**
    - Planifica los cambios para revisar lo que se va a desplegar: **`terraform plan`**
    - Aplica los cambios para crear los recursos de GCP: **`terraform apply`**

- **``Uso``**

    - Una vez desplegado, las aplicaciones externas pueden usar las credenciales de un proveedor de identidades configurado (como GitHub OIDC en el ejemplo de GitHub Actions) para asumir un rol de IAM en GCP y acceder a los recursos.
    - Consulta la documentación oficial de Google Cloud sobre la federación de identidades de la carga de trabajo para obtener instrucciones detalladas sobre la configuración del proveedor de identidades externo.

- **``CI/CD con github actions``**

    - **Estructura de archivos**: Se diseñó una estructura modular donde `main.tf` gestiona los recursos, `providers.tf` la conexión y `variables.tf` la lógica de entrada.
    - **Aislamiento de terraform.tfvars**: Este archivo contiene los valores reales de tus variables (IDs de proyecto, correos, etc.). Lo aislamos e ignoramos en `.gitignore` por dos razones críticas:
        - **Seguridad**: Evitar que datos sensibles o específicos del entorno se suban al repositorio público.
        - **Flexibilidad**: En local, Terraform lee este archivo automáticamente; en GitHub Actions, estos mismos valores se inyectan dinámicamente mediante Secretos.
    - **Sincronización**: El repositorio se subió vinculando la carpeta local con el remoto de GitHub mediante **`git remote add origin`**, permitiendo que cada **`git push`** dispare el ciclo de vida de la infraestructura.

    - **Creación de secretos en github**: Para que GitHub Actions pueda "hablar" con Google Cloud sin intervención humana, necesita conocer las variables de entorno de forma segura.
        - **Implementación**: Se crearon secretos en `settings > secrets and variables > actions`. Estos incluyen el `GCP_PROJECT_ID`, `GCP_PROJECT_NUMBER`, `ADMIN_USER` y `GCP_REGION`.
        - **Incorporación de workflows**: Creamos el archivo `.github/workflows/deploy.yml`. Su función es definir los pasos (`Steps`): Checkout del código, autenticación en GCP e inicio/aplicación de Terraform.
        - **Medidas de seguridad**: El uso de secretos garantiza que, aunque el código sea visible, las llaves y credenciales no lo sean. Además, al usar variables en el comando **`terraform apply -var="..."`**, forzamos a Terraform a usar los datos del entorno seguro de GitHub en lugar de archivos locales.

- **``Creacion de WIF en github action``**

    - En lugar de tener una "llave bajo el felpudo" (archivo JSON), configuramos una relación de confianza. GCP solo confía en GitHub cuando este demuestra que viene de un repositorio y una rama específica.
    - **Configuración en la interfaz web**:
        - **Pool de identidad**: El contenedor lógico de la conexión.
        - **Proveedor**: Define quién es el emisor (GitHub) y qué "reivindicaciones" (claims) aceptamos (como el `repository_id`).
        - **Mapeo de atributos**: Conecta campos de GitHub (como `assertion.repository`) con atributos de Google.
    - **Comandos cli y vinculación de sa**:
        - Para automatizar esto, ejecutamos comandos de `gcloud iam workload-identity-pools`. Lo más crítico fue el `binding` (vinculación):
            **`gcloud iam workload-identity-pools create "github-pool" \
    --location="global" \
    --description="Pool para GitHub Actions" \
    --display-name="GitHub Pool"`**
        - **Crear el proveedor de identidad (oidc)**:
            **`gcloud iam workload-identity-pools providers create-oidc "github-provider" \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --issuer-uri="https://token.actions.githubusercontent.com" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --display-name="GitHub Provider"`**
        - **Vincular la "service account" al repositorio**:
            **`gcloud iam service-accounts add-iam-policy-binding "sa-compute-terraform@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/sebastian-gsz/gitbook-cloud-computing"`**
        - Esto cierra el círculo: GitHub Actions recibe un token temporal, Google lo valida contra el Pool, y si coincide, le permite "suplantar" a la Service Account manual para crear la VM.
