# IC05 - Analyse exploratoire de données

Dans le cadre d'IC05, nous avons étés amenés à réaliser un projet qui explore l'analyse des données à partir d'un ensemble de fichiers de fact-checking provenant de différents sites, avec un focus sur Politifact. Ce projet inclut la création et le nettoyage d'une base de données, ainsi que la création d'un réseau basé sur ces données. Le réseau est interactif et permet de parcourir les informations dynamiquement.

## Technologies utilisées

- **Langages** : R, JavaScript
- **Visualisation et exploration des données** : Gephi

## Participants

Ce projet a été réalisé par les membres suivants :

- **Ambre Lallement**
- **Engel Calon**
- **Ismaël Driche**
- **Yassine Ouzzane**

## Dossiers du projet

### 1. **Dossier Politifact**

Le dossier **Politifact** contient l'ensemble des fichiers utilisés pour :

- Créer la base de données.
- Nettoyer les données.
- Préparer les données pour la création du réseau.

### 2. **Dossier Network**

Le dossier **Network** contient les fichiers permettant d'afficher et d'interagir avec le réseau d'informations créé à partir des données scrappées. Ce réseau est interactif et peut être exploré via une interface web.

#### Naviguer sur le graphe

Pour visualiser et explorer le réseau : 

1. **Cloner le dépôt** :

   ```bash
   git clone https://github.com/S4TxC/IC05.git

2. **Accéder au dossier network** :
    ```bash
    cd network

3. **Lancer le serveur en local** :
     ```bash
     python3 -m http.server 8000
     ```
     ou
     ```bash
     python -m SimpleHTTPServer 8000
     ```
     
4. **Accéder à l'application** : Depuis un navigateur, aller sur `http://localhost:8000`

### 3. Autres ressources

Ce projet inclut également des ressources provenant d'autres sites de fact-checking qui ont été scrappés, en plus de Politifact. Ces ressources n'ont pas pu être exploitées, notamment, en raison du faible nombre de données récupérés sur ces sites (Snopes, Check Your Fact) par rapport à Politifact.

---

# IC05 - Exploratory Data Analysis

As part of IC05, we were tasked with conducting a project that explores data analysis from a set of fact-checking files gathered from various websites, with a focus on Politifact. This project includes the creation and cleaning of a database, as well as the creation of a network based on this data. The network is interactive and allows for dynamic exploration of the information.

## Technologies Used

- **Languages**: R, JavaScript
- **Data Visualization and Exploration**: Gephi

## Participants

This project was completed by the following members:

- **Ambre Lallement**
- **Engel Calon**
- **Ismaël Driche**
- **Yassine Ouzzane**

## Project Folders

### 1. **Politifact Folder**

The **Politifact** folder contains all the files used for:

- Creating the database.
- Cleaning the data.
- Preparing the data for building the network.

### 2. **Network Folder**

The **Network** folder contains files that allow you to display and interact with the information network created from the scraped data. This network is interactive and can be explored through a web interface.

#### Navigating the Graph

To visualize and explore the network:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/S4TxC/IC05.git

2. **Navigate to the network folder:**
    ```bash
    cd network

3. **Start the server locally:**
     ```bash
     python3 -m http.server 8000
     ```
     or
     ```bash
     python -m SimpleHTTPServer 8000
     ```
     
4. **Access the application:**   From a browser, go to http://localhost:8000

### 3. Autres ressources

This project also includes resources from other fact-checking websites that were scraped, in addition to Politifact. These resources could not be fully utilized, primarily due to the low number of data retrieved from these sites (Snopes, Check Your Fact) compared to Politifact.
