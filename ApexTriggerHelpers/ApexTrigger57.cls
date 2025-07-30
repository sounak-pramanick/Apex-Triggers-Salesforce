public class Product_TriggerHelper {
    public static void apexTrigger57(List<Product__c> newList) {
        for(Product__c prod : newList) {
            if(prod.Offer_Available__c && prod.Offer_Type__c == null) {
                prod.addError('You need to specify an offer type when offer is available');
            }
            else if(prod.Offer_Available__c && prod.Offer_Type__c == 'Flat' && prod.Flat_Discount__c == null) {
                prod.addError('Flat discount must be specified when offer type is flat');
            }
            else if(prod.Offer_Available__c && prod.Offer_Type__c == 'Percentage' && prod.Percentage_Discount__c == null) {
                prod.addError('Percentage discount must be specified when offer type is percentage');
            }
            else if(prod.Offer_Available__c && prod.Offer_Type__c == 'Flat') {
                prod.Offer_Price__c = prod.Original_Price__c - prod.Flat_Discount__c;
            }
            else if(prod.Offer_Available__c && prod.Offer_Type__c == 'Percentage') {
                prod.Offer_Price__c = ((100 - prod.Percentage_Discount__c) * prod.Original_Price__c) / 100;
            }
        }
    }
}