class NumberToWords {
  static final List<String> _units = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];

  static final List<String> _tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];

  static String convert(double amount) {
    if (amount == 0) return "Zero";

    int integerPart = amount.floor();
    int decimalPart = ((amount - integerPart) * 100).round();

    String words = _convertIndian(integerPart);

    if (decimalPart > 0) {
      words += " and ${_convertIndian(decimalPart)} Cents";
    }

    return words;
  }

  static String _convertIndian(int n) {
    if (n < 0) return "Minus ${_convertIndian(-n)}";
    if (n < 20) return _units[n];
    if (n < 100) return "${_tens[n ~/ 10]} ${_units[n % 10]}".trim();
    if (n < 1000) {
      return "${_units[n ~/ 100]} Hundred ${_convertIndian(n % 100)}".trim();
    }
    if (n < 100000) {
      return "${_convertIndian(n ~/ 1000)} Thousand ${_convertIndian(n % 1000)}"
          .trim();
    }
    if (n < 10000000) {
      return "${_convertIndian(n ~/ 100000)} Lakh ${_convertIndian(n % 100000)}"
          .trim();
    }
    return "${_convertIndian(n ~/ 10000000)} Crore ${_convertIndian(n % 10000000)}"
        .trim();
  }

  static String formatAmount(dynamic number) {
    if (number == null) return "0";
    double num;
    if (number is int) {
      num = number.toDouble();
    } else if (number is double) {
      num = number;
    } else if (number is String) {
      num = double.tryParse(number) ?? 0;
    } else {
      return "0";
    }

    int integerPart = num.floor();
    // Use toStringAsFixed(2) to safely get decimal part without float precision issues
    String decimalPartStr = num.toStringAsFixed(2).split('.')[1];

    String result = _formatIndianInteger(integerPart);
    if (int.parse(decimalPartStr) > 0) {
      return "$result.$decimalPartStr";
    }
    return result;
  }

  static String _formatIndianInteger(int n) {
    String s = n.toString();
    if (s.length <= 3) return s;

    // Standard Regex for Indian Commas:
    // Last 3 digits, then every 2 digits.

    String result = "";
    String remaining = s;

    // Last 3 digits
    if (remaining.length > 3) {
      result = remaining.substring(remaining.length - 3);
      remaining = remaining.substring(0, remaining.length - 3);
    } else {
      return remaining;
    }

    while (remaining.length > 2) {
      result = "${remaining.substring(remaining.length - 2)},$result";
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      result = "$remaining,$result";
    }

    return result;
  }
}
