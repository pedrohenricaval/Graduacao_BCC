//Tirar getters
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.Scanner;
import java.util.stream.Collectors;

public class Main{

    // Construcao do tipo 
    public static class CountryData {
        private String country;
        private int confirmed;
        private int deaths;
        private int recovery;
        private int active;

        public CountryData(String country, int confirmed, int deaths, int recovery, int active) {
            this.country   = country;
            this.confirmed = confirmed;
            this.deaths    = deaths;
            this.recovery  = recovery;
            this.active    = active;
        }

        public String  getCountry()   { return country; }
        public int     getConfirmed() { return confirmed; }
        public int     getDeaths()    { return deaths; }
        public int     getRecovery()  { return recovery; }
        public int     getActive()    { return active; }
    }

    // Funcoes de parsing
    // Associa os dados da linha a CountryData
    private static CountryData parseLine(String str) {
        String[] campos = str.split(",");
        
        return new CountryData(
            campos[0],
            Integer.parseInt(campos[1]),
            Integer.parseInt(campos[2]),
            Integer.parseInt(campos[3]),
            Integer.parseInt(campos[4])
        );
    }

    // Le arq, faz o parsing e retorna em forma de lista
    public static List<CountryData> parseFile(String path) throws IOException {
        return Files.lines(Paths.get(path))
            .map(Main::parseLine)
            .collect(Collectors.toList());
    }

    // Funcoes auxiliares dos calculos  
    // Obtem lista dos maiores ativos
    public static List<CountryData> topActive(int n2, List<CountryData> countries) {
        return countries.stream()
            .sorted(Comparator.comparingInt(CountryData::getActive).reversed())
            .limit(n2)
            .collect(Collectors.toList());
    }

    // Obtem a lista dos menores confirmados
    public static List<CountryData> bottomConfirmed(int n3, List<CountryData> countries) {
        return countries.stream()
            .sorted(Comparator.comparingInt(CountryData::getConfirmed))
            .limit(n3)
            .collect(Collectors.toList());
    }

    // Funcoes dos calculos requeridos
    // Obtem a soma dos ativos de acordo com a condicao estipulada
    public static int sumActiveConfirmed(int n1, List<CountryData> countries) {
        return countries.stream()
            .filter(cd -> cd.getConfirmed() >= n1)
            .mapToInt(CountryData::getActive)
            .sum();
    }

    // Obtem a soma das mortes de acordo com as condicoes estipuladas
    public static int sumDeathConfirmed(int n2, int n3, List<CountryData> countries) {
        List<CountryData> top = topActive(n2, countries);
        List<CountryData> bottom = bottomConfirmed(n3, top);
        return bottom.stream()
            .mapToInt(CountryData::getDeaths)
            .sum();
    }

    // Obtem a lista de paises de acordo com as condicoes estipuladas
    public static List<CountryData> topConfirmed(int n4, List<CountryData> countries) {
        return countries.stream()
            .sorted(Comparator.comparingInt(CountryData::getConfirmed).reversed())
            .limit(n4)
            .sorted(Comparator.comparing(CountryData::getCountry))
            .collect(Collectors.toList());
    }

    public static void main(String[] args) {
        try {
          // Obtem lista formatada dos paises
          List<CountryData> countryDataList = parseFile("dados.csv");

          // Obtem numeros de controle
          Scanner sc = new Scanner(System.in);
          int n1 = sc.nextInt();
          int n2 = sc.nextInt();
          int n3 = sc.nextInt();
          int n4 = sc.nextInt();
          sc.close();

          // Prints de saida
          System.out.println(sumActiveConfirmed(n1, countryDataList));
          System.out.println(sumDeathConfirmed(n2, n3, countryDataList));
          topConfirmed(n4, countryDataList).stream()
              .map(CountryData::getCountry)
              .forEach(System.out::println);

        } catch (IOException e) {
            System.err.println("ERROR " + e.getMessage());
        }
    }
}
