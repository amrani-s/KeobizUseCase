Composants Principaux : 

AccountTrigger : Ce trigger exécute la méthode Run de la classe TriggerDispatcher, qui gère les différentes phases (avant et après) de chaque événement.

TriggerDispatcher : Cette classe vérifie le type d'événement et appelle les méthodes appropriées du gestionnaire de trigger. Cela permet de centraliser la logique de gestion des triggers, garantissant une meilleure lisibilité et maintenabilité.

TriggerHandler Interface : Définit un ensemble de méthodes que toute classe de gestionnaire de trigger doit implémenter, assurant une structure cohérente pour le traitement des événements.

AccountTriggerHandler : Cette classe implémente l'interface TriggerHandler et contient la logique métier spécifique. Lors des mises à jour, elle vérifie si le statut de mission d'un compte a été modifié en "canceled" et met à jour la date d'annulation. De plus, elle gère la désactivation des contacts associés lorsque tous les comptes d'un contact sont annulés et déclenche une synchronisation via une API.

ApiService : Cette classe implémente l'interface Queueable pour permettre l'exécution d'appels API asynchrones. Elle construit et envoie des requêtes HTTP, tout en gérant les réponses et les erreurs potentielles de l'API avec des Custom Error Exceptions (ApiBadRequestException, ApiNotFoundException, ApiUnauthorizedException).

Note : Il faut créer un Custom Metadata pour gérer les éléments (endPoint, authToken) de synchronisation avec l’API. (On peut les coder directement en dur dans le code, mais ce n’est pas une bonne approche). Dans mon cas, le Custom Metadata est : APIConfiguration (il se trouve dans le fichier force-app/main/default/customMetadata/APIConfiguration.APIConfiguration.md-meta.xml).
