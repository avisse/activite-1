
# Activité 1 – Automatisation du déploiement d’un cluster Kubernetes (EKS) + Service Serverless (Lambda)
##  Objectif
Déployer une infrastructure cloud automatisée avec :
- Un **cluster Kubernetes** (via AWS EKS)
- Un **service serverless** (via AWS Lambda)

---

##  Infrastructure utilisée

### 1. Cloud Provider
- **AWS (Amazon Web Services)**

### 2. Technologies & outils
- **Terraform** (Infrastructure as Code)
- **AWS EC2** (VM de travail)
- **AWS EKS** (Elastic Kubernetes Service)
- **AWS Lambda** (Java serverless function)
- **PowerShell** (connexion SSH)
- **Docker** (installé en prévision de l’activité 2)
---

##  Étapes réalisées

### 🔹 Étape 1 : Création de la machine de travail
- Création d'une instance EC2 (t2.micro, Free Tier)
- Connexion SSH via PowerShell avec clé `.pem`

### 🔹 Étape 2 : Installation des outils sur la VM
```bash
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker && sudo systemctl enable docker

# Installation de Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install terraform -y
```

---

### 🔹 Étape 3 : Fichiers Terraform créés

- `provider.tf` : configuration AWS
- `variables.tf` : définition des variables (nom du cluster, région…)
- `main.tf` : ressources complètes (VPC, subnets, EKS, node group…)
- `outputs.tf` : valeurs affichées en sortie

### 🔹 Étape 4 : Déploiement de l’infrastructure

```bash
terraform init
terraform plan
terraform apply
```

-Cluster EKS opérationnel  
-Node Group fonctionnel (IP publique activée)  
- IAM Role et VPC bien configurés

---

##  Problèmes rencontrés

| Problème | Solution |
|---------|----------|
| `CREATE_FAILED` sur Node Group | Ajout de `map_public_ip_on_launch = true` dans les subnets |
| Instances EC2 se relançaient automatiquement | Suppression manuelle des Node Groups et clusters dans EKS console |

---

##  Serverless Lambda (Java)

### Fonction Java développée :
```java
public class App implements RequestHandler<String, String> {
    @Override
    public String handleRequest(String input, Context context) {
        return "Bonjour depuis AWS Lambda, tu m’as dit : " + input;
    }
}
```

- Build avec Maven → `.jar`
- Compressé en `.zip`
- Déployé sur AWS Lambda (Java 11)
- Testé via AWS Console avec succès 

---

## Nettoyage effectué

- Suppression des Node Groups
- Suppression des clusters EKS
- Résiliation de l’EC2 inutilisée
- Aucune ressource active à la fin de l’activité (pas de facturation involontaire) meme si cela m'est arriver au finale ...

---

##  Résultat attendu
> Un cluster Kubernetes opérationnel déployé automatiquement via Terraform  
> Un service Lambda Java fonctionnel, testé via AWS Console

---

## Arborescence du projet (exemple)

```
infra/
├── provider.tf
├── variables.tf
├── main.tf
├── outputs.tf
hello-lambda/
├── pom.xml
├── src/
│   └── main/java/com/infoline/lambda/App.java
```

---


# Déploiement d'une fonction AWS Lambda en Java – Activité 1 (Partie 2)

##  Objectif

Dans cette deuxième partie de l’Activité Type 1, l’objectif était de déployer un **service serverless**, en l’occurrence une **fonction Lambda AWS écrite en Java**, compatible avec l’écosystème cloud mis en place précédemment.

j'ai choisi de rester dans la Free Tier AWS et d’effectuer toutes les manipulations à partir de notre **instance EC2**, accessible via **PowerShell en SSH**.

---

## Étapes techniques

### 1. Mise en place de l’environnement de développement Java

#### a. Mise à jour de la machine et installation de Java
j'aitout d’abord mis à jour notre instance EC2 et installé Java 8 (Amazon Corretto 8) :

```bash
sudo yum update -y
sudo amazon-linux-extras enable corretto8
sudo yum install -y java-1.8.0-amazon-corretto-devel
java -version
```

#### b. Installation de Maven
Maven est nécessaire pour compiler les projets Java. j'ai installé ensuite :

```bash
sudo yum install -y maven
mvn -version
```

---

### 2. Création et compilation du projet Lambda Java

#### a. Création du projet

j'ai créé un projet Java simple contenant un fichier `App.java` avec une méthode compatible AWS Lambda (interface `RequestHandler`). Exemple :

```java
public class App implements RequestHandler<Object, String> {
    public String handleRequest(Object input, Context context) {
        return "Hello from Lambda Java!";
    }
}
```

#### b. Configuration du pom.xml

j'ai configuré le fichier `pom.xml` pour inclure la dépendance AWS Lambda Java Core :

```xml
<dependency>
  <groupId>com.amazonaws</groupId>
  <artifactId>aws-lambda-java-core</artifactId>
  <version>1.2.1</version>
</dependency>
```

#### c. Problème rencontré

-Erreur de compilation avec Maven : `source release 5 is no longer supported`.  
 -Cause : la version de Java ciblée était obsolète.  
Solution : nous avons ajouté ceci dans le `pom.xml` pour forcer la version 1.8 :

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>3.8.1</version>
      <configuration>
        <source>1.8</source>
        <target>1.8</target>
      </configuration>
    </plugin>
  </plugins>
</build>
```

#### d. Compilation

```bash
mvn clean package
```

Résultat attendu : `BUILD SUCCESS`

Le fichier généré : `target/hello-lambda-1.0-SNAPSHOT.jar`

---

### 3. Création de la fonction Lambda sur AWS

#### a. Accès au service Lambda via la Console AWS
- Aller dans le service “Lambda” via la Console AWS
- Cliquer sur **Créer une fonction**
- Choisir **Créer depuis zéro**
- Renseigner le nom
- Runtime : **Java 8 (Corretto)**
- Créer la fonction

#### b. Téléversement du .jar
- Dans l’onglet **Code**, uploader le fichier `.jar` compilé
- ( attention, pas un fichier `.zip` si non nécessaire)

#### c. Configuration du handler

Nous avons indiqué dans la configuration le **handler** au bon format :

```
package.App::handleRequest
```

Problème rencontré :
- Une erreur apparaissait car le handler n’était pas correctement référencé.
Solution : nous avons vérifié dans `App.java` le bon nom du package et corrigé le champ handler dans AWS.

---

## Conclusion

Avec cette deuxième partie :
- Nous avons préparé et compilé un projet Java Lambda sur notre VM EC2
- Nous avons envoyé le `.jar` sur AWS Lambda
- Nous avons vérifié que le handler était bien reconnu et fonctionnel
- je vous ai mis plusieurs captures d'écran ce qui vous permettra peut-être de mieux comprendre. l'environnement AWS c'était un peut compliqué, j'ai eu notamment des facturations; mais effectivement il y avait un script qui redéployait ou qui recréer et des EKS ou des nodes en continue

---

## Technologies utilisées

- AWS EC2
- AWS Lambda
- Java 1.8 (Amazon Corretto)
- Maven
- PowerShell (connexion SSH)
