import '../lib/utils/number_to_words.dart';

void main() {
  final testCases = [
    {
      "value": 46895680.0,
      "expectedWords":
          "Four Crore Sixty Eight Lakh Ninety Five Thousand Six Hundred Eighty",
      "expectedFormat": "4,68,95,680",
    },
    {
      "value": 2300000000.0,
      "expectedWords": "Two Hundred Thirty Crore",
      "expectedFormat": "2,30,00,00,000",
    },
    {
      "value": 436690000.0,
      "expectedWords": "Forty Three Crore Sixty Six Lakh Ninety Thousand",
      "expectedFormat": "43,66,90,000",
    },
    {
      "value": 437836690000.0,
      "expectedWords":
          "Forty Three Thousand Seven Hundred Eighty Three Crore Sixty Six Lakh Ninety Thousand",
      "expectedFormat": "43,783,66,90,000",
    },
    {
      "value": 20300000000000.0,
      // User said: "Twenty lakh thirty thousand crore"
      // 20,30,000 Crores?
      // 20,30,000,00,00,000
      // 2,03,000,00,00,000 (User's comma format)
      // 2,03,000 (2 Lakh 3 Thousand) Crores
      // Let's see what the code generates.
      "expectedWords": "Twenty Lakh Thirty Thousand Crore",
      "expectedFormat": "20,30,00,00,00,000",
    },
  ];

  print("\n--- Running Number Verification ---\n");

  for (var test in testCases) {
    double val = test['value'] as double;
    String words = NumberToWords.convert(val);
    String format = NumberToWords.formatAmount(val);

    print("Value: ${val.toStringAsFixed(0)}");
    print("Words: $words");
    print("Format: $format");
    print("--------------------------------------------------");
  }
}
