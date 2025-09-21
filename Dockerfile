# Étape 1 : Utiliser une image OpenJDK 11
FROM openjdk:11-jre-slim

# Étape 2 : Créer un dossier dans le conteneur
WORKDIR /app

# Étape 3 : Copier le .jar dans le conteneur
COPY target/demo-0.0.1-SNAPSHOT.jar app.jar

# Étape 4 : Exposer le port
EXPOSE 8080

# Étape 5 : Commande de démarrage
ENTRYPOINT ["java", "-jar", "app.jar"]