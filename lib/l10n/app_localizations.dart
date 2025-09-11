import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ms', 'MY'),
    Locale('zh', 'CN'),
  ];
  
  // Translation maps
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'WMS Mechanic',
      'login': 'Login',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'loginError': 'Invalid email or password',
      'dashboard': 'Dashboard',
      'welcome': 'Welcome',
      'activeJobs': 'Active Jobs',
      'completedJobs': 'Completed Jobs',
      'pendingJobs': 'Pending Jobs',
      'allJobs': 'All Jobs',
      'taskManagement': 'Task Management',
      'addTask': 'Add Task',
      'tasks': 'Tasks',
      'pending': 'Pending',
      'inProgress': 'In Progress',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'allTasks': 'All Tasks',
      'profile': 'Profile',
      'editProfile': 'Edit Profile',
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'systemMode': 'System',
      'search': 'Search',
      'searchTasks': 'Search tasks...',
      'noResults': 'No results found',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'title': 'Title',
      'description': 'Description',
      'priority': 'Priority',
      'status': 'Status',
      'category': 'Category',
      'dueDate': 'Due Date',
      'location': 'Location',
      'notes': 'Notes',
      'detailsTab': 'Details',
      'timeTrackingTab': 'Time Tracking',
      'notesPhotosTab': 'Notes & Photos',
      'signOffTab': 'Sign Off',
      'jobTasks': 'Job Tasks',
      'tasksForThisJob': 'Tasks for this job',
      'manageTasksEfficiently': 'Manage your tasks efficiently',
      'noTasksForJob': 'No tasks found for this job',
      'addTasksToJob': 'Add tasks to this job to get started',
      'updateStatus': 'Update Status',
      'timeTracking': 'Time Tracking',
      'timeHistory': 'Time History',
      'noTimeEntries': 'No time entries recorded yet.',
      'pause': 'Pause',
      'start': 'Start',
      'stop': 'Stop',
      'addNote': 'Add Note',
      'enterNoteHere': 'Enter your note here...',
      'clear': 'Clear',
      'notesTitle': 'Notes',
      'noNotesYet': 'No notes added yet.',
      'photos': 'Photos',
      'capturePhoto': 'Capture Photo',
      'noPhotosYet': 'No photos captured yet.',
      'completionStatus': 'Completion Status',
      'markAsCompleted': 'Mark as Completed',
      'taskFinished': 'Task has been finished successfully',
      'qualityCheck': 'Quality Check',
      'allRequirementsMet': 'All requirements have been met',
      'digitalSignOff': 'Digital Sign-off',
      'customerSignature': 'Customer Signature',
      'signaturePadPlaceholder': 'Signature Pad (Implementation needed)',
      'taskNotFound': 'Task Not Found',
      'taskNotFoundMessage': 'Task not found',
      'errorLoadingTask': 'Error loading task',
      'statusUpdated': 'Task status updated',
      'priorityUpdated': 'Task priority updated',
      'low': 'Low',
      'medium': 'Medium',
      'high': 'High',
      'urgent': 'Urgent',
      'maintenance': 'Maintenance',
      'repair': 'Repair',
      'inspection': 'Inspection',
      'diagnostic': 'Diagnostic',
      'customerService': 'Customer Service',
      'administrative': 'Administrative',
      'other': 'Other',
      'noTasks': 'No tasks found',
      'noPendingTasks': 'No pending tasks',
      'noInProgressTasks': 'No tasks in progress',
      'noCompletedTasks': 'No completed tasks',
      'createFirstTask': 'Create your first task to get started',
      'taskAdded': 'Task added successfully',
      'taskUpdated': 'Task updated successfully',
      'taskDeleted': 'Task deleted successfully',
      'errorOccurred': 'An error occurred',
      'confirmDelete': 'Are you sure you want to delete this item?',
      'confirmLogout': 'Are you sure you want to logout?',
      // Profile & common
      'pleaseLoginToViewProfile': 'Please log in to view your profile',
      'goToLogin': 'Go to Login',
      'basicInformation': 'Basic Information',
      'professionalInformation': 'Professional Information',
      'name': 'Name',
      'phone': 'Phone',
      'address': 'Address',
      'dateOfBirth': 'Date of Birth',
      'employeeId': 'Employee ID',
      'department': 'Department',
      'position': 'Position',
      'hireDate': 'Hire Date',
      'preferencesTitle': 'Preferences',
      'notifications': 'Push Notifications',
      'autoSave': 'Auto Save',
      'chooseFromGallery': 'Choose from Gallery',
      'takePhoto': 'Take Photo',
      'removePhoto': 'Remove Photo',
      'resetProfile': 'Reset Profile',
      'resetProfileConfirm': 'Are you sure you want to reset your profile? This action cannot be undone.',
      'retry': 'Retry',
      'resetDatabase': 'Reset Database',
      'resetDatabaseDesc': 'This will recreate the database with the latest schema. All data will be lost and replaced with sample data. Use this if you encounter database errors.',
      'databaseResetSuccess': 'Database reset successfully!',
      'databaseResetFailed': 'Database reset failed',
      // Tasks
      'editTaskPlaceholder': 'Edit task functionality would be implemented here',
      'taskStatusUpdatedTo': 'Task status updated to',
      'taskPriorityUpdatedTo': 'Task priority updated to',
      'deleteTask': 'Delete Task',
      // Task details labels
      'estimatedDuration': 'Estimated Duration',
      'tags': 'Tags',
      'running': 'Running',
      'stopped': 'Stopped',
      'currentSession': 'Current Session',
      'totalTime': 'Total Time',
      'entries': 'Entries',
      'addManualEntry': 'Add Manual Entry',
      'noTimeEntriesYet': 'No time entries yet',
      'startTrackingOrAddManual': 'Start tracking time or add manual entries',
      'confirmedPhotos': 'Confirmed Photos',
      'pendingPhotos': 'Pending Photos',
      'confirmPhotos': 'Confirm Photos',
      'photoCapturedHint': 'Photo captured! Tap "Confirm Photos" to save.',
      'photoSelectedHint': 'Photo selected! Tap "Confirm Photos" to save.',
      'tapConfirmPhotosToSave': 'Tap "Confirm Photos" to save',
      'photosConfirmedSaved': 'Photos confirmed and saved successfully!',
      'qualityCheckNotesOptional': 'Quality Check Notes (Optional)',
      'completeQualityCheck': 'Complete Quality Check',
      'detailsButton': 'Details',
      'startTimeLabel': 'Start Time (HH:MM)',
    },
    'ms': {
      'appTitle': 'WMS Mekanik',
      'login': 'Log Masuk',
      'logout': 'Log Keluar',
      'email': 'E-mel',
      'password': 'Kata Laluan',
      'loginError': 'E-mel atau kata laluan tidak sah',
      'dashboard': 'Papan Pemuka',
      'welcome': 'Selamat Datang',
      'activeJobs': 'Kerja Aktif',
      'completedJobs': 'Kerja Selesai',
      'pendingJobs': 'Kerja Menunggu',
      'allJobs': 'Semua Kerja',
      'taskManagement': 'Pengurusan Tugas',
      'addTask': 'Tambah Tugas',
      'tasks': 'Tugas',
      'pending': 'Menunggu',
      'inProgress': 'Sedang Berjalan',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
      'allTasks': 'Semua Tugas',
      'profile': 'Profil',
      'editProfile': 'Edit Profil',
      'settings': 'Tetapan',
      'language': 'Bahasa',
      'theme': 'Tema',
      'lightMode': 'Mod Terang',
      'darkMode': 'Mod Gelap',
      'systemMode': 'Sistem',
      'search': 'Cari',
      'searchTasks': 'Cari tugas...',
      'noResults': 'Tiada hasil dijumpai',
      'save': 'Simpan',
      'cancel': 'Batal',
      'delete': 'Padam',
      'edit': 'Edit',
      'add': 'Tambah',
      'close': 'Tutup',
      'title': 'Tajuk',
      'description': 'Penerangan',
      'priority': 'Keutamaan',
      'status': 'Status',
      'category': 'Kategori',
      'dueDate': 'Tarikh Akhir',
      'location': 'Lokasi',
      'notes': 'Nota',
      'detailsTab': 'Butiran',
      'timeTrackingTab': 'Penjejakan Masa',
      'notesPhotosTab': 'Nota & Foto',
      'signOffTab': 'Tandatangan',
      'jobTasks': 'Tugas Kerja',
      'tasksForThisJob': 'Tugas untuk kerja ini',
      'manageTasksEfficiently': 'Urus tugas anda dengan cekap',
      'noTasksForJob': 'Tiada tugas untuk kerja ini',
      'addTasksToJob': 'Tambah tugas untuk memulakan',
      'updateStatus': 'Kemas Kini Status',
      'timeTracking': 'Penjejakan Masa',
      'timeHistory': 'Sejarah Masa',
      'noTimeEntries': 'Tiada rekod masa lagi.',
      'pause': 'Jeda',
      'start': 'Mula',
      'stop': 'Henti',
      'addNote': 'Tambah Nota',
      'enterNoteHere': 'Masukkan nota anda di sini...',
      'clear': 'Kosongkan',
      'notesTitle': 'Nota',
      'noNotesYet': 'Belum ada nota.',
      'photos': 'Foto',
      'capturePhoto': 'Ambil Foto',
      'noPhotosYet': 'Belum ada foto diambil.',
      'completionStatus': 'Status Penyempurnaan',
      'markAsCompleted': 'Tandakan sebagai Selesai',
      'taskFinished': 'Tugas telah selesai',
      'qualityCheck': 'Semakan Kualiti',
      'allRequirementsMet': 'Semua keperluan telah dipenuhi',
      'digitalSignOff': 'Tandatangan Digital',
      'customerSignature': 'Tandatangan Pelanggan',
      'signaturePadPlaceholder': 'Pad Tandatangan (Perlu dilaksana)',
      'taskNotFound': 'Tugas Tidak Dijumpai',
      'taskNotFoundMessage': 'Tugas tidak dijumpai',
      'errorLoadingTask': 'Ralat memuat tugas',
      'statusUpdated': 'Status tugas dikemas kini',
      'priorityUpdated': 'Keutamaan tugas dikemas kini',
      'low': 'Rendah',
      'medium': 'Sederhana',
      'high': 'Tinggi',
      'urgent': 'Mendesak',
      'maintenance': 'Penyelenggaraan',
      'repair': 'Pembaikan',
      'inspection': 'Pemeriksaan',
      'diagnostic': 'Diagnostik',
      'customerService': 'Perkhidmatan Pelanggan',
      'administrative': 'Pentadbiran',
      'other': 'Lain-lain',
      'noTasks': 'Tiada tugas dijumpai',
      'noPendingTasks': 'Tiada tugas menunggu',
      'noInProgressTasks': 'Tiada tugas sedang berjalan',
      'noCompletedTasks': 'Tiada tugas selesai',
      'createFirstTask': 'Cipta tugas pertama anda untuk bermula',
      'taskAdded': 'Tugas berjaya ditambah',
      'taskUpdated': 'Tugas berjaya dikemas kini',
      'taskDeleted': 'Tugas berjaya dipadam',
      'errorOccurred': 'Ralat telah berlaku',
      'confirmDelete': 'Adakah anda pasti mahu memadam item ini?',
      'confirmLogout': 'Adakah anda pasti mahu log keluar?',
      // Profile & common
      'pleaseLoginToViewProfile': 'Sila log masuk untuk melihat profil anda',
      'goToLogin': 'Pergi ke Log Masuk',
      'basicInformation': 'Maklumat Asas',
      'professionalInformation': 'Maklumat Profesional',
      'name': 'Nama',
      'phone': 'Telefon',
      'address': 'Alamat',
      'dateOfBirth': 'Tarikh Lahir',
      'employeeId': 'ID Pekerja',
      'department': 'Jabatan',
      'position': 'Jawatan',
      'hireDate': 'Tarikh Mula',
      'preferencesTitle': 'Keutamaan',
      'notifications': 'Pemberitahuan Tolak',
      'autoSave': 'Simpan Automatik',
      'chooseFromGallery': 'Pilih dari Galeri',
      'takePhoto': 'Ambil Foto',
      'removePhoto': 'Buang Foto',
      'resetProfile': 'Tetapkan Semula Profil',
      'resetProfileConfirm': 'Adakah anda pasti mahu menetapkan semula profil anda? Tindakan ini tidak boleh dibatalkan.',
      'retry': 'Cuba Lagi',
      'resetDatabase': 'Tetapkan Semula Pangkalan Data',
      'resetDatabaseDesc': 'Ini akan mencipta semula pangkalan data dengan skema terkini. Semua data akan hilang dan diganti dengan data sampel. Gunakan ini jika anda menghadapi ralat pangkalan data.',
      'databaseResetSuccess': 'Pangkalan data berjaya ditetapkan semula!',
      'databaseResetFailed': 'Tetapan semula pangkalan data gagal',
      // Tasks
      'editTaskPlaceholder': 'Fungsi sunting tugas akan dilaksanakan di sini',
      'taskStatusUpdatedTo': 'Status tugas dikemas kini kepada',
      'taskPriorityUpdatedTo': 'Keutamaan tugas dikemas kini kepada',
      'deleteTask': 'Padam Tugas',
      // Task details labels
      'estimatedDuration': 'Anggaran Tempoh',
      'tags': 'Tanda',
      'running': 'Berjalan',
      'stopped': 'Dihenti',
      'currentSession': 'Sesi Semasa',
      'totalTime': 'Jumlah Masa',
      'entries': 'Catatan',
      'addManualEntry': 'Tambah Catatan Manual',
      'noTimeEntriesYet': 'Belum ada rekod masa',
      'startTrackingOrAddManual': 'Mula jejaki masa atau tambah catatan manual',
      'confirmedPhotos': 'Foto Disahkan',
      'pendingPhotos': 'Foto Belum Disahkan',
      'confirmPhotos': 'Sahkan Foto',
      'photoCapturedHint': 'Foto diambil! Ketik "Sahkan Foto" untuk menyimpan.',
      'photoSelectedHint': 'Foto dipilih! Ketik "Sahkan Foto" untuk menyimpan.',
      'tapConfirmPhotosToSave': 'Ketik "Sahkan Foto" untuk menyimpan',
      'photosConfirmedSaved': 'Foto berjaya disahkan dan disimpan!',
      'qualityCheckNotesOptional': 'Catatan Semakan Kualiti (Pilihan)',
      'completeQualityCheck': 'Lengkapkan Semakan Kualiti',
      'detailsButton': 'Butiran',
      'startTimeLabel': 'Masa Mula (JJ:MM)',
    },
    'zh': {
      'appTitle': 'WMS 机械师',
      'login': '登录',
      'logout': '退出登录',
      'email': '电子邮件',
      'password': '密码',
      'loginError': '电子邮件或密码无效',
      'dashboard': '仪表板',
      'welcome': '欢迎',
      'activeJobs': '活跃工作',
      'completedJobs': '已完成工作',
      'pendingJobs': '待处理工作',
      'allJobs': '所有工作',
      'taskManagement': '任务管理',
      'addTask': '添加任务',
      'tasks': '任务',
      'pending': '待处理',
      'inProgress': '进行中',
      'completed': '已完成',
      'cancelled': '已取消',
      'allTasks': '所有任务',
      'profile': '个人资料',
      'editProfile': '编辑个人资料',
      'settings': '设置',
      'language': '语言',
      'theme': '主题',
      'lightMode': '浅色模式',
      'darkMode': '深色模式',
      'systemMode': '系统',
      'search': '搜索',
      'searchTasks': '搜索任务...',
      'noResults': '未找到结果',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'edit': '编辑',
      'add': '添加',
      'close': '关闭',
      'title': '标题',
      'description': '描述',
      'priority': '优先级',
      'status': '状态',
      'category': '类别',
      'dueDate': '截止日期',
      'location': '位置',
      'notes': '备注',
      'detailsTab': '详情',
      'timeTrackingTab': '时间跟踪',
      'notesPhotosTab': '备注与照片',
      'signOffTab': '签署',
      'jobTasks': '工单任务',
      'tasksForThisJob': '该工单的任务',
      'manageTasksEfficiently': '高效管理您的任务',
      'noTasksForJob': '该工单没有任务',
      'addTasksToJob': '添加任务以开始',
      'updateStatus': '更新状态',
      'timeTracking': '时间跟踪',
      'timeHistory': '时间记录',
      'noTimeEntries': '尚无时间记录。',
      'pause': '暂停',
      'start': '开始',
      'stop': '停止',
      'addNote': '添加备注',
      'enterNoteHere': '在此输入备注...',
      'clear': '清空',
      'notesTitle': '备注',
      'noNotesYet': '尚未添加备注。',
      'photos': '照片',
      'capturePhoto': '拍照',
      'noPhotosYet': '尚未拍摄照片。',
      'completionStatus': '完成状态',
      'markAsCompleted': '标记为完成',
      'taskFinished': '任务已成功完成',
      'qualityCheck': '质量检查',
      'allRequirementsMet': '所有要求均已满足',
      'digitalSignOff': '电子签署',
      'customerSignature': '客户签名',
      'signaturePadPlaceholder': '签名板（待实现）',
      'taskNotFound': '未找到任务',
      'taskNotFoundMessage': '未找到任务',
      'errorLoadingTask': '加载任务出错',
      'statusUpdated': '任务状态已更新',
      'priorityUpdated': '任务优先级已更新',
      'low': '低',
      'medium': '中',
      'high': '高',
      'urgent': '紧急',
      'maintenance': '维护',
      'repair': '维修',
      'inspection': '检查',
      'diagnostic': '诊断',
      'customerService': '客户服务',
      'administrative': '行政',
      'other': '其他',
      'noTasks': '未找到任务',
      'noPendingTasks': '没有待处理任务',
      'noInProgressTasks': '没有进行中的任务',
      'noCompletedTasks': '没有已完成的任务',
      'createFirstTask': '创建您的第一个任务开始使用',
      'taskAdded': '任务添加成功',
      'taskUpdated': '任务更新成功',
      'taskDeleted': '任务删除成功',
      'errorOccurred': '发生错误',
      'confirmDelete': '您确定要删除此项目吗？',
      'confirmLogout': '您确定要退出登录吗？',
      // Profile & common
      'pleaseLoginToViewProfile': '请登录以查看您的个人资料',
      'goToLogin': '前往登录',
      'basicInformation': '基本信息',
      'professionalInformation': '职业信息',
      'name': '姓名',
      'phone': '电话',
      'address': '地址',
      'dateOfBirth': '出生日期',
      'employeeId': '员工编号',
      'department': '部门',
      'position': '职位',
      'hireDate': '入职日期',
      'preferencesTitle': '偏好设置',
      'notifications': '推送通知',
      'autoSave': '自动保存',
      'chooseFromGallery': '从相册选择',
      'takePhoto': '拍照',
      'removePhoto': '删除照片',
      'resetProfile': '重置个人资料',
      'resetProfileConfirm': '确定要重置您的个人资料吗？此操作无法撤销。',
      'retry': '重试',
      'resetDatabase': '重置数据库',
      'resetDatabaseDesc': '这将使用最新的结构重新创建数据库。所有数据将丢失并替换为示例数据。遇到数据库错误时使用。',
      'databaseResetSuccess': '数据库重置成功！',
      'databaseResetFailed': '数据库重置失败',
      // Tasks
      'editTaskPlaceholder': '此处将实现编辑任务功能',
      'taskStatusUpdatedTo': '任务状态更新为',
      'taskPriorityUpdatedTo': '任务优先级更新为',
      'deleteTask': '删除任务',
      // Task details labels
      'estimatedDuration': '预计时长',
      'tags': '标签',
      'running': '进行中',
      'stopped': '已停止',
      'currentSession': '当前会话',
      'totalTime': '总时长',
      'entries': '条目',
      'addManualEntry': '添加手动记录',
      'noTimeEntriesYet': '尚无时间记录',
      'startTrackingOrAddManual': '开始计时或添加手动记录',
      'confirmedPhotos': '已确认照片',
      'pendingPhotos': '待确认照片',
      'confirmPhotos': '确认照片',
      'photoCapturedHint': '已拍照！点击“确认照片”以保存。',
      'photoSelectedHint': '已选择照片！点击“确认照片”以保存。',
      'tapConfirmPhotosToSave': '点击“确认照片”以保存',
      'photosConfirmedSaved': '照片已确认并成功保存！',
      'qualityCheckNotesOptional': '质量检查备注（可选）',
      'completeQualityCheck': '完成质量检查',
      'detailsButton': '详情',
      'startTimeLabel': '开始时间（HH:MM）',
    },
  };
  
  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }
  
  // Convenience getters
  String get appTitle => translate('appTitle');
  String get login => translate('login');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get loginError => translate('loginError');
  String get dashboard => translate('dashboard');
  String get welcome => translate('welcome');
  String get activeJobs => translate('activeJobs');
  String get completedJobs => translate('completedJobs');
  String get pendingJobs => translate('pendingJobs');
  String get allJobs => translate('allJobs');
  String get taskManagement => translate('taskManagement');
  String get addTask => translate('addTask');
  String get tasks => translate('tasks');
  String get pending => translate('pending');
  String get inProgress => translate('inProgress');
  String get completed => translate('completed');
  String get allTasks => translate('allTasks');
  String get profile => translate('profile');
  String get editProfile => translate('editProfile');
  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get lightMode => translate('lightMode');
  String get darkMode => translate('darkMode');
  String get systemMode => translate('systemMode');
  String get search => translate('search');
  String get searchTasks => translate('searchTasks');
  String get noResults => translate('noResults');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get close => translate('close');
  String get title => translate('title');
  String get description => translate('description');
  String get priority => translate('priority');
  String get status => translate('status');
  String get category => translate('category');
  String get dueDate => translate('dueDate');
  String get location => translate('location');
  String get notes => translate('notes');
  String get low => translate('low');
  String get medium => translate('medium');
  String get high => translate('high');
  String get urgent => translate('urgent');
  String get maintenance => translate('maintenance');
  String get repair => translate('repair');
  String get inspection => translate('inspection');
  String get diagnostic => translate('diagnostic');
  String get customerService => translate('customerService');
  String get administrative => translate('administrative');
  String get other => translate('other');
  String get noTasks => translate('noTasks');
  String get noPendingTasks => translate('noPendingTasks');
  String get noInProgressTasks => translate('noInProgressTasks');
  String get noCompletedTasks => translate('noCompletedTasks');
  String get createFirstTask => translate('createFirstTask');
  String get taskAdded => translate('taskAdded');
  String get taskUpdated => translate('taskUpdated');
  String get taskDeleted => translate('taskDeleted');
  String get errorOccurred => translate('errorOccurred');
  String get confirmDelete => translate('confirmDelete');
  String get confirmLogout => translate('confirmLogout');
  String get pleaseLoginToViewProfile => translate('pleaseLoginToViewProfile');
  String get goToLogin => translate('goToLogin');
  String get basicInformation => translate('basicInformation');
  String get professionalInformation => translate('professionalInformation');
  String get name => translate('name');
  String get phone => translate('phone');
  String get address => translate('address');
  String get dateOfBirth => translate('dateOfBirth');
  String get employeeId => translate('employeeId');
  String get department => translate('department');
  String get position => translate('position');
  String get hireDate => translate('hireDate');
  String get preferencesTitle => translate('preferencesTitle');
  String get notifications => translate('notifications');
  String get autoSave => translate('autoSave');
  String get chooseFromGallery => translate('chooseFromGallery');
  String get takePhoto => translate('takePhoto');
  String get removePhoto => translate('removePhoto');
  String get resetProfile => translate('resetProfile');
  String get resetProfileConfirm => translate('resetProfileConfirm');
  String get retry => translate('retry');
  String get resetDatabase => translate('resetDatabase');
  String get resetDatabaseDesc => translate('resetDatabaseDesc');
  String get databaseResetSuccess => translate('databaseResetSuccess');
  String get databaseResetFailed => translate('databaseResetFailed');
  String get editTaskPlaceholder => translate('editTaskPlaceholder');
  String get taskStatusUpdatedTo => translate('taskStatusUpdatedTo');
  String get taskPriorityUpdatedTo => translate('taskPriorityUpdatedTo');
  String get deleteTask => translate('deleteTask');
  // Newly added convenience getters
  String get jobTasks => translate('jobTasks');
  String get tasksForThisJob => translate('tasksForThisJob');
  String get manageTasksEfficiently => translate('manageTasksEfficiently');
  String get noTasksForJob => translate('noTasksForJob');
  String get addTasksToJob => translate('addTasksToJob');
  String get detailsTab => translate('detailsTab');
  String get timeTrackingTab => translate('timeTrackingTab');
  String get notesPhotosTab => translate('notesPhotosTab');
  String get signOffTab => translate('signOffTab');
  String get cancelled => translate('cancelled');
  String get updateStatus => translate('updateStatus');
  String get timeTracking => translate('timeTracking');
  String get timeHistory => translate('timeHistory');
  String get noTimeEntries => translate('noTimeEntries');
  String get pause => translate('pause');
  String get start => translate('start');
  String get stop => translate('stop');
  String get addNote => translate('addNote');
  String get enterNoteHere => translate('enterNoteHere');
  String get clear => translate('clear');
  String get notesTitle => translate('notesTitle');
  String get noNotesYet => translate('noNotesYet');
  String get photos => translate('photos');
  String get capturePhoto => translate('capturePhoto');
  String get noPhotosYet => translate('noPhotosYet');
  String get completionStatus => translate('completionStatus');
  String get markAsCompleted => translate('markAsCompleted');
  String get taskFinished => translate('taskFinished');
  String get qualityCheck => translate('qualityCheck');
  String get allRequirementsMet => translate('allRequirementsMet');
  String get digitalSignOff => translate('digitalSignOff');
  String get customerSignature => translate('customerSignature');
  String get signaturePadPlaceholder => translate('signaturePadPlaceholder');
  String get taskNotFound => translate('taskNotFound');
  String get taskNotFoundMessage => translate('taskNotFoundMessage');
  String get statusUpdated => translate('statusUpdated');
  String get priorityUpdated => translate('priorityUpdated');
  // Task details extras
  String get estimatedDuration => translate('estimatedDuration');
  String get tags => translate('tags');
  String get running => translate('running');
  String get stopped => translate('stopped');
  String get currentSession => translate('currentSession');
  String get totalTime => translate('totalTime');
  String get entries => translate('entries');
  String get addManualEntry => translate('addManualEntry');
  String get noTimeEntriesYet => translate('noTimeEntriesYet');
  String get startTrackingOrAddManual => translate('startTrackingOrAddManual');
  String get confirmedPhotos => translate('confirmedPhotos');
  String get pendingPhotos => translate('pendingPhotos');
  String get confirmPhotos => translate('confirmPhotos');
  String get photoCapturedHint => translate('photoCapturedHint');
  String get photoSelectedHint => translate('photoSelectedHint');
  String get tapConfirmPhotosToSave => translate('tapConfirmPhotosToSave');
  String get photosConfirmedSaved => translate('photosConfirmedSaved');
  String get qualityCheckNotesOptional => translate('qualityCheckNotesOptional');
  String get completeQualityCheck => translate('completeQualityCheck');
  String get detailsButton => translate('detailsButton');
  String get startTimeLabel => translate('startTimeLabel');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ms', 'zh'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
