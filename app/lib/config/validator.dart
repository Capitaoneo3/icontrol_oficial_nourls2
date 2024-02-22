import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';

import '../res/strings.dart';
import 'application_messages.dart';

class Validator {
  BuildContext context;

  Validator({Key? key, required this.context});

  /*
    * Is valid date and format
    *
    * Format: dd/MM/yyyy
    * valid:
    *   01/12/1996
    * invalid:
    *   01/13/1996
    *
    * Format: MM/dd/yyyy
    * valid:
    *  12/01/1996
    * invalid
    *  13/01/1996
    * */

  bool validateBirth(String date, String format) {
    int day = 1, month = 1, year = 2000;

    //Get separator data  10/10/2020, 2020-10-10, 10.10.2020
    String separator = RegExp("([-/.])").firstMatch(date)!.group(0)![0];

    //Split by separator [mm, dd, yyyy]
    var frSplit = format.split(separator);
    //Split by separtor [10, 10, 2020]
    var dtSplit = date.split(separator);

    for (int i = 0; i < frSplit.length; i++) {
      var frm = frSplit[i].toLowerCase();
      var vl = dtSplit[i];

      if (frm == "dd")
        day = int.parse(vl);
      else if (frm == "mm")
        month = int.parse(vl);
      else if (frm == "yyyy") year = int.parse(vl);
    }

    //First date check
    //The dart does not throw an exception for invalid date.
    var now = DateTime.now();

    var validDate = now.year - 120;

    if (month > 12 ||
        month < 1 ||
        day < 1 ||
        day > daysInMonth(month, year) ||
        year < validDate ||
        year > now.year ||
        (year == now.year && month > now.month) ||
        (year == now.year && month == now.month && day > now.day)) {
      ApplicationMessages(context: context).showMessage(Strings.birth_denied);
      return false;
    } else {
      return true;
    }
  }

  static int daysInMonth(int month, int year) {
    int days = 28 +
        (month + (month / 8).floor()) % 2 +
        2 % month +
        2 * (1 / month).floor();
    return (isLeapYear(year) && month == 2) ? 29 : days;
  }

  static bool isLeapYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);

  bool validateEmail(String email) {
    if (RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      return true;
    } else {
      ApplicationMessages(context: context).showMessage(Strings.email_denied);
      return false;
    }
  }

  bool validatePassword(String password) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z]).{8,}$');
    if (password.isEmpty) {
      ApplicationMessages(context: context)
          .showMessage(Strings.password_denied);
      return false;
    } else {
      if (!regex.hasMatch(password)) {
        ApplicationMessages(context: context)
            .showMessage(Strings.password_denied);
        return false;
      } else {
        return true;
      }
    }
  }

  bool validateCoPassword(String password, String coPassword) {
    if (password == coPassword) {
      return true;
    } else {
      ApplicationMessages(context: context)
          .showMessage(Strings.coPassword_denied);
      return false;
    }
  }

  bool validateCellphone(String cellphone) {
    if (cellphone.length > 13) {
      return true;
    } else {
      ApplicationMessages(context: context)
          .showMessage(Strings.cellphone_denied);
      return false;
    }
  }

  bool validateCPF(String cpf) {
    if (CPFValidator.isValid(cpf)) {
      return true;
    } else {
      ApplicationMessages(context: context).showMessage(Strings.cpf_denied);
      return false;
    }
  }

  bool validateCNPJ(String cnpj) {
    if (CNPJValidator.isValid(cnpj)) {
      return true;
    } else {
      ApplicationMessages(context: context).showMessage(Strings.cnpj_denied);
      return false;
    }
  }

  bool validateCEP(String cep) {
    if (cep.length > 8) {
      return true;
    } else {
      ApplicationMessages(context: context).showMessage(Strings.cep_denied);
      return false;
    }
  }

  bool validateGenericTextField(String text, String field) {
    if (text.isNotEmpty) {
      return true;
    } else {
      ApplicationMessages(context: context)
          .showMessage("Preencha o campo $field!");
      return false;
    }
  }
}
