public class PayloadLogger {
    
    // Méthode pour enregistrer le payload échoué
    
    public static void saveFailedPayload(String serializedPayload, String httpBody, integer statusCode) {
        // Remplire avec les donnée correspondantes
        Integer randomNumber = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000000);         
        FailedPayload__c failedPayload = new FailedPayload__c();
        failedPayload.Name = 'Payload_' + randomNumber;
        
        failedPayload.Payload__c = serializedPayload; // Stocker le payload en JSON
        failedPayload.ErrorMessage__c = httpBody;
        failedPayload.statusCode__c = statusCode;
        failedPayload.IsResolved__c = false;  // Indiquer que ce problème n'est pas encore résolu
        
        try {
            insert failedPayload;
            
            System.debug('failedPayload inseré');
        } catch (DmlException e) {
            // Gérer les erreurs de DML ici, si nécessaire
            System.debug('Une erreur DML lors de l\'insertion de payload est survenue : ' + e+ ' Voici le payload échoué : '+ serializedPayload);
        }
    }
}