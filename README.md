La solution se repose sur le principe de 'trigger framework' pour créer une sorte de 'Trigger Factoy'  qui permet d'organiser et structurer la logique des triggers dans Salesforce. En séparant la logique métier de celle des déclencheurs, il favorise la lisibilité, maintenabilité, réutilisation et la modularité du code tout en mettant les Trigger Best Practice( un seul trigger par objet, code bulkifié...etc)

Composants Principaux : 

AccountTrigger : Ce trigger exécute la méthode Run de la classe TriggerDispatcher, qui gère les différentes phases (avant et après) de chaque événement.

TriggerDispatcher : Cette classe vérifie le type d'événement et appelle les méthodes appropriées du gestionnaire de trigger. Cela permet de centraliser la logique de gestion des triggers, garantissant une meilleure lisibilité et maintenabilité.

TriggerHandler Interface : Définit un ensemble de méthodes que toute classe de gestionnaire de trigger doit implémenter, assurant une structure cohérente pour le traitement des événements.

AccountTriggerHandler : Cette classe implémente l'interface TriggerHandler et contient la logique métier spécifique. Lors des mises à jour, elle vérifie si le statut de mission d'un compte a été modifié en "canceled" et met à jour la date d'annulation. De plus, elle gère la désactivation des contacts associés lorsque tous les comptes d'un contact sont annulés et déclenche une synchronisation via une API.

ApiService : Cette classe implémente l'interface Queueable pour permettre l'exécution d'appels API asynchrones. Elle construit et envoie des requêtes HTTP, tout en gérant les réponses et les erreurs potentielles de l'API avec des Custom Error Exceptions (ApiBadRequestException, ApiNotFoundException, ApiUnauthorizedException).

PayloadLogger : permet via sa méthode saveFailedPayload, de stocker dans Salesforce les payloads ayant échoué en raison d'erreurs API dans un objet personnalisé nommé FailedPayload__c. Elle enregistre le code et le message d'erreur, et il est ensuite possible de développer un batch qui s'exécute pour rejouer ces payloads échoués.

CheckRecursive :  permet de gérer la récursivité d'un trigger et peut être utilisé si besoin.

Note : 
- Il faut créer un Custom Metadata pour gérer les éléments (endPoint, authToken) de synchronisation avec l’API. (On peut les coder directement en dur dans le code, mais ce n’est pas une bonne approche). Dans mon cas, le Custom Metadata est : APIConfiguration (il se trouve dans le fichier force-app/main/default/customMetadata/APIConfiguration.APIConfiguration.md-meta.xml).
- Il faut créer un Custom Object FailedPayload__c pour stocker les payload echoués (force-app/main/default/objects/FailedPayload__c).
