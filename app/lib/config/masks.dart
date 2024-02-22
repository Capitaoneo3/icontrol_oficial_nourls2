import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Masks {

  MaskTextInputFormatter birthMask() {
    return MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
  }

  MaskTextInputFormatter cepMask() {
    return MaskTextInputFormatter(
        mask: '#####-###',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
  }

  MaskTextInputFormatter cellphoneMask() {
    return MaskTextInputFormatter(
    mask: '(##)#####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy);
  }

  MaskTextInputFormatter cpfMask() {
    return MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
  }

  MaskTextInputFormatter cnpjMask() {
    return MaskTextInputFormatter(
        mask: '##.###.###/####-##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy);
  }


}