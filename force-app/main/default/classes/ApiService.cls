public class ApiService implements Queueable, Database.AllowsCallouts {
        
    private String endpoint;
    private String httpMethod;
    private List<Map<String, Object>> payload;
    private String authToken;
    
    // Constructeur pour initialiser les paramètres
    public ApiService(String endpoint, String httpMethod, List<Map<String, Object>> payload, String authToken) {
        this.endpoint = endpoint;
        this.httpMethod = httpMethod;
        this.payload = payload;
        this.authToken = authToken;
    }
    
    // Méthode exécutable pour l'appel de l'API
    public void execute(QueueableContext context) {
        if (!payload.isEmpty()) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod(httpMethod);
            request.setHeader('Authorization', authToken);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(JSON.serialize(payload));
            System.debug('le payload serializé : '+JSON.serialize(payload));
            
            HttpResponse response = http.send(request);
            // Gérer les réponses de l'API
            handleApiResponse(response);
        }
    }
    
    // Gestion des erreurs de l'API
    private void handleApiResponse(HttpResponse response) {
        Integer statusCode = response.getStatusCode();
        String responseBody = response.getBody(); 
        
        if (statusCode == 200) {
            System.debug('Contacts synchronisés avec succès');
        } else if (statusCode == 404) {
            throw new ApiNotFoundException('La ressource demandée n\'a pas été trouvée. Réponse API : '  + responseBody);
        } else if (statusCode == 401) {
            throw new ApiUnauthorizedException('Authorization échouée : token d\'auth non fourni ou invalide. Réponse API : ' + responseBody);
        } else if (statusCode == 400) {
            throw new ApiBadRequestException('Erreur dans les paramètres : le corps doit être un tableau d\'objets avec deux propriétés id:string et is_active:boolean. Réponse API : ' + responseBody);
        }
    }
    
    
    
    
    
    
}