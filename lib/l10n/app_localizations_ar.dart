// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get enterEmail => 'أدخل البريد الإلكتروني';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get min6Chars => '6 أحرف على الأقل';

  @override
  String get accountCreatedVerifyEmail => 'تم إنشاء الحساب بنجاح. يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.';

  @override
  String get emailAlreadyInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جدًا.';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت.';

  @override
  String get registrationFailed => 'فشل إنشاء الحساب.';

  @override
  String get continueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String googleError(String error) {
    return 'خطأ في Google: $error';
  }

  @override
  String get verifyYourEmailFirst => 'أكد بريدك الإلكتروني أولاً';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get userDataNotFound => 'لم يتم العثور على بيانات المستخدم.';

  @override
  String get wrongPassword => 'كلمة المرور غير صحيحة';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟ ';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get passwordResetEmailSent => 'تم إرسال بريد إعادة تعيين كلمة المرور.';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get noUserFoundForEmail => 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';

  @override
  String get invalidEmailAddress => 'عنوان البريد الإلكتروني غير صالح';

  @override
  String get pleaseEnterYourEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get forgotPasswordTitle => 'نسيت كلمة المرور';

  @override
  String get enterEmailToResetPassword => 'أدخل بريدك الإلكتروني لإعادة تعيين كلمة المرور';

  @override
  String get verifyEmail => 'تأكيد البريد الإلكتروني';

  @override
  String get emailNotVerifiedYet => 'لم يتم تأكيد البريد الإلكتروني بعد.';

  @override
  String get verificationEmailSentSuccessfully => 'تم إرسال بريد التحقق بنجاح.';

  @override
  String get verificationEmailMessage => 'لقد أرسلنا رسالة تحقق إلى بريدك الإلكتروني.\nيرجى تأكيد بريدك الإلكتروني قبل المتابعة.';

  @override
  String get iveVerifiedMyEmail => 'لقد أكدت بريدي الإلكتروني';

  @override
  String get resendVerificationEmail => 'إعادة إرسال بريد التحقق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get or => 'أو';

  @override
  String get searchProducts => 'البحث عن المنتجات';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get categories => 'الفئات';

  @override
  String get all => 'الكل';

  @override
  String get bestSelling => 'الأكثر مبيعًا';

  @override
  String get smartphones => 'الهواتف الذكية';

  @override
  String get laptops => 'أجهزة الكمبيوتر المحمولة';

  @override
  String get tablets => 'الأجهزة اللوحية';

  @override
  String get smartwatches => 'الساعات الذكية';

  @override
  String get audio => 'الصوتيات';

  @override
  String get gaming => 'الألعاب';

  @override
  String get electronics => 'الإلكترونيات';

  @override
  String get homeAppliances => 'الأجهزة المنزلية';

  @override
  String get perfumes => 'العطور';

  @override
  String get beauty => 'الجمال';

  @override
  String get clothing => 'الملابس';

  @override
  String get shoes => 'الأحذية';

  @override
  String get bags => 'الحقائب';

  @override
  String get glasses => 'النظارات';

  @override
  String get watches => 'الساعات';

  @override
  String get jewelry => 'المجوهرات';

  @override
  String get sports => 'الرياضة';

  @override
  String get books => 'الكتب';

  @override
  String get toys => 'الألعاب';

  @override
  String get furniture => 'الأثاث';

  @override
  String get food => 'الطعام';

  @override
  String get health => 'الصحة';

  @override
  String get automotive => 'السيارات';

  @override
  String get other => 'أخرى';

  @override
  String get home => 'الرئيسية';

  @override
  String get cart => 'السلة';

  @override
  String get favorite => 'المفضلة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get rateThisProduct => 'قيّم هذا المنتج';

  @override
  String get tellUsAboutThisProduct => 'أخبرنا عن هذا المنتج...';

  @override
  String get reviewSubmittedSuccessfully => 'تم إرسال التقييم بنجاح';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get contactSupport => 'التواصل مع الدعم';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation => 'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteFailed => 'فشل الحذف';

  @override
  String get logoutFailed => 'فشل تسجيل الخروج';

  @override
  String get orderHistory => 'سجل الطلبات';

  @override
  String get noOrderYet => 'لا توجد طلبات حتى الآن';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get processing => 'قيد المعالجة';

  @override
  String get shipped => 'تم الشحن';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get cancelled => 'ملغاة';

  @override
  String get order => 'طلب';

  @override
  String get product => 'منتج';

  @override
  String get firstNameIsRequired => 'الاسم الأول مطلوب';

  @override
  String get firstNameMinLength => 'يجب أن يحتوي الاسم الأول على حرفين على الأقل';

  @override
  String get firstNameMaxLength => 'يجب ألا يتجاوز الاسم الأول 30 حرفًا';

  @override
  String get validFirstName => 'يرجى إدخال اسم أول صالح';

  @override
  String get lastNameIsRequired => 'اسم العائلة مطلوب';

  @override
  String get lastNameMinLength => 'يجب أن يحتوي اسم العائلة على حرفين على الأقل';

  @override
  String get lastNameMaxLength => 'يجب ألا يتجاوز اسم العائلة 30 حرفًا';

  @override
  String get validLastName => 'يرجى إدخال اسم عائلة صالح';

  @override
  String get phoneNumberRequired => 'رقم الهاتف (مطلوب)';

  @override
  String get pleaseEnterPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get countryRequired => 'الدولة (مطلوب)';

  @override
  String get countryIsRequired => 'الدولة مطلوبة';

  @override
  String get countryNameTooShort => 'اسم الدولة قصير جدًا';

  @override
  String get countryNameTooLong => 'اسم الدولة طويل جدًا';

  @override
  String get validCountryName => 'يرجى إدخال اسم دولة صالح';

  @override
  String get cityRequired => 'المدينة (مطلوب)';

  @override
  String get cityIsRequired => 'المدينة مطلوبة';

  @override
  String get cityNameTooShort => 'اسم المدينة قصير جدًا';

  @override
  String get validCityName => 'يرجى إدخال اسم مدينة صالح';

  @override
  String get streetAddressOptional => 'عنوان الشارع (اختياري)';

  @override
  String get additionalInformation => 'معلومات إضافية';

  @override
  String get subscribedStores => 'المتاجر المشتركة';

  @override
  String get unsubscribedStores => 'المتاجر غير المشتركة';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get clear => 'مسح';

  @override
  String get noProductFound => 'لم يتم العثور على أي منتج';

  @override
  String get tryAnotherKeyword => 'حاول البحث بكلمة مفتاحية أخرى.';

  @override
  String get noName => 'بدون اسم';

  @override
  String get pleaseLogin => 'يرجى تسجيل الدخول';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get orderId => 'رقم الطلب';

  @override
  String get status => 'الحالة';

  @override
  String get total => 'المجموع';

  @override
  String get date => 'التاريخ';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get profilePhoto => 'صورة الملف الشخصي';

  @override
  String get optional => 'اختياري';

  @override
  String get taxIncluded => 'الضريبة مشمولة';

  @override
  String get writeReview => 'كتابة تقييم';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String itemsLeftInStock(Object count) {
    return 'تبقى $count قطعة فقط في المخزون';
  }

  @override
  String get quantity => 'الكمية';

  @override
  String get description => 'الوصف';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح.';

  @override
  String get relatedProducts => 'منتجات ذات صلة';

  @override
  String get noRelatedProducts => 'لا توجد منتجات ذات صلة';

  @override
  String get customerReviews => 'تقييمات العملاء';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get noProducts => 'لا توجد منتجات';

  @override
  String get qty => 'الكمية';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get buyNow => 'اشترِ الآن';

  @override
  String get addedToCart => 'تمت الإضافة إلى السلة 🛒';

  @override
  String get unknown => 'غير معروف';

  @override
  String get reviews => 'المراجعات';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavoriteProducts => 'لا توجد منتجات مفضلة';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة ❤️';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get deliveryInformation => 'معلومات التوصيل';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get pleaseEnterYourFullName => 'يرجى إدخال اسمك الكامل';

  @override
  String get nameTooLong => 'الاسم طويل جدًا';

  @override
  String get pleaseEnterAValidName => 'يرجى إدخال اسم صالح';

  @override
  String get pleaseEnterYourFirstAndLastName => 'يرجى إدخال الاسم الأول واسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get address => 'العنوان';

  @override
  String get pleaseEnterYourAddress => 'يرجى إدخال عنوانك';

  @override
  String get pleaseEnterAMoreCompleteAddress => 'يرجى إدخال عنوان أكثر تفصيلًا';

  @override
  String get addressTooLong => 'العنوان طويل جدًا';

  @override
  String get pleaseEnterYourCity => 'يرجى إدخال مدينتك';

  @override
  String get cityNameTooLong => 'اسم المدينة طويل جدًا';

  @override
  String get pleaseEnterAValidCity => 'يرجى إدخال مدينة صالحة';

  @override
  String get saveYourInformation => 'حفظ معلوماتك';

  @override
  String get forFasterCheckoutNextTime => 'لتسريع إتمام الطلب في المرة القادمة';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashOnDelivery => 'الدفع عند الاستلام';

  @override
  String get payWhenYourOrderArrives => 'ادفع عند وصول طلبك';

  @override
  String get transferBeforeShipping => 'قم بالتحويل قبل الشحن';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get items => 'المنتجات';

  @override
  String get payment => 'الدفع';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get orderPlacedSuccessfully => 'تم تأكيد طلبك بنجاح 🎉';

  @override
  String get pleaseEnterYourPhoneNumber => 'يرجى إدخال رقم هاتفك';

  @override
  String get pleaseEnterAValidAddress => 'يرجى إدخال عنوان صالح';

  @override
  String get pleaseEnterYourCountry => 'يرجى إدخال بلدك';

  @override
  String get pleaseEnterAValidCountry => 'يرجى إدخال دولة صالحة';

  @override
  String get yourCartIsEmpty => 'سلة التسوق فارغة';

  @override
  String get selected => 'محدد';

  @override
  String get deselectAll => 'إلغاء تحديد الكل';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get pleaseSelectAtLeastOneProduct => 'يرجى تحديد منتج واحد على الأقل';

  @override
  String get bankTransfer => 'التحويل البنكي';

  @override
  String get unableToSelectImage => 'تعذر اختيار الصورة';

  @override
  String get noActiveBankAccountsAvailable => 'لا توجد حسابات بنكية نشطة متاحة';

  @override
  String get unableToLoadPaymentInformation => 'تعذر تحميل معلومات الدفع';

  @override
  String get copied => 'تم النسخ';

  @override
  String get copy => 'نسخ';

  @override
  String get transferYourOrderTotalToTheBankAccountBelow => 'قم بتحويل إجمالي طلبك إلى الحساب البنكي أدناه.';

  @override
  String get selectBankAccount => 'اختر الحساب البنكي';

  @override
  String get bankAccountDetails => 'تفاصيل الحساب البنكي';

  @override
  String get bank => 'البنك';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get paymentProof => 'إثبات الدفع';

  @override
  String get uploadTransferScreenshot => 'قم برفع صورة التحويل';

  @override
  String get tapToChooseAnImage => 'اضغط لاختيار صورة';

  @override
  String get paymentProofSelected => 'تم اختيار إثبات الدفع';

  @override
  String get afterCompletingTheTransfer => 'بعد إتمام التحويل، اضغط على \"لقد قمت بالتحويل\" لمتابعة إتمام طلبك.';

  @override
  String get bankTransferCurrentlyUnavailable => 'التحويل البنكي غير متاح حاليًا. يرجى اختيار طريقة دفع أخرى.';

  @override
  String get uploadFailed => 'فشل رفع الملف';

  @override
  String get iHaveTransferred => 'لقد قمت بالتحويل';

  @override
  String get userNotLoggedIn => 'المستخدم غير مسجل الدخول';

  @override
  String get language => 'اللغة';

  @override
  String get chooseYourPreferredLanguage => 'اختر لغتك المفضلة';

  @override
  String get chooseLanguageDescription => 'اختر اللغة التي تريد استخدامها في التطبيق.';

  @override
  String get english => 'الإنجليزية';

  @override
  String get unitedStates => 'الولايات المتحدة';

  @override
  String get french => 'الفرنسية';

  @override
  String get france => 'فرنسا';

  @override
  String get arabic => 'العربية';

  @override
  String get morocco => 'المغرب';

  @override
  String get systemDefault => 'لغة النظام';

  @override
  String get followDeviceLanguage => 'استخدام لغة الجهاز';

  @override
  String get languageSavedSuccessfully => 'تم حفظ اللغة بنجاح';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get manageNotificationsDescription => 'تحكم في كيفية تلقي التحديثات من التطبيق.';

  @override
  String get orderUpdates => 'تحديثات الطلبات';

  @override
  String get orderUpdatesDescription => 'تلقي تحديثات حول طلباتك.';

  @override
  String get offersDiscounts => 'العروض والتخفيضات';

  @override
  String get offersDiscountsDescription => 'احصل على إشعارات حول العروض الجديدة.';

  @override
  String get promotionsDescription => 'تلقي الإشعارات الترويجية.';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get emailNotificationsDescription => 'تلقي رسائل البريد الإلكتروني المهمة.';

  @override
  String get pushNotificationsFutureUpdate => 'ستتوفر الإشعارات الفورية باستخدام Firebase Cloud Messaging في تحديث قادم.';

  @override
  String get theme => 'المظهر';

  @override
  String get chooseYourPreferredTheme => 'اختر مظهرك المفضل';

  @override
  String get selectHowAppAppear => 'اختر الطريقة التي تريد أن يظهر بها التطبيق.';

  @override
  String get light => 'فاتح';

  @override
  String get alwaysUseLightMode => 'استخدام الوضع الفاتح دائمًا';

  @override
  String get dark => 'داكن';

  @override
  String get alwaysUseDarkMode => 'استخدام الوضع الداكن دائمًا';

  @override
  String get followDeviceSettings => 'اتباع إعدادات الجهاز';

  @override
  String get themeSavedSuccessfully => 'تم حفظ المظهر بنجاح';

  @override
  String get failedToSaveTheme => 'فشل حفظ المظهر';

  @override
  String get add => 'إضافة';

  @override
  String get orderStatusCannotBeChanged => 'لا يمكن تغيير حالة هذا الطلب.';

  @override
  String get users => 'المستخدمون';

  @override
  String get noUsersFound => 'لم يتم العثور على مستخدمين';

  @override
  String get noEmail => 'لا يوجد بريد إلكتروني';

  @override
  String deleteUserConfirmation(Object name) {
    return 'هل أنت متأكد أنك تريد حذف $name؟';
  }

  @override
  String get unableToLoadOrders => 'تعذر تحميل الطلبات.';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get userHasNoOrders => 'لم يقم هذا المستخدم بإجراء أي طلبات بعد.';

  @override
  String orderNumber(Object orderNumber) {
    return 'الطلب رقم $orderNumber';
  }

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get completed => 'مكتملة';

  @override
  String get usersOrders => 'طلبات المستخدم';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get dashboardSubtitle => 'إليك ما يحدث اليوم';

  @override
  String get recentOrders => 'الطلبات الأخيرة';

  @override
  String get noRecentOrders => 'لا توجد طلبات حديثة';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get average => 'المتوسط';

  @override
  String get account => 'الحساب';

  @override
  String get storeManagement => 'إدارة المتاجر';

  @override
  String get admin => 'مسؤول';

  @override
  String get user => 'مستخدم';

  @override
  String get noProductsAvailable => 'لا توجد منتجات متاحة';

  @override
  String get productDeleted => 'تم حذف المنتج';

  @override
  String get edit => 'تعديل';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get chooseNotifications => 'اختر الإشعارات التي تريد تلقيها.';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get turnAllNotificationsOnOrOff => 'تفعيل أو تعطيل جميع الإشعارات';

  @override
  String get newOrders => 'طلبات جديدة';

  @override
  String get receiveNotificationsForNewOrders => 'تلقي إشعارات عند وجود طلبات جديدة';

  @override
  String get newUsers => 'مستخدمون جدد';

  @override
  String get notifyWhenCustomerRegisters => 'إشعار عند تسجيل عميل جديد';

  @override
  String get lowStock => 'مخزون منخفض';

  @override
  String get alertWhenProductsRunningOut => 'تنبيه عندما توشك المنتجات على النفاد';

  @override
  String get promotions => 'العروض الترويجية';

  @override
  String get marketingPromotionalNotifications => 'إشعارات التسويق والعروض الترويجية';

  @override
  String get sound => 'الصوت';

  @override
  String get playSoundWhenReceivingNotifications => 'تشغيل صوت عند تلقي الإشعارات';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get vibrateWhenReceivingNotifications => 'الاهتزاز عند تلقي الإشعارات';

  @override
  String get markAllAsRead => 'تحديد الكل كمقروء';

  @override
  String get allNotificationsMarkedAsRead => 'تم تحديد جميع الإشعارات كمقروءة';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get newUser => 'مستخدم جديد';

  @override
  String get newProduct => 'منتج جديد';

  @override
  String get warning => 'تحذير';

  @override
  String get pleaseAddAtLeastOneImage => 'يرجى إضافة صورة واحدة على الأقل';

  @override
  String get productUpdatedSuccessfully => 'تم تحديث المنتج بنجاح';

  @override
  String get selectImages => 'اختيار الصور';

  @override
  String get replaceImage => 'استبدال الصورة';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get productName => 'اسم المنتج';

  @override
  String get enterProductName => 'أدخل اسم المنتج';

  @override
  String get nameIsTooShort => 'الاسم قصير جدًا';

  @override
  String get maximum25Characters => 'الحد الأقصى 25 حرفًا';

  @override
  String get nikeAirMaxHint => 'مثال: Nike Air Max';

  @override
  String get enterDescription => 'أدخل الوصف';

  @override
  String get descriptionIsTooShort => 'الوصف قصير جدًا';

  @override
  String get maximum80Characters => 'الحد الأقصى 80 حرفًا';

  @override
  String get price => 'السعر';

  @override
  String get enterPrice => 'أدخل السعر';

  @override
  String get invalidPrice => 'السعر غير صالح';

  @override
  String get priceMustBeGreaterThanZero => 'يجب أن يكون السعر أكبر من 0';

  @override
  String get maximumPrice => 'الحد الأقصى للسعر هو 99999.99';

  @override
  String get oldPrice => 'السعر القديم';

  @override
  String get invalidOldPrice => 'السعر القديم غير صالح';

  @override
  String get oldPriceMustBeGreaterThanZero => 'يجب أن يكون السعر القديم أكبر من 0';

  @override
  String get stock => 'المخزون';

  @override
  String get enterStockQuantity => 'أدخل كمية المخزون';

  @override
  String get invalidStock => 'المخزون غير صالح';

  @override
  String get stockCannotBeNegative => 'لا يمكن أن يكون المخزون سالبًا';

  @override
  String get maximumStock => 'الحد الأقصى للمخزون هو 999999';

  @override
  String get category => 'الفئة';

  @override
  String get pleaseSelectCategory => 'يرجى اختيار فئة';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get pleaseSelectBrand => 'يرجى اختيار علامة تجارية';

  @override
  String get updateProduct => 'تحديث المنتج';

  @override
  String get oldPriceHint => 'مثال: 129.99';

  @override
  String get stockHint => 'مثال: 25';

  @override
  String get accessories => 'الإكسسوارات';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get productNameHint => 'مثال: Nike Air Max';

  @override
  String get error => 'خطأ';

  @override
  String get priceHint => 'مثال: 99.99';

  @override
  String get shortDescriptionHint => 'وصف قصير...';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String get selectImage => 'اختيار صورة';

  @override
  String get pleaseSelectAnImage => 'يرجى اختيار صورة';

  @override
  String get productAddedSuccessfully => 'تمت إضافة المنتج بنجاح!';

  @override
  String get addProduct => 'إضافة منتج';

  @override
  String get editUser => 'تعديل المستخدم';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get shippingAddress => 'عنوان الشحن';

  @override
  String get country => 'الدولة';

  @override
  String get city => 'المدينة';

  @override
  String get streetAddress => 'عنوان الشارع';

  @override
  String get firstNameRequired => 'الاسم الأول مطلوب';

  @override
  String get lastNameRequired => 'اسم العائلة مطلوب';

  @override
  String get userUpdatedSuccessfully => 'تم تحديث المستخدم بنجاح';

  @override
  String failedToUpdateUser(Object error) {
    return 'فشل تحديث المستخدم: $error';
  }

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get usersDetails => 'تفاصيل المستخدم';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get totalOrders => 'إجمالي الطلبات';

  @override
  String get totalSpent => 'إجمالي الإنفاق';

  @override
  String get memberSince => 'عضو منذ';

  @override
  String get customerStatistics => 'إحصائيات العميل';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get viewOrders => 'عرض الطلبات';

  @override
  String get deleteUser => 'حذف المستخدم';

  @override
  String get areYouSureDeleteUser => 'هل أنت متأكد أنك تريد حذف هذا المستخدم؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get userDeletedSuccessfully => 'تم حذف المستخدم بنجاح';

  @override
  String get noUserFound => 'لم يتم العثور على مستخدم';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get administrator => 'مسؤول';

  @override
  String get menu => 'القائمة';

  @override
  String get orders => 'الطلبات';

  @override
  String get customers => 'العملاء';

  @override
  String get products => 'المنتجات';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get analytics => 'التحليلات';

  @override
  String get system => 'النظام';

  @override
  String get settings => 'الإعدادات';

  @override
  String get noOrders => 'لا توجد طلبات';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get customer => 'العميل';

  @override
  String get orderTotal => 'إجمالي الطلب';

  @override
  String get paymentInformation => 'معلومات الدفع';

  @override
  String get paymentProofUploaded => 'تم رفع إثبات الدفع';

  @override
  String get paymentProofNotUploaded => 'لم يتم رفع إثبات الدفع';

  @override
  String get viewPaymentProof => 'عرض إثبات الدفع';

  @override
  String get orderStatus => 'حالة الطلبات';

  @override
  String get orderUpdatedSuccessfully => 'تم تحديث الطلب بنجاح';

  @override
  String get editBankAccount => 'تعديل الحساب البنكي';

  @override
  String get addBankAccount => 'إضافة حساب بنكي';

  @override
  String get editBankInformation => 'تعديل المعلومات البنكية';

  @override
  String get bankInformation => 'المعلومات البنكية';

  @override
  String get updateBankAccountInfo => 'حدّث معلومات الحساب البنكي الذي يمكن للعملاء استخدامه للتحويلات البنكية.';

  @override
  String get addBankAccountInfo => 'أضف الحساب البنكي الذي يمكن للعملاء استخدامه للتحويلات البنكية.';

  @override
  String get bankName => 'اسم البنك';

  @override
  String get accountName => 'اسم صاحب الحساب';

  @override
  String get iban => 'IBAN';

  @override
  String get rib => 'RIB';

  @override
  String get swiftBic => 'SWIFT / BIC';

  @override
  String get phoneOptional => 'رقم الهاتف (اختياري)';

  @override
  String get customersCanUseAccount => 'يمكن للعملاء استخدام هذا الحساب للتحويلات البنكية.';

  @override
  String get bankAccountUpdatedSuccessfully => 'تم تحديث الحساب البنكي بنجاح';

  @override
  String get bankAccountAddedSuccessfully => 'تمت إضافة الحساب البنكي بنجاح';

  @override
  String get failedToUpdateBankAccount => 'فشل تحديث الحساب البنكي';

  @override
  String get failedToAddBankAccount => 'فشلت إضافة الحساب البنكي';

  @override
  String get updateBankAccount => 'تحديث الحساب البنكي';

  @override
  String get saveBankAccount => 'حفظ الحساب البنكي';

  @override
  String get bankNameRequired => 'اسم البنك مطلوب';

  @override
  String get enterValidBankName => 'أدخل اسم بنك صالحًا';

  @override
  String get accountNameRequired => 'اسم صاحب الحساب مطلوب';

  @override
  String get enterValidAccountName => 'أدخل اسم صاحب حساب صالحًا';

  @override
  String get ibanRequired => 'IBAN مطلوب';

  @override
  String get enterValidIban => 'أدخل IBAN صالحًا';

  @override
  String get invalidIbanLength => 'طول IBAN غير صالح';

  @override
  String get ribRequired => 'RIB مطلوب';

  @override
  String get ribExactly24Digits => 'يجب أن يحتوي RIB على 24 رقمًا بالضبط';

  @override
  String get enterValidSwiftBic => 'أدخل رمز SWIFT / BIC صالحًا';

  @override
  String get enterValidPhoneNumber => 'أدخل رقم هاتف صالحًا';

  @override
  String get enterValidEmailAddress => 'أدخل عنوان بريد إلكتروني صالحًا';

  @override
  String get paymentBanks => 'البنوك الخاصة بالدفع';

  @override
  String get bankAccountDisabled => 'تم تعطيل الحساب البنكي';

  @override
  String get bankAccountEnabled => 'تم تفعيل الحساب البنكي';

  @override
  String get unableToUpdateBankAccount => 'تعذر تحديث الحساب البنكي';

  @override
  String get deleteBankAccount => 'حذف الحساب البنكي';

  @override
  String deleteBankConfirmation(Object bankName) {
    return 'هل أنت متأكد من حذف \"$bankName\"؟\n\nلن يتمكن العملاء بعد ذلك من استخدام هذا الحساب للتحويلات البنكية.';
  }

  @override
  String get bankAccountDeleted => 'تم حذف الحساب البنكي';

  @override
  String get unableToDeleteBankAccount => 'تعذر حذف الحساب البنكي';

  @override
  String get unableToLoadPaymentBanks => 'تعذر تحميل الحسابات البنكية.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get noBankAccountsYet => 'لا توجد حسابات بنكية بعد';

  @override
  String get addBankAccountToEnableTransfers => 'أضف حسابًا بنكيًا لتفعيل الدفع عن طريق التحويل البنكي.';

  @override
  String get unnamedBank => 'بنك بدون اسم';

  @override
  String get accountNameNotProvided => 'اسم الحساب غير متوفر';

  @override
  String get bankOptions => 'خيارات الحساب';

  @override
  String get disable => 'تعطيل';

  @override
  String get enable => 'تفعيل';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get updateAdministratorPassword => 'قم بتحديث كلمة مرور المسؤول الخاصة بك.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get enterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get passwordMinLength => 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get confirmYourPassword => 'أكد كلمة المرور الخاصة بك';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get passwordTooWeak => 'كلمة المرور ضعيفة جدًا';

  @override
  String get tooManyAttempts => 'محاولات كثيرة جدًا. حاول مرة أخرى لاحقًا.';

  @override
  String get pleaseSignInAgain => 'يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get exportOrders => 'تصدير الطلبات';

  @override
  String get unableToLoadProfile => 'تعذر تحميل الملف الشخصي';

  @override
  String get updateYourAdministratorProfile => 'تحديث ملفك الشخصي كمسؤول';

  @override
  String get updateYourAccountPassword => 'تحديث كلمة مرور حسابك';

  @override
  String get application => 'التطبيق';

  @override
  String get manageNotificationSettings => 'إدارة إعدادات الإشعارات';

  @override
  String get administration => 'الإدارة';

  @override
  String get viewStoreAnalytics => 'عرض إحصائيات المتجر';

  @override
  String get manageProducts => 'إدارة المنتجات';

  @override
  String get addEditOrDeleteProducts => 'إضافة المنتجات أو تعديلها أو حذفها';

  @override
  String get manageOrders => 'إدارة الطلبات';

  @override
  String get trackAndUpdateOrders => 'تتبع الطلبات وتحديثها';

  @override
  String get manageUsers => 'إدارة المستخدمين';

  @override
  String get viewRegisteredCustomers => 'عرض العملاء المسجلين';

  @override
  String get exportAllOrders => 'تصدير جميع الطلبات';

  @override
  String get backupDatabase => 'نسخ احتياطي لقاعدة البيانات';

  @override
  String get createBackup => 'إنشاء نسخة احتياطية';

  @override
  String get manageBankTransferAccounts => 'إدارة حسابات التحويل البنكي';

  @override
  String get about => 'حول التطبيق';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get version101 => 'الإصدار 1.0.0';

  @override
  String get accountDeletedSuccessfully => 'تم حذف الحساب بنجاح';

  @override
  String get forSecurityReasonsSignInAgain => 'لأسباب أمنية، يرجى تسجيل الدخول مرة أخرى قبل حذف حسابك.';

  @override
  String get failedToDeleteAccount => 'فشل حذف الحساب';

  @override
  String get permanentlyDeleteAccountConfirmation => 'هل أنت متأكد أنك تريد حذف حسابك نهائيًا؟\n\nلا يمكن التراجع عن هذا الإجراء.';

  @override
  String get storePerformanceOverview => 'نظرة عامة على أداء المتجر';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get success => 'النجاح';

  @override
  String get businessOverview => 'نظرة عامة على النشاط التجاري';

  @override
  String get businessHealth => 'حالة النشاط التجاري';

  @override
  String get revenueGeneratedFromDeliveredOrders => 'الإيرادات الناتجة عن الطلبات التي تم توصيلها';

  @override
  String usersRegistered(int count) {
    return 'تم تسجيل $count مستخدم';
  }

  @override
  String productsAvailable(int count) {
    return '$count منتج متاح';
  }

  @override
  String ordersDeliveredSuccessfully(int count) {
    return 'تم توصيل $count طلب بنجاح';
  }

  @override
  String get logoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get pleaseSelectAtLeastOneCollection => 'يرجى اختيار مجموعة واحدة على الأقل';

  @override
  String get saveDatabaseBackup => 'حفظ نسخة احتياطية من قاعدة البيانات';

  @override
  String get backupCancelled => 'تم إلغاء النسخ الاحتياطي';

  @override
  String get databaseBackupSavedSuccessfully => 'تم حفظ النسخة الاحتياطية لقاعدة البيانات بنجاح';

  @override
  String backupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get selectDatabaseBackup => 'اختيار نسخة احتياطية من قاعدة البيانات';

  @override
  String get unableToReadSelectedFile => 'تعذر قراءة الملف المحدد';

  @override
  String get invalidBackupFile => 'ملف النسخة الاحتياطية غير صالح';

  @override
  String get restoreDatabase => 'هل تريد استعادة قاعدة البيانات؟';

  @override
  String get backupContains => 'تحتوي هذه النسخة الاحتياطية على:';

  @override
  String collectionsCount(int count) {
    return '$count مجموعات';
  }

  @override
  String documentsCount(int count) {
    return '$count مستندات';
  }

  @override
  String get existingDocumentsWillBeOverwritten => 'سيتم استبدال المستندات الموجودة التي تحمل نفس المعرّفات.';

  @override
  String get doYouWantToContinue => 'هل تريد المتابعة؟';

  @override
  String get restore => 'استعادة';

  @override
  String databaseRestoredSuccessfully(int count) {
    return 'اكتملت الاستعادة: تمت إضافة $count مستندات جديدة';
  }

  @override
  String restoreFailed(String error) {
    return 'فشل استعادة قاعدة البيانات: $error';
  }

  @override
  String get databaseBackup => 'نسخة احتياطية من قاعدة البيانات';

  @override
  String get createBackupDescription => 'أنشئ نسخة احتياطية من بيانات Firestore واحفظها كملف JSON.';

  @override
  String get selectData => 'اختيار البيانات';

  @override
  String get chooseCollectionsToInclude => 'اختر المجموعات التي تريد تضمينها.';

  @override
  String completedPercentage(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get creatingBackup => 'جارٍ إنشاء النسخة الاحتياطية...';

  @override
  String get restoreBackup => 'استعادة النسخة الاحتياطية';

  @override
  String get backupFirestoreOnly => 'تحتوي النسخة الاحتياطية على بيانات Firestore فقط. لا يتم تضمين صور المنتجات والملفات الشخصية المخزنة في Firebase Storage في نسخة JSON الاحتياطية هذه.';

  @override
  String get pleaseSelectProfilePicture => 'يرجى اختيار صورة للملف الشخصي';

  @override
  String get profilePhotoRequired => 'صورة الملف الشخصي *';

  @override
  String get changeProfilePhoto => 'تغيير صورة الملف الشخصي';

  @override
  String get enterAValidPhoneNumber => 'أدخل رقم هاتف صالحًا';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get productDeletedSuccessfully => 'تم حذف المنتج بنجاح';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get rating => 'التقييم';

  @override
  String get discount => 'الخصم';

  @override
  String get deleteProduct => 'حذف المنتج';

  @override
  String get deleteProductConfirmation => 'هل أنت متأكد أنك تريد حذف هذا المنتج؟';

  @override
  String get productOutOfStock => 'هذا المنتج غير متوفر في المخزون.';

  @override
  String onlyItemsAvailable(int stock) {
    return 'متوفر فقط $stock من هذا المنتج.';
  }

  @override
  String get alreadyInCart => 'هذا المنتج موجود بالفعل في سلة التسوق.';

  @override
  String get orderPlacedNotification => 'تم تقديم الطلب';

  @override
  String orderPlacedNotificationBody(Object orderNumber) {
    return 'تم تقديم طلبك $orderNumber بنجاح.';
  }

  @override
  String get orderUpdatedNotification => 'تم تحديث الطلب';

  @override
  String orderUpdatedNotificationBody(Object orderNumber, Object status) {
    return 'طلبك $orderNumber الآن $status.';
  }

  @override
  String get newProductNotification => 'منتج جديد';

  @override
  String newProductNotificationBody(Object productName) {
    return 'تمت إضافة منتج جديد: $productName.';
  }

  @override
  String get promotionNotification => 'عرض خاص';

  @override
  String promotionNotificationBody(Object productName) {
    return '$productName الآن في تخفيض!';
  }

  @override
  String get tapAgainToExit => 'اضغط مرة أخرى للخروج';

  @override
  String newOrderNotificationBody(Object userName, Object orderNumber) {
    return 'قام $userName بإنشاء الطلب $orderNumber';
  }

  @override
  String get enterStock => 'يرجى إدخال كمية المخزون.';

  @override
  String get createNewStoreForPlatform => 'أنشئ متجرًا جديدًا لمنصتك.';

  @override
  String get exampleMiloMall => 'مثال: Milo Mall';

  @override
  String get exampleMiloMallId => 'مثال: milo_mall';

  @override
  String get pleaseEnterStoreName => 'يرجى إدخال اسم المتجر.';

  @override
  String get storeNameTooShort => 'اسم المتجر قصير جدًا.';

  @override
  String get storeId => 'معرّف المتجر';

  @override
  String get pleaseEnterStoreId => 'يرجى إدخال معرّف المتجر.';

  @override
  String get storeIdTooShort => 'معرّف المتجر قصير جدًا.';

  @override
  String get storeIdCharactersError => 'استخدم فقط الأحرف الصغيرة والأرقام والرمز _.';

  @override
  String get storeActive => 'المتجر نشط';

  @override
  String get usersCanAccessStore => 'يمكن للمستخدمين الوصول إلى هذا المتجر.';

  @override
  String get usersCannotAccessStore => 'لا يمكن للمستخدمين الوصول إلى هذا المتجر.';

  @override
  String get storeIdAlreadyExists => 'معرّف المتجر هذا موجود بالفعل.';

  @override
  String get storeCreatedSuccessfully => 'تم إنشاء المتجر بنجاح.';

  @override
  String get createAdministrator => 'إنشاء مسؤول';

  @override
  String get createAdminAssignStore => 'أنشئ مسؤولًا وقم بتعيينه إلى متجر.';

  @override
  String get pleaseEnterFirstName => 'يرجى إدخال الاسم الأول.';

  @override
  String get pleaseEnterLastName => 'يرجى إدخال اسم العائلة.';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال البريد الإلكتروني.';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صالح.';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور.';

  @override
  String get passwordMinCharacters => 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get assignStore => 'تعيين متجر';

  @override
  String get unableToLoadStores => 'تعذر تحميل المتاجر.';

  @override
  String get noActiveStoresAvailable => 'لا توجد متاجر نشطة متاحة.';

  @override
  String get adminCreatedSuccessfully => 'تم إنشاء المسؤول بنجاح';

  @override
  String get failedToCreateAdmin => 'فشل إنشاء المسؤول.';

  @override
  String get stores => 'المتاجر';

  @override
  String get createStore => 'إنشاء متجر';

  @override
  String get noStoresYet => 'لا توجد متاجر بعد';

  @override
  String get superAdmin => 'المسؤول العام';

  @override
  String get platformOverview => 'نظرة عامة على المنصة';

  @override
  String get manageAllStoresAndAdmins => 'إدارة جميع المتاجر والمسؤولين.';

  @override
  String get management => 'الإدارة';

  @override
  String get manageStores => 'إدارة المتاجر';

  @override
  String get createEditManageAllStores => 'إنشاء وتعديل وإدارة جميع المتاجر.';

  @override
  String get manageAdmins => 'إدارة المسؤولين';

  @override
  String get createAdminsAndAssignStores => 'إنشاء المسؤولين وتعيينهم للمتاجر.';

  @override
  String get ordersCompleted => 'الطلبات المكتملة';

  @override
  String get admins => 'المسؤولون';

  @override
  String get createAdmin => 'إنشاء مسؤول';

  @override
  String get noAdminsYet => 'لا يوجد مسؤولون بعد';

  @override
  String get noStoreAssigned => 'لم يتم تعيين متجر';

  @override
  String get storeInformation => 'معلومات المتجر';

  @override
  String get storeName => 'اسم المتجر';

  @override
  String get pleaseSelectStore => 'يرجى اختيار متجر.';

  @override
  String get security => 'الأمان';

  @override
  String get passwordResetDescription => 'إرسال رابط لإعادة تعيين كلمة المرور إلى بريدك الإلكتروني.';

  @override
  String get appearance => 'المظهر';

  @override
  String get adminManagement => 'إدارة المسؤولين';

  @override
  String get platform => 'المنصة';

  @override
  String get aboutMiloMall => 'حول Milo Mall';

  @override
  String get saasMarketplacePlatform => 'منصة Milo Mall للتجارة الإلكترونية SaaS';

  @override
  String get emailVerified => 'البريد الإلكتروني موثّق';

  @override
  String get emailNotVerified => 'البريد الإلكتروني غير موثّق';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get close => 'إغلاق';

  @override
  String get editStore => 'تعديل المتجر';

  @override
  String get updateStoreInformation => 'قم بتحديث معلومات متجرك.';

  @override
  String get removeStoreLogo => 'إزالة شعار المتجر';

  @override
  String get storeUpdatedSuccessfully => 'تم تحديث المتجر بنجاح.';

  @override
  String get store => 'المتجر';

  @override
  String get editAdmin => 'تعديل المسؤول';

  @override
  String get since => 'منذ';

  @override
  String get adminInformation => 'معلومات المسؤول';

  @override
  String get updateAdminInformation => 'قم بتحديث معلومات المسؤول.';

  @override
  String get adminUpdatedSuccessfully => 'تم تحديث المسؤول بنجاح.';

  @override
  String get permissionDenied => 'ليس لديك صلاحية لتنفيذ هذا الإجراء.';

  @override
  String get adminOrStoreNotFound => 'لم يتم العثور على المسؤول أو المتجر.';

  @override
  String get emailAlreadyExists => 'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get storeInactive => 'المتجر المحدد غير نشط.';

  @override
  String get invalidAdminInformation => 'معلومات المسؤول غير صالحة.';

  @override
  String get adminUpdateSecurityInfo => 'تتم معالجة تغييرات المسؤول بشكل آمن عبر خدمة إدارة المنصة.';

  @override
  String get allStores => 'جميع المتاجر';

  @override
  String get allAdmins => 'جميع المسؤولين';

  @override
  String get totalStores => 'إجمالي المتاجر';

  @override
  String get activeStores => 'المتاجر النشطة';

  @override
  String get noStores => 'لم يتم العثور على متاجر';

  @override
  String get noAdmins => 'لم يتم العثور على مسؤولين';

  @override
  String get totalAdmins => 'إجمالي المسؤولين';

  @override
  String get computers => 'الحواسيب';

  @override
  String get fashion => 'الأزياء';

  @override
  String get lifestyle => 'نمط الحياة';

  @override
  String placedNewOrder(Object userName) {
    return 'قام $userName بوضع طلب جديد';
  }

  @override
  String get currencySymbol => 'د.م';

  @override
  String get whatsappNumber => 'رقم واتساب';

  @override
  String get enterWhatsappNumber => 'يرجى إدخال رقم واتساب';

  @override
  String get invalidWhatsappNumber => 'يرجى إدخال رقم واتساب صالح';

  @override
  String get accountInactive => 'حسابك غير نشط. يرجى التواصل مع مسؤول المتجر.';

  @override
  String get chooseYourStore => 'اختر متجرك';

  @override
  String get selectStoreToContinue => 'اختر متجرًا للمتابعة';

  @override
  String get noStoresAvailableAtMoment => 'لا توجد متاجر متاحة في الوقت الحالي.';

  @override
  String get oldPriceMustBeGreaterThanPrice => 'يجب أن يكون السعر القديم أكبر من السعر الحالي.';

  @override
  String get confirm => 'تأكيد';

  @override
  String get oldPriceMustBeHigher => 'يجب أن يكون السعر القديم أعلى من السعر الحالي';

  @override
  String get productRemovedByAdmin => 'هذا المنتج لم يعد متاحًا لأنه تم حذفه من طرف المسؤول.';

  @override
  String get subscriptionCenterTitle => 'مركز الاشتراكات';

  @override
  String get subscriptionCenterSubtitle => 'إدارة الاشتراكات الشهرية ومواعيد الأداء';

  @override
  String get subscriptionTotalStores => 'إجمالي المتاجر';

  @override
  String get subscriptionConfigured => 'تم إعدادها';

  @override
  String get subscriptionDueSoon => 'اقترب موعد الأداء';

  @override
  String get subscriptionOverdue => 'متأخر';

  @override
  String get subscriptionExpectedRevenue => 'الإيرادات الشهرية المتوقعة';

  @override
  String get subscriptionStoreSubscriptions => 'اشتراكات المتاجر';

  @override
  String get subscriptionFilterAll => 'الكل';

  @override
  String get subscriptionStatusActive => 'نشط';

  @override
  String get subscriptionStatusDueSoon => 'اقترب موعد الأداء';

  @override
  String get subscriptionStatusOverdue => 'متأخر';

  @override
  String get subscriptionStatusNotConfigured => 'غير مُعدّ';

  @override
  String get subscriptionNoStores => 'لا توجد متاجر تطابق هذا الفلتر.';

  @override
  String get subscriptionOverdueNote => 'الاشتراكات المتأخرة تعرض تنبيهاً فقط. تتم إدارة تفعيل المتاجر بشكل منفصل.';

  @override
  String get subscriptionManageTitle => 'إدارة الاشتراك';

  @override
  String get subscriptionMonthlyPrice => 'السعر الشهري (درهم)';

  @override
  String get subscriptionPriceHint => 'مثال: 150';

  @override
  String get subscriptionNextPayment => 'موعد الأداء القادم';

  @override
  String get subscriptionNotSet => 'غير محدد';

  @override
  String get subscriptionSaveNote => 'يتم حفظ معلومات الاشتراك فقط. لا يتم تسجيل أي أداء ولا يتم تعطيل المتجر.';

  @override
  String get subscriptionInvalidPrice => 'يرجى إدخال سعر شهري صالح.';

  @override
  String get subscriptionSelectPaymentDate => 'يرجى تحديد موعد الأداء القادم.';

  @override
  String get subscriptionSaving => 'جارٍ الحفظ...';

  @override
  String get subscriptionSave => 'حفظ الاشتراك';

  @override
  String get subscriptionStoreEnabled => 'المتجر مفعّل';

  @override
  String get subscriptionStoreDisabled => 'المتجر معطّل';

  @override
  String get subscriptionLoadError => 'تعذّر تحميل الاشتراكات.';

  @override
  String subscriptionUpdatedFor(String storeName) {
    return 'تم تحديث اشتراك $storeName.';
  }

  @override
  String subscriptionSaveError(String error) {
    return 'تعذّر حفظ الاشتراك: $error';
  }

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get accessDeniedSuperAdminOnly => 'تم رفض الوصول. هذه الصفحة مخصصة للمشرف الأعلى فقط.';

  @override
  String get selectAtLeastOneCollection => 'اختر مجموعة واحدة على الأقل لإنشاء النسخة الاحتياطية.';

  @override
  String get existingDocumentsKeptUnchanged => 'ستبقى المستندات الموجودة دون تغيير.';

  @override
  String get onlyNewDocumentsAdded => 'ستتم إضافة المستندات الجديدة فقط.';

  @override
  String restoreFinished(int added, int skipped) {
    return 'اكتملت الاستعادة: تمت إضافة $added مستندات وتجاوز $skipped مستندات.';
  }

  @override
  String get storeSubscriptionSignInAgain => 'يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get storeSubscriptionNoStore => 'لا يوجد متجر مرتبط بهذا الحساب.';

  @override
  String get storeSubscriptionStoreNotFound => 'لم يتم العثور على المتجر.';

  @override
  String get storeSubscriptionChooseFileType => 'اختر ملفًا بصيغة JPG أو PNG أو WEBP أو PDF.';

  @override
  String get storeSubscriptionFileTooLarge => 'يجب ألا يتجاوز حجم الملف 10 ميغابايت.';

  @override
  String get storeSubscriptionFileReadError => 'تعذرت قراءة الملف المحدد.';

  @override
  String storeSubscriptionFileSelectError(Object error) {
    return 'تعذر اختيار الملف: $error';
  }

  @override
  String get storeSubscriptionSelectDateAndProof => 'يرجى تحديد تاريخ التحويل وإرفاق إثبات الدفع أولًا.';

  @override
  String get storeSubscriptionFileUnavailable => 'الملف المحدد لم يعد متاحًا. يرجى اختياره مرة أخرى.';

  @override
  String get storeSubscriptionPriceNotConfigured => 'لم يتم إعداد سعر الاشتراك.';

  @override
  String get storeSubscriptionBankUnavailable => 'الحساب البنكي الخاص بالاشتراك غير متاح حاليًا.';

  @override
  String get storeSubscriptionPaymentSubmitted => 'تم إرسال إثبات الدفع. دفعتك في انتظار المراجعة.';

  @override
  String storeSubscriptionSubmitPaymentError(Object error) {
    return 'تعذر إرسال الدفع: $error';
  }

  @override
  String get storeSubscriptionTitle => 'الاشتراك والمدفوعات';

  @override
  String get storeSubscriptionYourSubscription => 'اشتراكك';

  @override
  String get storeSubscriptionPriceLabel => 'سعر الاشتراك';

  @override
  String get storeSubscriptionNextPaymentDate => 'تاريخ الدفع القادم';

  @override
  String get storeSubscriptionStatusLabel => 'حالة الاشتراك';

  @override
  String get storeSubscriptionBankTransfer => 'التحويل البنكي';

  @override
  String get storeSubscriptionBankUnavailableContact => 'التحويل البنكي غير متاح حاليًا. يرجى التواصل مع الدعم.';

  @override
  String get storeSubscriptionBankTransferDetails => 'بيانات التحويل البنكي';

  @override
  String get storeSubscriptionTransferInstructions => 'حوّل مبلغ الاشتراك إلى هذا الحساب.';

  @override
  String get storeSubscriptionBankName => 'اسم البنك';

  @override
  String get storeSubscriptionAccountHolder => 'صاحب الحساب';

  @override
  String get storeSubscriptionRib => 'رقم RIB';

  @override
  String get storeSubscriptionIban => 'رقم IBAN';

  @override
  String get storeSubscriptionSwiftBic => 'رمز SWIFT/BIC';

  @override
  String get storeSubscriptionSubmitProofTitle => 'إرسال إثبات الدفع';

  @override
  String get storeSubscriptionUploadReceiptSubtitle => 'ارفع إيصال التحويل البنكي للتحقق منه يدويًا.';

  @override
  String get storeSubscriptionTransferDate => 'تاريخ التحويل';

  @override
  String get storeSubscriptionTransactionReferenceOptional => 'مرجع المعاملة (اختياري)';

  @override
  String get storeSubscriptionTransactionReferenceHint => 'أدخل مرجع المعاملة البنكية';

  @override
  String get storeSubscriptionTransferReceiptRequired => 'إيصال التحويل *';

  @override
  String get storeSubscriptionChooseImageOrPdf => 'اختر صورة أو ملف PDF';

  @override
  String get storeSubscriptionAllowedFileTypes => 'JPG أو PNG أو WEBP أو PDF · الحد الأقصى 10 ميغابايت';

  @override
  String get storeSubscriptionBrowseFiles => 'استعراض الملفات';

  @override
  String get storeSubscriptionChangeFile => 'تغيير الملف';

  @override
  String get storeSubscriptionSubmitting => 'جارٍ الإرسال...';

  @override
  String get storeSubscriptionSubmitForVerification => 'إرسال للتحقق';

  @override
  String get storeSubscriptionManualVerificationNotice => 'إرسال إثبات الدفع لا يجدد اشتراكك تلقائيًا. يجب أن يتحقق مسؤول المنصة من عملية الدفع.';

  @override
  String get storeSubscriptionPaymentHistory => 'سجل المدفوعات';

  @override
  String get storeSubscriptionPaymentHistorySubtitle => 'تابع طلبات دفع اشتراكك.';

  @override
  String storeSubscriptionLoadHistoryError(Object error) {
    return 'تعذر تحميل سجل المدفوعات: $error';
  }

  @override
  String get storeSubscriptionNoPayments => 'لم يتم إرسال أي مدفوعات للاشتراك حتى الآن.';

  @override
  String get storeSubscriptionPaymentApproved => 'تمت الموافقة';

  @override
  String get storeSubscriptionPaymentRejected => 'مرفوض';

  @override
  String get storeSubscriptionPaymentPendingReview => 'في انتظار المراجعة';

  @override
  String get storeSubscriptionReference => 'المرجع';

  @override
  String get storeSubscriptionAdminNote => 'ملاحظة المسؤول';

  @override
  String storeSubscriptionLoadDetailsError(Object error) {
    return 'تعذر تحميل تفاصيل الاشتراك: $error';
  }

  @override
  String get storeSubscriptionLoadBankError => 'تعذر تحميل البيانات البنكية. يرجى التواصل مع الدعم.';

  @override
  String get storeSubscriptionManageTitle => 'إدارة اشتراكك';

  @override
  String get storeSubscriptionManageSubtitle => 'راجع باقتك، وحوّل المبلغ، وأرسل الإيصال للتحقق منه.';

  @override
  String get storeSubscriptionTryAgain => 'إعادة المحاولة';

  @override
  String get storeSubscriptionMonthlyPlan => 'شهري';

  @override
  String get reviewSubscriptionPayments => 'مراجعة مدفوعات الاشتراك';

  @override
  String get reviewSubscriptionPaymentsSubtitle => 'راجع التحويلات البنكية ووافق على المدفوعات أو ارفضها.';

  @override
  String get subscriptionPayments => 'مدفوعات الاشتراكات';

  @override
  String get subscriptionAndPayments => 'الاشتراك والمدفوعات';

  @override
  String get manageAllSubscriptions => 'إدارة جميع الاشتراكات';

  @override
  String get subscriptionPaymentPending => 'قيد الانتظار';

  @override
  String get subscriptionPaymentAll => 'الكل';

  @override
  String get subscriptionPaymentProof => 'إثبات الدفع';

  @override
  String get subscriptionPaymentNoProof => 'لم يتم تقديم إثبات الدفع.';

  @override
  String get subscriptionPaymentOpenUploadedFile => 'افتح الملف المرفوع باستخدام الرابط أدناه:';

  @override
  String subscriptionPaymentCouldNotOpenProof(Object error) {
    return 'تعذر فتح إثبات الدفع: $error';
  }

  @override
  String get subscriptionPaymentApproveTitle => 'الموافقة على الدفع';

  @override
  String get subscriptionPaymentRejectTitle => 'رفض الدفع';

  @override
  String get subscriptionPaymentRejectionReason => 'سبب الرفض *';

  @override
  String get subscriptionPaymentReviewNoteOptional => 'ملاحظة المراجعة (اختيارية)';

  @override
  String get subscriptionPaymentRequestMissing => 'طلب الدفع لم يعد موجودًا.';

  @override
  String get subscriptionPaymentMissingStoreId => 'طلب الدفع لا يحتوي على معرّف المتجر.';

  @override
  String get subscriptionPaymentStoreMissing => 'المتجر غير موجود.';

  @override
  String get subscriptionPaymentAlreadyReviewed => 'تمت مراجعة هذا الدفع بالفعل.';

  @override
  String get subscriptionPaymentApprovedUpdated => 'تمت الموافقة على الدفع وتحديث الاشتراك.';

  @override
  String get subscriptionPaymentRejectedMessage => 'تم رفض الدفع.';

  @override
  String subscriptionPaymentReviewError(Object error) {
    return 'تعذرت مراجعة الدفع: $error';
  }

  @override
  String get subscriptionPaymentBank => 'البنك';

  @override
  String get subscriptionPaymentTransferReference => 'مرجع التحويل';

  @override
  String get subscriptionPaymentTransferDate => 'تاريخ التحويل';

  @override
  String get subscriptionPaymentSubmitted => 'تاريخ الإرسال';

  @override
  String get subscriptionPaymentViewProof => 'عرض إثبات الدفع';

  @override
  String subscriptionPaymentLoadError(Object error) {
    return 'تعذر تحميل طلبات الدفع:\n$error';
  }

  @override
  String get subscriptionPaymentNoRequests => 'لم يتم العثور على طلبات دفع.';

  @override
  String get save => 'حفظ';

  @override
  String get activeBankDetailsVisibleToStoreAdmins => 'المعلومات البنكية المفعّلة ظاهرة لمسؤولي المتاجر.';

  @override
  String get paymentInstructions => 'تعليمات الدفع';

  @override
  String get subscriptionBankAccount => 'الحساب البنكي للاشتراك';

  @override
  String get couldNotLoadBankDetails => 'تعذر تحميل المعلومات البنكية';

  @override
  String get bankDetailsSavedSuccessfully => 'تم حفظ المعلومات البنكية بنجاح';

  @override
  String get storeCategories => 'فئات المتجر';

  @override
  String get selectStoreCategories => 'اختر الفئات المتاحة في هذا المتجر';

  @override
  String get androidPhones => 'هواتف أندرويد';

  @override
  String get iphones => 'هواتف آيفون';

  @override
  String get phoneAccessories => 'إكسسوارات الهواتف';

  @override
  String get desktopComputers => 'أجهزة الكمبيوتر المكتبية';

  @override
  String get computerAccessories => 'إكسسوارات الكمبيوتر';

  @override
  String get monitors => 'الشاشات';

  @override
  String get printers => 'الطابعات';

  @override
  String get televisions => 'أجهزة التلفاز';

  @override
  String get cameras => 'الكاميرات';

  @override
  String get smartHome => 'المنزل الذكي';

  @override
  String get electronicAccessories => 'الإكسسوارات الإلكترونية';

  @override
  String get women => 'النساء';

  @override
  String get men => 'الرجال';

  @override
  String get kids => 'الأطفال';

  @override
  String get unisex => 'للجنسين';

  @override
  String get sunglasses => 'النظارات الشمسية';

  @override
  String get wallets => 'المحافظ';

  @override
  String get skincare => 'العناية بالبشرة';

  @override
  String get makeup => 'المكياج';

  @override
  String get bodyCare => 'العناية بالجسم';

  @override
  String get hairCare => 'العناية بالشعر';

  @override
  String get livingRoom => 'غرفة المعيشة';

  @override
  String get bedroom => 'غرفة النوم';

  @override
  String get office => 'المكتب';

  @override
  String get kitchen => 'المطبخ';

  @override
  String get outdoorFurniture => 'أثاث خارجي';

  @override
  String get fitness => 'اللياقة البدنية';

  @override
  String get training => 'التدريب';

  @override
  String get sportswear => 'الملابس الرياضية';

  @override
  String get sportsEquipment => 'المعدات الرياضية';

  @override
  String get consoles => 'أجهزة الألعاب';

  @override
  String get games => 'الألعاب';

  @override
  String get gamingAccessories => 'إكسسوارات الألعاب';

  @override
  String get otherProducts => 'منتجات أخرى';

  @override
  String get gold => 'الذهب';

  @override
  String get silver => 'الفضة';

  @override
  String get rings => 'الخواتم';

  @override
  String get necklaces => 'القلادات';

  @override
  String get bracelets => 'الأساور';

  @override
  String get anklets => 'الخلاخل';

  @override
  String get earrings => 'الأقراط';

  @override
  String get goldChains => 'سلاسل الذهب';

  @override
  String get silverChains => 'سلاسل الفضة';

  @override
  String get pendants => 'الحُلي المعلّقة';

  @override
  String get goldSets => 'أطقم الذهب';

  @override
  String get silverSets => 'أطقم الفضة';

  @override
  String get crownsAndTiaras => 'التيجان والدِّيَم';

  @override
  String get otherGoldJewelry => 'مجوهرات ذهب أخرى';

  @override
  String get otherSilverJewelry => 'مجوهرات فضة أخرى';

  @override
  String get continueAsGuest => 'المتابعة كزائر';

  @override
  String get subcategory => 'الفئة الفرعية';

  @override
  String get pleaseSelectSubcategory => 'يرجى اختيار الفئة الفرعية';

  @override
  String get alreadyHaveAnAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get signIn => 'تسجيل الدخول';
}
