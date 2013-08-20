public with sharing class Controller_Preview {
    public String videoId {get; private set;}
            
    public Controller_Preview() {
        videoId = Apexpages.currentPage().getParameters().get('videoId');
    }
}