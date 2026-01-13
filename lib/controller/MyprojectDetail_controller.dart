
// ---------- Helper Classes ----------
import 'package:flutter/material.dart';

class DualEntryControllers {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  TextEditingController balanceController = TextEditingController();
  bool remembered = false;
}

class DualFieldControllers {
  TextEditingController mainKeyController = TextEditingController();
  List<DualEntryControllers> entries = [DualEntryControllers()];
}

class LabourEntryControllers {
  TextEditingController titleController = TextEditingController();
  TextEditingController amountPaidController = TextEditingController();
  bool remembered = false;
}

class LabourFieldControllers {
  TextEditingController mainKeyController = TextEditingController();
  List<LabourEntryControllers> entries = [LabourEntryControllers()];
}
