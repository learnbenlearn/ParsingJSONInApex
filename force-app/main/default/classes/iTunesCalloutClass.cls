public class iTunesCalloutClass {
    final static String baseEndpoint = 'https://itunes.apple.com/search?';
    
    public static void retrieveArtistSongs(String artistName) {
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        
        String urlEncodedArtistName = artistName.replace(' ', '+');
        
        request.setEndpoint(baseEndpoint + 'media=music&entity=musicTrack&term=' + urlEncodedArtistName + '&limit=25');
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            List<Object> trackList = (List<Object>) responseBodyMap.get('results');
            
            List<Map<String, Object>> trackListMap = new List<Map<String, Object>>();
            
            for(Object track : trackList) {
                trackListMap.add((Map<String, Object>) track);
            }
            
            List<Song__c> songs = new List<Song__c>();
            
            for(Map<String, Object> track : trackListMap) {
                songs.add(new Song__c(Song_Name__c=String.valueOf(track.get('trackName')), Artist__c=String.valueOf(track.get('artistName')), 
                                      Album__c=String.valueOf(track.get('collectionName')), Release_Date__c=Date.valueOf(String.valueOf(track.get('releaseDate')).substring(0, 10))));
            }
            
            insert songs;
        } else {
            throw new iTunesCalloutException(response.getStatusCode() + ': ' + response.getBody());
        }
    }
    
    public class iTunesCalloutException extends Exception{}
}