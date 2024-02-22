
abstract class Links {

  //usuario

  static const String LOGIN = "usuarios/login/";
  static const String REGISTER_W_ADDRESS = "usuarios/cadastro/";
  static const String REGISTER_W_LOCATION = "usuarios/cadastroapp/";
  static const String VERIFY_PLAN = "usuarios/verificaPlano/";
  static const String LOAD_PLAN = "usuarios/planoUser/";
  static const String LIST_PLANS = "usuarios/listPlanos/";
  static const String LIST_HISTORY_USER_PLANS = "usuarios/planosHistorico/";
  static const String UPDATE_USER_DATA = "usuarios/updateUser/";
  static const String LOAD_PROFILE = "usuarios/perfil/";
  static const String UPDATE_AVATAR = "usuarios/updateavatar/";
  static const String UPDATE_PASSWORD = "usuarios/atualizar_senha/";
  static const String DISABLE_ACCOUNT = "usuarios/desativarconta/";
  static const String SAVE_FCM = "usuarios/savefcm/";
  static const String LIST_NOTIFICATIONS = "usuarios/notificacoes/";
  static const String RECOVER_PASSWORD_TOKEN = "usuarios/recuperarsenha/";
  static const String VERIFY_PASSWORD_TOKEN = "usuarios/verificatoken/";
  static const String UPDATE_PASSWORD_TOKEN = "usuarios/updatepasswordtoken/";
  static const String VERIFY_TWO_FACTORS = "usuarios/doisFatores/";
  static const String LOGIN_TWO_FACTORS = "usuarios/loginDoisFatores/";


  static const String UPDATE_ADDRESS = "usuarios/updateUserEnd/";

  //funcionarios

  static const String VERIFY_TOKEN_REGISTER = "usuarios/verificatokencadastro/";
  static const String LIST_EMPLOYEES = "usuarios/listaFuncionarios/";
  static const String LIST_ID_EMPLOYEE = "usuarios/listaFuncionariosId/";
  static const String UPDATE_STATUS_EMPLOYEE = "usuarios/updateStatusFuncionario/";
  static const String DELETE_EMPLOYEE = "usuarios/excluirFuncionario/";
  static const String EDIT_EMPLOYEE = "usuarios/editarFuncionario/";
  static const String SAVE_EMPLOYEE = "usuarios/saveFuncionario/";
  static const String LIST_EMPLOYEES_TOKEN = "usuarios/listaFuncionariosToken/";
  static const String REGISTER_EMPLOYEE = "usuarios/cadastroFuncionario/";

  //frotas

  static const String SAVE_FLEET = "usuarios/saveFrotas/";
  static const String UPDATE_FLEET = "usuarios/updateFrotas/";
  static const String LIST_FLEETS = "usuarios/listFrotas/";
  static const String DELETE_FLEET = "usuarios/excluirFrotas/";
  static const String UPDATE_SEQUENCE = "usuarios/updateOrdem/";

  //marcas

  static const String SAVE_BRAND = "usuarios/saveMarcas/";
  static const String UPDATE_BRAND = "usuarios/updateMarcas/";
  static const String LIST_BRANDS = "usuarios/listMarcas/";
  static const String DELETE_BRAND = "usuarios/excluirMarcas/";

  //modelos

  static const String SAVE_MODEL = "usuarios/saveModelos/";
  static const String UPDATE_MODEL = "usuarios/updateModelos/";
  static const String LIST_MODELS = "usuarios/listModelos/";
  static const String DELETE_MODEL = "usuarios/excluirModelos/";

  //equipamentos

  static const String SAVE_EQUIPMENT = "usuarios/saveEquipamentos/";
  static const String UPDATE_EQUIPMENT = "usuarios/updateEquipamentos/";
  static const String LIST_EQUIPMENTS = "usuarios/listEquipamentos/";
  static const String DELETE_EQUIPMENT = "usuarios/excluirEquipamentos/";

  //tarefas

  static const String SAVE_TASK = "usuarios/saveTarefas/";
  static const String UPDATE_TASK = "usuarios/updateTarefas/";
  static const String LIST_TASKS = "usuarios/listTarefas/";
  static const String LIST_ID_TASK = "usuarios/listTarefasId/";
  static const String DELETE_TASK = "usuarios/excluirTarefas/";
  static const String UPDATE_SEQUENCE_TASKS = "usuarios/updateOrdemTarefa/";
  static const String LIST_STATUS= "usuarios/listStatus/";

  //tarefa - funcionarios

  static const String SAVE_TASK_EMPLOYEE = "usuarios/saveTarefasFuncionarios/";
  static const String LIST_TASK_EMPLOYEE = "usuarios/listTarefasFuncionarios/";
  static const String LIST_TASK_EMPLOYEE_ALL = "usuarios/listTarefasFuncionariosAll/";
  static const String DELETE_TASK_EMPLOYEE = "usuarios/excluirTarefasFuncionarios/";


  //tarefa - comentarios

  static const String SAVE_TASK_COMMENT = "usuarios/saveTarefasComentarios/";
  static const String LIST_TASK_COMMENTS = "usuarios/listTarefasComentarios/";
  static const String UPDATE_TASK_COMMENT = "usuarios/updateTarefasComentarios/";
  static const String DELETE_TASK_COMMENT = "usuarios/excluirTarefasComentarios/";

  //tarefa - checklist

  static const String SAVE_TASK_CHECKLIST = "usuarios/saveTarefasChecklists/";
  static const String SAVE_TASK_CHECKLIST_ITEMS = "usuarios/saveTarefasChecklistsItens/";
  static const String LIST_TASK_CHECKLISTS = "usuarios/listTarefasChecklists/";
  static const String LIST_TASK_CHECKLIST_ITEMS = "usuarios/listTarefasChecklistsItens/";
  static const String CHECK_UNCHECK_ITEM = "usuarios/checkItem/";
  static const String UPDATE_TASK_CHECKLIST_ITEM = "usuarios/updateTarefasCheckItens/";
  static const String UPDATE_TASK_CHECKLIST = "usuarios/updateTarefasChecklists/";
  static const String DELETE_TASK_CHECKLIST = "usuarios/excluirTarefasChecklists/";
  static const String DELETE_TASK_CHECKLIST_ITEM  = "usuarios/excluirTarefasChecklistsItens/";

  //tarefa - anexos

  static const String SAVE_ATTACHMENT = "usuarios/saveAnexo/";
  static const String LIST_ATTACHMENTS = "usuarios/listAnexos/";
  static const String DELETE_ATTACHMENT = "usuarios/excluirAnexo/";

  //pagamentos

  static const String ADD_PAYMENT = "pagamentos/adicionar/";
  static const String LIST_PAYMENTS = "pagamentos/listar/";
  static const String CREATE_TOKEN_CARD = "pagamentos/criarTokenCartao/";


  //tarefa - anexos

  static const String SEARCH_INTERPRISES = "usuarios/buscarEmpresas/";
  static const String SEARCH_CITIES = "usuarios/buscarCidades/";
  static const String LIST_PARTNER_ID = "usuarios/listParceiroId/";

}