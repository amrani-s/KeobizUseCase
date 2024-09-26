public class AccountTriggerHandler implements TriggerHandler{   
    public void BeforeInsert(List<SObject> newItems){}
    public void BeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap) {
        
        // Itération sur chaque compte mis à jour
        for (Account acc : (List<Account>) newRecords) {
            // Vérifier si le statut de la mission est changé en "canceled"
            Account oldAcc = (Account)oldRecordMap.get(acc.Id);
            if (acc.MissionStatus__c == 'canceled' && oldAcc.MissionStatus__c != 'canceled') {
                // Mettre à jour la date d'annulation
                acc.MissionCanceledDate__c = Date.today();               
                
            }
        }
    }
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void AfterInsert(Map<Id, SObject> newItems) {}
    
    public void AfterUpdate(List<SObject> oldRecords, List<SObject> newRecords, Map<ID, SObject> oldRecordMap, Map<ID, SObject> newRecordMap) {
        
        
        List<Map<String, Object>> payloadList = new List<Map<String, Object>>(); 
        Set<Id> accountIdsForContactsQuery = new Set<Id>();
        List<AccountContactRelation__c> relations;
        List<AccountContactRelation__c> allAccRelatedtoThecontacts;
        Set<id> listContactToverify = new Set<id>();
        Set<Id> contactIdsToInactivate = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();        
        Map<id, List<AccountContactRelation__c>> contactWithRelatedAccounts = new Map<id, List<AccountContactRelation__c>>();
        String httpMethod = 'PATCH';
        // Paramètres de synchronisation stockés dans un CustomMetaData
        APIConfiguration__mdt  apiConfig = APIConfiguration__mdt.getInstance('APIConfiguration');
        
        
        
        
        // Sélectionner les comptes dont le statut a été changé en 'canceled'
        for (Account acc : (List<Account>) newRecords) {
            Account oldAcc = (Account)oldRecordMap.get(acc.Id);
            if (acc.MissionStatus__c == 'canceled' && oldAcc.MissionStatus__c != 'canceled') {
                accountIdsForContactsQuery.add(acc.id);
            }
        } 
        
        // Si des comptes ont été 'Canceled', on exécute la logique sinon on log un message indiquant : "Pas de modification en Canceled"
        if(!accountIdsForContactsQuery.isEmpty()){
            
            // Récupérer les relations entre les contacts et les comptes annulés
            relations = [SELECT Contact__c, Account__c, Account__r.MissionStatus__c 
                         FROM AccountContactRelation__c 
                         WHERE Account__c IN :accountIdsForContactsQuery];
            
            
            //Selectionner tout les les contact à verifier 
            if(!relations.isEmpty()){
                for (AccountContactRelation__c relation : relations) {
                    listContactToverify.add(relation.Contact__c);
                }
                
                
                
                // Récuprer toutes les relations en fonction des contacts à  mettre à jour
                allAccRelatedtoThecontacts = [SELECT Contact__c, Account__c, Account__r.MissionStatus__c 
                                              FROM AccountContactRelation__c 
                                              WHERE Contact__c IN :listContactToverify];
                
                
                
                
                // Création d'une Map pour lier les contacts avec les comptes associés grace à AccountContactRelation
                for (AccountContactRelation__c relation : allAccRelatedtoThecontacts) {
                    
                    if (relation.Contact__c != null) {
                        Id contactId = relation.Contact__c;
                        
                        
                        // Vérifiez si la clé existe déjà dans la Map, sinon l'initialiser
                        if (!contactWithRelatedAccounts.containsKey(contactId)) {
                            contactWithRelatedAccounts.put(contactId, new List<AccountContactRelation__c>());
                        }
                        
                        // Ajoutez AccountContactRelation à la liste associée à ce contact
                        contactWithRelatedAccounts.get(contactId).add(relation);
                    }
                }
                
                
                
                
                for (Id contactId : contactWithRelatedAccounts.keySet()) {
                    List<AccountContactRelation__c>  AccountContactRelationList = contactWithRelatedAccounts.get(contactId);
                    
                    // Variable pour vérifier si tous les comptes sont annulés
                    Boolean allAccountsCanceled = true; 
                    
                    for (AccountContactRelation__c accContList : AccountContactRelationList) {
                        // Vérifiez si le statut de mission du compte est 'canceled'
                        
                        if (accContList.Account__r != null && accContList.Account__r.MissionStatus__c != 'canceled') {
                            allAccountsCanceled = false; // Un compte n'est pas annulé
                            break; // Sortir de la boucle car on a trouvé un compte actif
                        }
                    }
                    
                    // Si tous les comptes sont annulés, ajoutez l'ID du contact au Set et à la liste pour traitement
                    if (allAccountsCanceled) {
                        contactIdsToInactivate.add(contactId);
                        Contact cont = new Contact(
                            Id = contactId, 
                            IsActive__c = false     
                        );
                        contactsToUpdate.add(cont);
                        
                        
                    }
                }
                
                
                
                
                // Effectuer l'update des contacts
                if (!contactsToUpdate.isEmpty()) {
                    try {
                        update contactsToUpdate; 
                        System.debug('Mise à jour réussie: ' + contactsToUpdate);
                    } catch (DmlException e) {
                        System.debug('Erreur lors de la mise à jour: ' + e.getMessage());
                    }
                } else {
                    System.debug('Pas de contact à mettre à jour');
                }
                
                
                
                // Itérer sur les IDs des contacts
                for (Id contactId : contactIdsToInactivate) {
                    // Créer un mappage pour chaque contact
                    Map<String, Object> contactData = new Map<String, Object>();
                    contactData.put('is_active', false); // Met à jour le statut d'activité
                    contactData.put('id', contactId); // Ajoute l'ID du contact
                    
                    
                    // Ajouter le mappage à la liste du payload
                    payloadList.add(contactData);
                }
                
                
                // Synchronisation avec l'API si la payloadLis n'est pas vide
                if (!payloadList.isEmpty()) {
                    
                    
                    
                    
                    ApiService apiJob = new ApiService(
                        apiConfig.Endpoint__c,
                        httpMethod,
                        payloadList,
                        apiConfig.AuthToken__c
                    );
                    
                    try {
                        System.enqueueJob(apiJob);
                    } catch (ApiNotFoundException e) {
                        System.debug('Erreur 404: ' + e.getMessage());
                        
                    } catch (ApiUnauthorizedException e) {
                        System.debug('Erreur 401: ' + e.getMessage());
                        
                    } catch (ApiBadRequestException e) {
                        System.debug('Erreur 400: ' + e.getMessage());
                        
                    } catch (Exception e) {
                        System.debug('Erreur inattendue: ' + e.getMessage());
                        
                    }
                }
                
            }else{
                System.debug('Pas de contact en relation avec ce compte');
            }
            
            
        }else{
            System.debug('Pas de modification en Canceled');
        }
        
    } 
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}