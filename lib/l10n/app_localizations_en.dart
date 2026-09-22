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
  String get invalidEmail => 'Invalid email';

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
  String get passwordResetEmailSent => 'Password reset email sent! Check your inbox or spam folder.';

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
  String get usernameOptional => 'Username (Optional)';

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
  String get zipCodeOptional => 'ZIP Code (Optional)';

  @override
  String get additionalInformation => 'Additional Information';

  @override
  String get genderOptional => 'Gender (Optional)';

  @override
  String get dateOfBirthOptional => 'Date of Birth (Optional)';

  @override
  String get selectYourBirthDate => 'Select your birth date';

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
  String get admin => 'Administrator';

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
  String get username => 'Username';

  @override
  String get phone => 'Phone';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get selectDateOfBirth => 'Select date of birth';

  @override
  String get shippingAddress => 'Shipping Address';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get zipCode => 'ZIP Code';

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
  String get system => 'SYSTEM';

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
  String get pleaseSignInAgain => 'Please sign in again and retry.';

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
    return 'Database restored successfully ($count documents)';
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
  String get usernameIsRequired => 'Username is required';

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
  String get continueAsGuest => 'Continue as Guest';
}
