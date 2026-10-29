// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createAccount => 'Create Account';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get password => 'Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get min6Chars => 'Min 6 chars';

  @override
  String get accountCreatedVerifyEmail => 'Account created successfully. Please verify your email before logging in.';

  @override
  String get emailAlreadyInUse => 'This email is already in use.';

  @override
  String get weakPassword => 'Password is too weak.';

  @override
  String get noInternetConnection => 'No internet connection.';

  @override
  String get registrationFailed => 'Registration failed.';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String googleError(String error) {
    return 'Google error: $error';
  }

  @override
  String get verifyYourEmailFirst => 'Verify your email first';

  @override
  String get resend => 'Resend';

  @override
  String get userDataNotFound => 'User data not found.';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get login => 'Login';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account? ';

  @override
  String get register => 'Register';

  @override
  String get passwordResetEmailSent => 'Password reset email sent.';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get noUserFoundForEmail => 'No user found for this email';

  @override
  String get invalidEmailAddress => 'Invalid email address';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get enterEmailToResetPassword => 'Enter your email to reset your password';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get emailNotVerifiedYet => 'Email is not verified yet.';

  @override
  String get verificationEmailSentSuccessfully => 'Verification email sent successfully.';

  @override
  String get verificationEmailMessage => 'We\'ve sent a verification email to your inbox.\nPlease verify your email before continuing.';

  @override
  String get iveVerifiedMyEmail => 'I\'ve Verified My Email';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String get logout => 'Logout';

  @override
  String get or => 'OR';

  @override
  String get searchProducts => 'Search products';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get categories => 'Categories';

  @override
  String get all => 'All';

  @override
  String get bestSelling => 'Best Selling';

  @override
  String get smartphones => 'Smartphones';

  @override
  String get laptops => 'Laptops';

  @override
  String get tablets => 'Tablets';

  @override
  String get smartwatches => 'Smartwatches';

  @override
  String get audio => 'Audio';

  @override
  String get gaming => 'Gaming';

  @override
  String get electronics => 'Electronics';

  @override
  String get homeAppliances => 'Home Appliances';

  @override
  String get perfumes => 'Perfumes';

  @override
  String get beauty => 'Beauty';

  @override
  String get clothing => 'Clothing';

  @override
  String get shoes => 'Shoes';

  @override
  String get bags => 'Bags';

  @override
  String get glasses => 'Glasses';

  @override
  String get watches => 'Watches';

  @override
  String get jewelry => 'Jewelry';

  @override
  String get sports => 'Sports';

  @override
  String get books => 'Books';

  @override
  String get toys => 'Toys';

  @override
  String get furniture => 'Furniture';

  @override
  String get food => 'Food';

  @override
  String get health => 'Health';

  @override
  String get automotive => 'Automotive';

  @override
  String get other => 'Other';

  @override
  String get home => 'Home';

  @override
  String get cart => 'Cart';

  @override
  String get favorite => 'Favorite';

  @override
  String get profile => 'Profile';

  @override
  String get rateThisProduct => 'Rate this product';

  @override
  String get tellUsAboutThisProduct => 'Tell us about this product...';

  @override
  String get reviewSubmittedSuccessfully => 'Review submitted successfully';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get logoutFailed => 'Logout failed';

  @override
  String get orderHistory => 'Order History';

  @override
  String get noOrderYet => 'No order yet';

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing';

  @override
  String get shipped => 'Shipped';

  @override
  String get delivered => 'Delivered';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get order => 'Order';

  @override
  String get product => 'Product';

  @override
  String get firstNameIsRequired => 'First name is required';

  @override
  String get firstNameMinLength => 'First name must be at least 2 characters';

  @override
  String get firstNameMaxLength => 'First name must not exceed 30 characters';

  @override
  String get validFirstName => 'Please enter a valid first name';

  @override
  String get lastNameIsRequired => 'Last name is required';

  @override
  String get lastNameMinLength => 'Last name must be at least 2 characters';

  @override
  String get lastNameMaxLength => 'Last name must not exceed 30 characters';

  @override
  String get validLastName => 'Please enter a valid last name';

  @override
  String get phoneNumberRequired => 'Phone Number (Required)';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get countryRequired => 'Country (Required)';

  @override
  String get countryIsRequired => 'Country is required';

  @override
  String get countryNameTooShort => 'Country name is too short';

  @override
  String get countryNameTooLong => 'Country name is too long';

  @override
  String get validCountryName => 'Please enter a valid country name';

  @override
  String get cityRequired => 'City (Required)';

  @override
  String get cityIsRequired => 'City is required';

  @override
  String get cityNameTooShort => 'City name is too short';

  @override
  String get validCityName => 'Please enter a valid city name';

  @override
  String get streetAddressOptional => 'Street Address (Optional)';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get subscribedStores => 'Subscribed Stores';

  @override
  String get unsubscribedStores => 'Unsubscribed Stores';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get clear => 'Clear';

  @override
  String get noProductFound => 'No product found';

  @override
  String get tryAnotherKeyword => 'Try searching with another keyword.';

  @override
  String get noName => 'No name';

  @override
  String get pleaseLogin => 'Please login';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get orderId => 'Order ID';

  @override
  String get status => 'Status';

  @override
  String get total => 'Total';

  @override
  String get date => 'Date';

  @override
  String get productDetails => 'Product Details';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get optional => 'Optional';

  @override
  String get taxIncluded => 'Tax included';

  @override
  String get writeReview => 'Write Review';

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String itemsLeftInStock(Object count) {
    return 'Only $count items left in stock';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get description => 'Description';

  @override
  String get noDescriptionAvailable => 'No description available.';

  @override
  String get relatedProducts => 'Related Products';

  @override
  String get noRelatedProducts => 'No related products';

  @override
  String get customerReviews => 'Customer Reviews';

  @override
  String get noReviewsYet => 'No reviews yet';

  @override
  String get noProducts => 'No products';

  @override
  String get qty => 'Qty';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get addedToCart => 'Added to cart 🛒';

  @override
  String get unknown => 'Unknown';

  @override
  String get reviews => 'Reviews';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoriteProducts => 'No favorite products';

  @override
  String get removedFromFavorites => 'Removed from favorites ❤️';

  @override
  String get checkout => 'Checkout';

  @override
  String get deliveryInformation => 'Delivery Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterYourFullName => 'Please enter your full name';

  @override
  String get nameTooLong => 'Name is too long';

  @override
  String get pleaseEnterAValidName => 'Please enter a valid name';

  @override
  String get pleaseEnterYourFirstAndLastName => 'Please enter your first and last name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get pleaseEnterYourAddress => 'Please enter your address';

  @override
  String get pleaseEnterAMoreCompleteAddress => 'Please enter a more complete address';

  @override
  String get addressTooLong => 'Address is too long';

  @override
  String get pleaseEnterYourCity => 'Please enter your city';

  @override
  String get cityNameTooLong => 'City name is too long';

  @override
  String get pleaseEnterAValidCity => 'Please enter a valid city';

  @override
  String get saveYourInformation => 'Save your information';

  @override
  String get forFasterCheckoutNextTime => 'For faster checkout next time';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get payWhenYourOrderArrives => 'Pay when your order arrives';

  @override
  String get transferBeforeShipping => 'Transfer before shipping';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get items => 'Items';

  @override
  String get payment => 'Payment';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get orderPlacedSuccessfully => 'Order placed successfully 🎉';

  @override
  String get pleaseEnterYourPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterAValidAddress => 'Please enter a valid address';

  @override
  String get pleaseEnterYourCountry => 'Please enter your country';

  @override
  String get pleaseEnterAValidCountry => 'Please enter a valid country';

  @override
  String get yourCartIsEmpty => 'Your cart is empty';

  @override
  String get selected => 'Selected';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get selectAll => 'Select All';

  @override
  String get pleaseSelectAtLeastOneProduct => 'Please select at least one product';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get unableToSelectImage => 'Unable to select image';

  @override
  String get noActiveBankAccountsAvailable => 'No active bank accounts available';

  @override
  String get unableToLoadPaymentInformation => 'Unable to load payment information';

  @override
  String get copied => 'copied';

  @override
  String get copy => 'Copy';

  @override
  String get transferYourOrderTotalToTheBankAccountBelow => 'Transfer your order total to the bank account below.';

  @override
  String get selectBankAccount => 'Select Bank Account';

  @override
  String get bankAccountDetails => 'Bank Account Details';

  @override
  String get bank => 'Bank';

  @override
  String get email => 'Email';

  @override
  String get paymentProof => 'Payment Proof';

  @override
  String get uploadTransferScreenshot => 'Upload transfer screenshot';

  @override
  String get tapToChooseAnImage => 'Tap to choose an image';

  @override
  String get paymentProofSelected => 'Payment proof selected';

  @override
  String get afterCompletingTheTransfer => 'After completing the transfer, tap \"I Have Transferred\" to continue placing your order.';

  @override
  String get bankTransferCurrentlyUnavailable => 'Bank Transfer is currently unavailable. Please choose another payment method.';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get iHaveTransferred => 'I Have Transferred';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get language => 'Language';

  @override
  String get chooseYourPreferredLanguage => 'Choose your preferred language';

  @override
  String get chooseLanguageDescription => 'Choose the language you want to use in the app.';

  @override
  String get english => 'English';

  @override
  String get unitedStates => 'United States';

  @override
  String get french => 'Français';

  @override
  String get france => 'France';

  @override
  String get arabic => 'العربية';

  @override
  String get morocco => 'Morocco';

  @override
  String get systemDefault => 'System Default';

  @override
  String get followDeviceLanguage => 'Follow device language';

  @override
  String get languageSavedSuccessfully => 'Language saved successfully';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotificationsDescription => 'Manage how you receive updates from the app.';

  @override
  String get orderUpdates => 'Order Updates';

  @override
  String get orderUpdatesDescription => 'Receive updates about your orders.';

  @override
  String get offersDiscounts => 'Offers & Discounts';

  @override
  String get offersDiscountsDescription => 'Get notified about new deals.';

  @override
  String get promotionsDescription => 'Receive promotional notifications.';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsDescription => 'Receive important emails.';

  @override
  String get pushNotificationsFutureUpdate => 'Push notifications with Firebase Cloud Messaging will be available in a future update.';

  @override
  String get theme => 'Theme';

  @override
  String get chooseYourPreferredTheme => 'Choose your preferred theme';

  @override
  String get selectHowAppAppear => 'Select how you want the app to appear.';

  @override
  String get light => 'Light';

  @override
  String get alwaysUseLightMode => 'Always use light mode';

  @override
  String get dark => 'Dark';

  @override
  String get alwaysUseDarkMode => 'Always use dark mode';

  @override
  String get followDeviceSettings => 'Follow device settings';

  @override
  String get themeSavedSuccessfully => 'Theme saved successfully';

  @override
  String get failedToSaveTheme => 'Failed to save theme';

  @override
  String get add => 'Add';

  @override
  String get orderStatusCannotBeChanged => 'This order status cannot be changed.';

  @override
  String get users => 'Users';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get noEmail => 'No email';

  @override
  String deleteUserConfirmation(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get unableToLoadOrders => 'Unable to load orders.';

  @override
  String get noOrdersFound => 'No Orders Found';

  @override
  String get userHasNoOrders => 'This user hasn\'t placed any orders yet.';

  @override
  String orderNumber(Object orderNumber) {
    return 'Order #$orderNumber';
  }

  @override
  String get viewDetails => 'View Details';

  @override
  String get completed => 'Completed';

  @override
  String get usersOrders => 'User Orders';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get dashboardSubtitle => 'Here\'s what\'s happening today';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get noRecentOrders => 'No recent orders';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get average => 'Average';

  @override
  String get account => 'Account';

  @override
  String get storeManagement => 'Store Management';

  @override
  String get admin => 'Admin';

  @override
  String get user => 'User';

  @override
  String get noProductsAvailable => 'No products available';

  @override
  String get productDeleted => 'Product deleted';

  @override
  String get edit => 'Edit';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get chooseNotifications => 'Choose which notifications you want to receive.';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get turnAllNotificationsOnOrOff => 'Turn all notifications on or off';

  @override
  String get newOrders => 'New Orders';

  @override
  String get receiveNotificationsForNewOrders => 'Receive notifications for new orders';

  @override
  String get newUsers => 'New Users';

  @override
  String get notifyWhenCustomerRegisters => 'Notify when a customer registers';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get alertWhenProductsRunningOut => 'Alert when products are running out';

  @override
  String get promotions => 'Promotions';

  @override
  String get marketingPromotionalNotifications => 'Marketing & promotional notifications';

  @override
  String get sound => 'Sound';

  @override
  String get playSoundWhenReceivingNotifications => 'Play a sound when receiving notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateWhenReceivingNotifications => 'Vibrate when receiving notifications';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get allNotificationsMarkedAsRead => 'All notifications marked as read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get notificationDeleted => 'Notification deleted';

  @override
  String get newOrder => 'New Order';

  @override
  String get newUser => 'New User';

  @override
  String get newProduct => 'New Product';

  @override
  String get warning => 'Warning';

  @override
  String get pleaseAddAtLeastOneImage => 'Please add at least one image';

  @override
  String get productUpdatedSuccessfully => 'Product updated successfully';

  @override
  String get selectImages => 'Select Images';

  @override
  String get replaceImage => 'Replace Image';

  @override
  String get deleteImage => 'Delete Image';

  @override
  String get productName => 'Product Name';

  @override
  String get enterProductName => 'Enter product name';

  @override
  String get nameIsTooShort => 'Name is too short';

  @override
  String get maximum25Characters => 'Maximum 25 characters';

  @override
  String get nikeAirMaxHint => 'e.g. Nike Air Max';

  @override
  String get enterDescription => 'Enter description';

  @override
  String get descriptionIsTooShort => 'Description is too short';

  @override
  String get maximum80Characters => 'Maximum 80 characters';

  @override
  String get price => 'Price';

  @override
  String get enterPrice => 'Enter price';

  @override
  String get invalidPrice => 'Invalid price';

  @override
  String get priceMustBeGreaterThanZero => 'Price must be greater than 0';

  @override
  String get maximumPrice => 'Maximum price is 99999.99';

  @override
  String get oldPrice => 'Old Price';

  @override
  String get invalidOldPrice => 'Invalid old price';

  @override
  String get oldPriceMustBeGreaterThanZero => 'Old price must be greater than 0';

  @override
  String get stock => 'Stock';

  @override
  String get enterStockQuantity => 'Enter stock quantity';

  @override
  String get invalidStock => 'Invalid stock';

  @override
  String get stockCannotBeNegative => 'Stock cannot be negative';

  @override
  String get maximumStock => 'Maximum stock is 999999';

  @override
  String get category => 'Category';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get brand => 'Brand';

  @override
  String get pleaseSelectBrand => 'Please select a brand';

  @override
  String get updateProduct => 'Update Product';

  @override
  String get oldPriceHint => 'e.g. 129.99';

  @override
  String get stockHint => 'e.g. 25';

  @override
  String get accessories => 'Accessories';

  @override
  String get editProduct => 'Edit Product';

  @override
  String get productNameHint => 'e.g. Nike Air Max';

  @override
  String get error => 'Error';

  @override
  String get priceHint => 'e.g. 99.99';

  @override
  String get shortDescriptionHint => 'Short description...';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get selectImage => 'Select Image';

  @override
  String get pleaseSelectAnImage => 'Please select an image';

  @override
  String get productAddedSuccessfully => 'Product added successfully!';

  @override
  String get addProduct => 'Add Product';

  @override
  String get editUser => 'Edit User';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get userUpdatedSuccessfully => 'User updated successfully';

  @override
  String failedToUpdateUser(Object error) {
    return 'Failed to update user: $error';
  }

  @override
  String get saving => 'Saving...';

  @override
  String get usersDetails => 'Users Details';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get memberSince => 'Member Since';

  @override
  String get customerStatistics => 'Customer Statistics';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewOrders => 'View Orders';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get areYouSureDeleteUser => 'Are you sure you want to delete this user?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get userDeletedSuccessfully => 'User deleted successfully';

  @override
  String get noUserFound => 'No user found';

  @override
  String get userNotFound => 'User not found';

  @override
  String get administrator => 'Administrator';

  @override
  String get menu => 'MENU';

  @override
  String get orders => 'Orders';

  @override
  String get customers => 'Customers';

  @override
  String get products => 'Products';

  @override
  String get revenue => 'Revenue';

  @override
  String get analytics => 'Analytics';

  @override
  String get system => 'System';

  @override
  String get settings => 'Settings';

  @override
  String get noOrders => 'No Orders';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get customer => 'Customer';

  @override
  String get orderTotal => 'Order Total';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String get paymentProofUploaded => 'Payment proof uploaded';

  @override
  String get paymentProofNotUploaded => 'Payment proof not uploaded';

  @override
  String get viewPaymentProof => 'View Payment Proof';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get orderUpdatedSuccessfully => 'Order updated successfully';

  @override
  String get editBankAccount => 'Edit Bank Account';

  @override
  String get addBankAccount => 'Add Bank Account';

  @override
  String get editBankInformation => 'Edit Bank Information';

  @override
  String get bankInformation => 'Bank Information';

  @override
  String get updateBankAccountInfo => 'Update the bank account information customers can use for bank transfers.';

  @override
  String get addBankAccountInfo => 'Add the bank account customers can use for bank transfers.';

  @override
  String get bankName => 'Bank Name';

  @override
  String get accountName => 'Account Name';

  @override
  String get iban => 'IBAN';

  @override
  String get rib => 'RIB';

  @override
  String get swiftBic => 'SWIFT / BIC';

  @override
  String get phoneOptional => 'Phone (Optional)';

  @override
  String get customersCanUseAccount => 'Customers can use this account for bank transfers.';

  @override
  String get bankAccountUpdatedSuccessfully => 'Bank account updated successfully';

  @override
  String get bankAccountAddedSuccessfully => 'Bank account added successfully';

  @override
  String get failedToUpdateBankAccount => 'Failed to update bank account';

  @override
  String get failedToAddBankAccount => 'Failed to add bank account';

  @override
  String get updateBankAccount => 'Update Bank Account';

  @override
  String get saveBankAccount => 'Save Bank Account';

  @override
  String get bankNameRequired => 'Bank name is required';

  @override
  String get enterValidBankName => 'Enter a valid bank name';

  @override
  String get accountNameRequired => 'Account name is required';

  @override
  String get enterValidAccountName => 'Enter a valid account name';

  @override
  String get ibanRequired => 'IBAN is required';

  @override
  String get enterValidIban => 'Enter a valid IBAN';

  @override
  String get invalidIbanLength => 'Invalid IBAN length';

  @override
  String get ribRequired => 'RIB is required';

  @override
  String get ribExactly24Digits => 'RIB must contain exactly 24 digits';

  @override
  String get enterValidSwiftBic => 'Enter a valid SWIFT / BIC code';

  @override
  String get enterValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get enterValidEmailAddress => 'Enter a valid email address';

  @override
  String get paymentBanks => 'Payment Banks';

  @override
  String get bankAccountDisabled => 'Bank account disabled';

  @override
  String get bankAccountEnabled => 'Bank account enabled';

  @override
  String get unableToUpdateBankAccount => 'Unable to update bank account';

  @override
  String get deleteBankAccount => 'Delete Bank Account';

  @override
  String deleteBankConfirmation(Object bankName) {
    return 'Are you sure you want to delete \"$bankName\"?\n\nCustomers will no longer be able to use this account for bank transfers.';
  }

  @override
  String get bankAccountDeleted => 'Bank account deleted';

  @override
  String get unableToDeleteBankAccount => 'Unable to delete bank account';

  @override
  String get unableToLoadPaymentBanks => 'Unable to load payment banks.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noBankAccountsYet => 'No bank accounts yet';

  @override
  String get addBankAccountToEnableTransfers => 'Add a bank account to enable bank transfer payments.';

  @override
  String get unnamedBank => 'Unnamed Bank';

  @override
  String get accountNameNotProvided => 'Account name not provided';

  @override
  String get bankOptions => 'Bank options';

  @override
  String get disable => 'Disable';

  @override
  String get enable => 'Enable';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateAdministratorPassword => 'Update your administrator password.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get passwordMinLength => 'Password must contain at least 6 characters';

  @override
  String get confirmYourPassword => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again later.';

  @override
  String get pleaseSignInAgain => 'Please sign in again.';

  @override
  String get exportOrders => 'Export Orders';

  @override
  String get unableToLoadProfile => 'Unable to load profile';

  @override
  String get updateYourAdministratorProfile => 'Update your administrator profile';

  @override
  String get updateYourAccountPassword => 'Update your account password';

  @override
  String get application => 'Application';

  @override
  String get manageNotificationSettings => 'Manage notification settings';

  @override
  String get administration => 'Administration';

  @override
  String get viewStoreAnalytics => 'View store analytics';

  @override
  String get manageProducts => 'Manage Products';

  @override
  String get addEditOrDeleteProducts => 'Add, edit or delete products';

  @override
  String get manageOrders => 'Manage Orders';

  @override
  String get trackAndUpdateOrders => 'Track and update orders';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get viewRegisteredCustomers => 'View registered customers';

  @override
  String get exportAllOrders => 'Export all orders';

  @override
  String get backupDatabase => 'Backup Database';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get manageBankTransferAccounts => 'Manage bank transfer accounts';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get version101 => 'Version 1.0.0';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get forSecurityReasonsSignInAgain => 'For security reasons, please sign in again before deleting your account.';

  @override
  String get failedToDeleteAccount => 'Failed to delete account';

  @override
  String get permanentlyDeleteAccountConfirmation => 'Are you sure you want to permanently delete your account?\n\nThis action cannot be undone.';

  @override
  String get storePerformanceOverview => 'Store performance overview';

  @override
  String get noData => 'No Data';

  @override
  String get success => 'Success';

  @override
  String get businessOverview => 'Business Overview';

  @override
  String get businessHealth => 'Business Health';

  @override
  String get revenueGeneratedFromDeliveredOrders => 'Revenue generated from delivered orders';

  @override
  String usersRegistered(int count) {
    return '$count users registered';
  }

  @override
  String productsAvailable(int count) {
    return '$count products available';
  }

  @override
  String ordersDeliveredSuccessfully(int count) {
    return '$count orders delivered successfully';
  }

  @override
  String get logoutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get pleaseSelectAtLeastOneCollection => 'Please select at least one collection';

  @override
  String get saveDatabaseBackup => 'Save Database Backup';

  @override
  String get backupCancelled => 'Backup cancelled';

  @override
  String get databaseBackupSavedSuccessfully => 'Database backup saved successfully';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get selectDatabaseBackup => 'Select Database Backup';

  @override
  String get unableToReadSelectedFile => 'Unable to read the selected file';

  @override
  String get invalidBackupFile => 'Invalid backup file';

  @override
  String get restoreDatabase => 'Restore Database?';

  @override
  String get backupContains => 'This backup contains:';

  @override
  String collectionsCount(int count) {
    return '$count collections';
  }

  @override
  String documentsCount(int count) {
    return '$count documents';
  }

  @override
  String get existingDocumentsWillBeOverwritten => 'Existing documents with the same IDs will be overwritten.';

  @override
  String get doYouWantToContinue => 'Do you want to continue?';

  @override
  String get restore => 'Restore';

  @override
  String databaseRestoredSuccessfully(int count) {
    return 'Restore completed: $count new documents added';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get databaseBackup => 'Database Backup';

  @override
  String get createBackupDescription => 'Create a backup of your Firestore data and save it as a JSON file.';

  @override
  String get selectData => 'Select Data';

  @override
  String get chooseCollectionsToInclude => 'Choose which collections you want to include.';

  @override
  String completedPercentage(int percent) {
    return '$percent% completed';
  }

  @override
  String get creatingBackup => 'Creating Backup...';

  @override
  String get restoreBackup => 'Restore Backup';

  @override
  String get backupFirestoreOnly => 'The backup contains Firestore data only. Product and profile images stored in Firebase Storage are not included in this JSON backup.';

  @override
  String get pleaseSelectProfilePicture => 'Please select a profile picture';

  @override
  String get profilePhotoRequired => 'Profile Photo *';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get enterAValidPhoneNumber => 'Enter a valid phone number';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get productDeletedSuccessfully => 'Product deleted successfully';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get statistics => 'Statistics';

  @override
  String get rating => 'Rating';

  @override
  String get discount => 'Discount';

  @override
  String get deleteProduct => 'Delete Product';

  @override
  String get deleteProductConfirmation => 'Are you sure you want to delete this product?';

  @override
  String get productOutOfStock => 'This product is out of stock.';

  @override
  String onlyItemsAvailable(int stock) {
    return 'Only $stock items available.';
  }

  @override
  String get alreadyInCart => 'This product is already in your cart.';

  @override
  String get orderPlacedNotification => 'Order Placed';

  @override
  String orderPlacedNotificationBody(Object orderNumber) {
    return 'Your order $orderNumber has been placed successfully.';
  }

  @override
  String get orderUpdatedNotification => 'Order Updated';

  @override
  String orderUpdatedNotificationBody(Object orderNumber, Object status) {
    return 'Your order $orderNumber is now $status.';
  }

  @override
  String get newProductNotification => 'New Product';

  @override
  String newProductNotificationBody(Object productName) {
    return 'A new product has been added: $productName.';
  }

  @override
  String get promotionNotification => 'Special Offer';

  @override
  String promotionNotificationBody(Object productName) {
    return '$productName is now on sale!';
  }

  @override
  String get tapAgainToExit => 'Tap again to exit';

  @override
  String newOrderNotificationBody(Object userName, Object orderNumber) {
    return '$userName placed order $orderNumber';
  }

  @override
  String get enterStock => 'Please enter stock quantity.';

  @override
  String get createNewStoreForPlatform => 'Create a new store for your platform.';

  @override
  String get exampleMiloMall => 'Example: Milo Mall';

  @override
  String get exampleMiloMallId => 'Example: Milo_mall';

  @override
  String get pleaseEnterStoreName => 'Please enter the store name.';

  @override
  String get storeNameTooShort => 'Store name is too short.';

  @override
  String get storeId => 'Store ID';

  @override
  String get pleaseEnterStoreId => 'Please enter the store ID.';

  @override
  String get storeIdTooShort => 'Store ID is too short.';

  @override
  String get storeIdCharactersError => 'Use only lowercase letters, numbers and _.';

  @override
  String get storeActive => 'Store Active';

  @override
  String get usersCanAccessStore => 'Users can access this store.';

  @override
  String get usersCannotAccessStore => 'Users cannot access this store.';

  @override
  String get storeIdAlreadyExists => 'This store ID already exists.';

  @override
  String get storeCreatedSuccessfully => 'Store created successfully.';

  @override
  String get createAdministrator => 'Create Administrator';

  @override
  String get createAdminAssignStore => 'Create an administrator and assign them to a store.';

  @override
  String get pleaseEnterFirstName => 'Please enter the first name.';

  @override
  String get pleaseEnterLastName => 'Please enter the last name.';

  @override
  String get pleaseEnterEmail => 'Please enter the email.';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email.';

  @override
  String get pleaseEnterPassword => 'Please enter a password.';

  @override
  String get passwordMinCharacters => 'Password must be at least 6 characters.';

  @override
  String get assignStore => 'Assign Store';

  @override
  String get unableToLoadStores => 'Unable to load stores.';

  @override
  String get noActiveStoresAvailable => 'No active stores available.';

  @override
  String get adminCreatedSuccessfully => 'Admin created successfully';

  @override
  String get failedToCreateAdmin => 'Failed to create admin.';

  @override
  String get stores => 'Stores';

  @override
  String get createStore => 'Create Store';

  @override
  String get noStoresYet => 'No stores yet';

  @override
  String get superAdmin => 'Super Admin';

  @override
  String get platformOverview => 'Platform Overview';

  @override
  String get manageAllStoresAndAdmins => 'Manage all stores and administrators.';

  @override
  String get management => 'Management';

  @override
  String get manageStores => 'Manage Stores';

  @override
  String get createEditManageAllStores => 'Create, edit and manage all stores.';

  @override
  String get manageAdmins => 'Manage Admins';

  @override
  String get createAdminsAndAssignStores => 'Create administrators and assign them to stores.';

  @override
  String get ordersCompleted => 'Completed Orders';

  @override
  String get admins => 'Admins';

  @override
  String get createAdmin => 'Create Admin';

  @override
  String get noAdminsYet => 'No admins yet';

  @override
  String get noStoreAssigned => 'No store assigned';

  @override
  String get storeInformation => 'Store Information';

  @override
  String get storeName => 'Store Name';

  @override
  String get pleaseSelectStore => 'Please select a store.';

  @override
  String get security => 'Security';

  @override
  String get passwordResetDescription => 'Send a password reset link to your email.';

  @override
  String get appearance => 'Appearance';

  @override
  String get adminManagement => 'Admin Management';

  @override
  String get platform => 'Platform';

  @override
  String get aboutMiloMall => 'About Milo Mall';

  @override
  String get saasMarketplacePlatform => 'Milo Mall SaaS Marketplace Platform';

  @override
  String get emailVerified => 'Email Verified';

  @override
  String get emailNotVerified => 'Email Not Verified';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get close => 'Close';

  @override
  String get editStore => 'Edit Store';

  @override
  String get updateStoreInformation => 'Update your store information.';

  @override
  String get removeStoreLogo => 'Remove Store Logo';

  @override
  String get storeUpdatedSuccessfully => 'Store updated successfully.';

  @override
  String get store => 'Store';

  @override
  String get editAdmin => 'Edit Admin';

  @override
  String get since => 'Since';

  @override
  String get adminInformation => 'Admin Information';

  @override
  String get updateAdminInformation => 'Update the administrator\'s information.';

  @override
  String get adminUpdatedSuccessfully => 'Admin updated successfully.';

  @override
  String get permissionDenied => 'You do not have permission to perform this action.';

  @override
  String get adminOrStoreNotFound => 'Admin or store not found.';

  @override
  String get emailAlreadyExists => 'An account with this email already exists.';

  @override
  String get storeInactive => 'The selected store is inactive.';

  @override
  String get invalidAdminInformation => 'The admin information is invalid.';

  @override
  String get adminUpdateSecurityInfo => 'Admin changes are securely processed through the platform administration service.';

  @override
  String get allStores => 'All Stores';

  @override
  String get allAdmins => 'All Administrators';

  @override
  String get totalStores => 'Total Stores';

  @override
  String get activeStores => 'Active Stores';

  @override
  String get noStores => 'No stores found';

  @override
  String get noAdmins => 'No administrators found';

  @override
  String get totalAdmins => 'Total Administrators';

  @override
  String get computers => 'Computers';

  @override
  String get fashion => 'Fashion';

  @override
  String get lifestyle => 'Lifestyle';

  @override
  String placedNewOrder(Object userName) {
    return '$userName placed a new order';
  }

  @override
  String get currencySymbol => 'MAD';

  @override
  String get whatsappNumber => 'WhatsApp Number';

  @override
  String get enterWhatsappNumber => 'Please enter WhatsApp number';

  @override
  String get invalidWhatsappNumber => 'Please enter a valid WhatsApp number';

  @override
  String get accountInactive => 'Your account is inactive. Please contact the store administrator.';

  @override
  String get chooseYourStore => 'Choose your store';

  @override
  String get selectStoreToContinue => 'Select a store to continue';

  @override
  String get noStoresAvailableAtMoment => 'There are no stores available at the moment.';

  @override
  String get oldPriceMustBeGreaterThanPrice => 'Old price must be greater than the current price.';

  @override
  String get confirm => 'Confirm';

  @override
  String get oldPriceMustBeHigher => 'Old price must be higher than the current price';

  @override
  String get productRemovedByAdmin => 'This product is no longer available because it was removed by the admin.';

  @override
  String get subscriptionCenterTitle => 'Subscription Center';

  @override
  String get subscriptionCenterSubtitle => 'Manage monthly plans and payment dates';

  @override
  String get subscriptionTotalStores => 'Total stores';

  @override
  String get subscriptionConfigured => 'Configured';

  @override
  String get subscriptionDueSoon => 'Due soon';

  @override
  String get subscriptionOverdue => 'Overdue';

  @override
  String get subscriptionExpectedRevenue => 'Expected monthly revenue';

  @override
  String get subscriptionStoreSubscriptions => 'Store subscriptions';

  @override
  String get subscriptionFilterAll => 'All';

  @override
  String get subscriptionStatusActive => 'Active';

  @override
  String get subscriptionStatusDueSoon => 'Due soon';

  @override
  String get subscriptionStatusOverdue => 'Overdue';

  @override
  String get subscriptionStatusNotConfigured => 'Not configured';

  @override
  String get subscriptionNoStores => 'No stores found for this filter.';

  @override
  String get subscriptionOverdueNote => 'Overdue subscriptions only show an alert here. Store activation is managed separately.';

  @override
  String get subscriptionManageTitle => 'Manage subscription';

  @override
  String get subscriptionMonthlyPrice => 'Monthly price (MAD)';

  @override
  String get subscriptionPriceHint => 'e.g. 150';

  @override
  String get subscriptionNextPayment => 'Next payment date';

  @override
  String get subscriptionNotSet => 'Not set';

  @override
  String get subscriptionSaveNote => 'This only saves subscription details. It does not record a payment or deactivate the store.';

  @override
  String get subscriptionInvalidPrice => 'Enter a valid monthly price.';

  @override
  String get subscriptionSelectPaymentDate => 'Please select the next payment date.';

  @override
  String get subscriptionSaving => 'Saving...';

  @override
  String get subscriptionSave => 'Save subscription';

  @override
  String get subscriptionStoreEnabled => 'Store enabled';

  @override
  String get subscriptionStoreDisabled => 'Store disabled';

  @override
  String get subscriptionLoadError => 'Could not load subscriptions.';

  @override
  String subscriptionUpdatedFor(String storeName) {
    return 'Subscription updated for $storeName.';
  }

  @override
  String subscriptionSaveError(String error) {
    return 'Could not save subscription: $error';
  }

  @override
  String get subscriptions => 'Plans';

  @override
  String get accessDeniedSuperAdminOnly => 'Access denied. SuperAdmin only.';

  @override
  String get selectAtLeastOneCollection => 'Select at least one collection to back up.';

  @override
  String get existingDocumentsKeptUnchanged => 'Existing documents will be kept unchanged.';

  @override
  String get onlyNewDocumentsAdded => 'Only new documents will be added.';

  @override
  String restoreFinished(int added, int skipped) {
    return 'Restore finished: $added documents added, $skipped documents skipped.';
  }

  @override
  String get storeSubscriptionSignInAgain => 'Please sign in again.';

  @override
  String get storeSubscriptionNoStore => 'No store is associated with this account.';

  @override
  String get storeSubscriptionStoreNotFound => 'Store not found.';

  @override
  String get storeSubscriptionChooseFileType => 'Choose a JPG, PNG, WEBP or PDF file.';

  @override
  String get storeSubscriptionFileTooLarge => 'The file must be smaller than 10 MB.';

  @override
  String get storeSubscriptionFileReadError => 'Could not read the selected file.';

  @override
  String storeSubscriptionFileSelectError(Object error) {
    return 'Could not select file: $error';
  }

  @override
  String get storeSubscriptionSelectDateAndProof => 'Select the transfer date and proof file first.';

  @override
  String get storeSubscriptionFileUnavailable => 'The selected file is no longer available. Select it again.';

  @override
  String get storeSubscriptionPriceNotConfigured => 'The subscription price has not been configured.';

  @override
  String get storeSubscriptionBankUnavailable => 'The subscription bank account is currently unavailable.';

  @override
  String get storeSubscriptionPaymentSubmitted => 'Payment proof submitted. Your payment is waiting for review.';

  @override
  String storeSubscriptionSubmitPaymentError(Object error) {
    return 'Could not submit payment: $error';
  }

  @override
  String get storeSubscriptionTitle => 'Subscription & Payments';

  @override
  String get storeSubscriptionYourSubscription => 'Your subscription';

  @override
  String get storeSubscriptionPriceLabel => 'Subscription price';

  @override
  String get storeSubscriptionNextPaymentDate => 'Next payment date';

  @override
  String get storeSubscriptionStatusLabel => 'Subscription status';

  @override
  String get storeSubscriptionBankTransfer => 'Bank transfer';

  @override
  String get storeSubscriptionBankUnavailableContact => 'Bank transfer is currently unavailable. Please contact support.';

  @override
  String get storeSubscriptionBankTransferDetails => 'Bank transfer details';

  @override
  String get storeSubscriptionTransferInstructions => 'Transfer the subscription amount to this account.';

  @override
  String get storeSubscriptionBankName => 'Bank name';

  @override
  String get storeSubscriptionAccountHolder => 'Account holder';

  @override
  String get storeSubscriptionRib => 'RIB';

  @override
  String get storeSubscriptionIban => 'IBAN';

  @override
  String get storeSubscriptionSwiftBic => 'SWIFT/BIC';

  @override
  String get storeSubscriptionSubmitProofTitle => 'Submit payment proof';

  @override
  String get storeSubscriptionUploadReceiptSubtitle => 'Upload your transfer receipt for manual verification.';

  @override
  String get storeSubscriptionTransferDate => 'Transfer date';

  @override
  String get storeSubscriptionTransactionReferenceOptional => 'Transaction reference (optional)';

  @override
  String get storeSubscriptionTransactionReferenceHint => 'Enter your bank transaction reference';

  @override
  String get storeSubscriptionTransferReceiptRequired => 'Transfer receipt *';

  @override
  String get storeSubscriptionChooseImageOrPdf => 'Choose image or PDF';

  @override
  String get storeSubscriptionAllowedFileTypes => 'JPG, PNG, WEBP or PDF · Max 10 MB';

  @override
  String get storeSubscriptionBrowseFiles => 'Browse files';

  @override
  String get storeSubscriptionChangeFile => 'Change file';

  @override
  String get storeSubscriptionSubmitting => 'Submitting...';

  @override
  String get storeSubscriptionSubmitForVerification => 'Submit for verification';

  @override
  String get storeSubscriptionManualVerificationNotice => 'Submitting proof does not renew your subscription automatically. Your payment must be verified by the platform administrator.';

  @override
  String get storeSubscriptionPaymentHistory => 'Payment history';

  @override
  String get storeSubscriptionPaymentHistorySubtitle => 'Track your subscription payment submissions.';

  @override
  String storeSubscriptionLoadHistoryError(Object error) {
    return 'Could not load payment history: $error';
  }

  @override
  String get storeSubscriptionNoPayments => 'No subscription payments submitted yet.';

  @override
  String get storeSubscriptionPaymentApproved => 'Approved';

  @override
  String get storeSubscriptionPaymentRejected => 'Rejected';

  @override
  String get storeSubscriptionPaymentPendingReview => 'Pending review';

  @override
  String get storeSubscriptionReference => 'Reference';

  @override
  String get storeSubscriptionAdminNote => 'Admin note';

  @override
  String storeSubscriptionLoadDetailsError(Object error) {
    return 'Could not load subscription details: $error';
  }

  @override
  String get storeSubscriptionLoadBankError => 'Could not load bank details. Please contact support.';

  @override
  String get storeSubscriptionManageTitle => 'Manage your subscription';

  @override
  String get storeSubscriptionManageSubtitle => 'Review your plan, transfer the payment, and submit your receipt for verification.';

  @override
  String get storeSubscriptionTryAgain => 'Try again';

  @override
  String get storeSubscriptionMonthlyPlan => 'Monthly';

  @override
  String get reviewSubscriptionPayments => 'Review Subscription Payments';

  @override
  String get reviewSubscriptionPaymentsSubtitle => 'Review bank transfers and approve or reject payments.';

  @override
  String get subscriptionPayments => 'Subscription Payments';

  @override
  String get subscriptionAndPayments => 'Subscription & Payments';

  @override
  String get manageAllSubscriptions => 'Manage all subscriptions';

  @override
  String get subscriptionPaymentPending => 'Pending';

  @override
  String get subscriptionPaymentAll => 'All';

  @override
  String get subscriptionPaymentProof => 'Payment proof';

  @override
  String get subscriptionPaymentNoProof => 'No payment proof was provided.';

  @override
  String get subscriptionPaymentOpenUploadedFile => 'Open the uploaded file using the link below:';

  @override
  String subscriptionPaymentCouldNotOpenProof(Object error) {
    return 'Could not open payment proof: $error';
  }

  @override
  String get subscriptionPaymentApproveTitle => 'Approve payment';

  @override
  String get subscriptionPaymentRejectTitle => 'Reject payment';

  @override
  String get subscriptionPaymentRejectionReason => 'Reason for rejection *';

  @override
  String get subscriptionPaymentReviewNoteOptional => 'Review note (optional)';

  @override
  String get subscriptionPaymentRequestMissing => 'Payment request no longer exists.';

  @override
  String get subscriptionPaymentMissingStoreId => 'Payment request has no store ID.';

  @override
  String get subscriptionPaymentStoreMissing => 'Store does not exist.';

  @override
  String get subscriptionPaymentAlreadyReviewed => 'This payment has already been reviewed.';

  @override
  String get subscriptionPaymentApprovedUpdated => 'Payment approved and subscription updated.';

  @override
  String get subscriptionPaymentRejectedMessage => 'Payment rejected.';

  @override
  String subscriptionPaymentReviewError(Object error) {
    return 'Could not review payment: $error';
  }

  @override
  String get subscriptionPaymentBank => 'Bank';

  @override
  String get subscriptionPaymentTransferReference => 'Transfer reference';

  @override
  String get subscriptionPaymentTransferDate => 'Transfer date';

  @override
  String get subscriptionPaymentSubmitted => 'Submitted';

  @override
  String get subscriptionPaymentViewProof => 'View payment proof';

  @override
  String subscriptionPaymentLoadError(Object error) {
    return 'Could not load payment requests:\n$error';
  }

  @override
  String get subscriptionPaymentNoRequests => 'No payment requests found.';

  @override
  String get save => 'Save';

  @override
  String get activeBankDetailsVisibleToStoreAdmins => 'Active bank details are visible to store admins.';

  @override
  String get paymentInstructions => 'Payment instructions';

  @override
  String get subscriptionBankAccount => 'Subscription Bank Account';

  @override
  String get couldNotLoadBankDetails => 'Could not load bank details';

  @override
  String get bankDetailsSavedSuccessfully => 'Bank details saved successfully';

  @override
  String get storeCategories => 'Store Categories';

  @override
  String get selectStoreCategories => 'Select the categories available in this store';

  @override
  String get androidPhones => 'Android Phones';

  @override
  String get iphones => 'iPhones';

  @override
  String get phoneAccessories => 'Phone Accessories';

  @override
  String get desktopComputers => 'Desktop Computers';

  @override
  String get computerAccessories => 'Computer Accessories';

  @override
  String get monitors => 'Monitors';

  @override
  String get printers => 'Printers';

  @override
  String get televisions => 'Televisions';

  @override
  String get cameras => 'Cameras';

  @override
  String get smartHome => 'Smart Home';

  @override
  String get electronicAccessories => 'Electronic Accessories';

  @override
  String get women => 'Women';

  @override
  String get men => 'Men';

  @override
  String get kids => 'Kids';

  @override
  String get unisex => 'Unisex';

  @override
  String get sunglasses => 'Sunglasses';

  @override
  String get wallets => 'Wallets';

  @override
  String get skincare => 'Skincare';

  @override
  String get makeup => 'Makeup';

  @override
  String get bodyCare => 'Body Care';

  @override
  String get hairCare => 'Hair Care';

  @override
  String get livingRoom => 'Living Room';

  @override
  String get bedroom => 'Bedroom';

  @override
  String get office => 'Office';

  @override
  String get kitchen => 'Kitchen';

  @override
  String get outdoorFurniture => 'Outdoor Furniture';

  @override
  String get fitness => 'Fitness';

  @override
  String get training => 'Training';

  @override
  String get sportswear => 'Sportswear';

  @override
  String get sportsEquipment => 'Sports Equipment';

  @override
  String get consoles => 'Consoles';

  @override
  String get games => 'Games';

  @override
  String get gamingAccessories => 'Gaming Accessories';

  @override
  String get otherProducts => 'Other Products';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get rings => 'Rings';

  @override
  String get necklaces => 'Necklaces';

  @override
  String get bracelets => 'Bracelets';

  @override
  String get anklets => 'Anklets';

  @override
  String get earrings => 'Earrings';

  @override
  String get goldChains => 'Gold Chains';

  @override
  String get silverChains => 'Silver Chains';

  @override
  String get pendants => 'Pendants';

  @override
  String get goldSets => 'Gold Sets';

  @override
  String get silverSets => 'Silver Sets';

  @override
  String get crownsAndTiaras => 'Crowns & Tiaras';

  @override
  String get otherGoldJewelry => 'Other Gold Jewelry';

  @override
  String get otherSilverJewelry => 'Other Silver Jewelry';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get pleaseSelectSubcategory => 'Please select a subcategory';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';
}
