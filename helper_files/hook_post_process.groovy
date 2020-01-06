// Library imports required for the normalisation
import java.text.Normalizer;
import java.text.Normalizer.Form;

if (transaction.question.form == "auto-completion") {
        transaction?.response?.resultPacket?.results.each() {
        // Do this for each result item

        // Create a normalised version of the name metadatafield that removes diacritics
        // This calls a Java function to normalize the name metadata field and write the normalised
        // version of the name into a new metadata field called nameNormalized
            it.metaData["nameNormalized"] = Normalizer.normalize(it.metaData["name"], Form.NFD).replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        }

        // read stop words into data model customData element
        //using $SEARCH_HOME for the path of the file
        //def stopFile = "${transaction.question.collection.configuration.searchHomeDir}\\share\\lang\\en_stopwords"
        // Linux
        def stop_file = "/opt/funnelback/share/lang/en_stopwords";
        // Windows
        // def stop_file = "c:\\funnelback\\share\\lang\\en_stopwords";
        def stop = new File(stop_file).readLines();
        transaction.response.customData["stopwords"] = stop
}
