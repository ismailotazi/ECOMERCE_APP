import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 chars'**
  String get min6Chars;

  /// No description provided for @accountCreatedVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Please verify your email before logging in.'**
  String get accountCreatedVerifyEmail;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get emailAlreadyInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get weakPassword;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get noInternetConnection;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed.'**
  String get registrationFailed;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleError.
  ///
  /// In en, this message translates to:
  /// **'Google error: {error}'**
  String googleError(String error);

  /// No description provided for @verifyYourEmailFirst.
  ///
  /// In en, this message translates to:
  /// **'Verify your email first'**
  String get verifyYourEmailFirst;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @userDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'User data not found.'**
  String get userDataNotFound;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAnAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox or spam folder.'**
  String get passwordResetEmailSent;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @noUserFoundForEmail.
  ///
  /// In en, this message translates to:
  /// **'No user found for this email'**
  String get noUserFoundForEmail;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmailAddress;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @enterEmailToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset your password'**
  String get enterEmailToResetPassword;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @emailNotVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'Email is not verified yet.'**
  String get emailNotVerifiedYet;

  /// No description provided for @verificationEmailSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully.'**
  String get verificationEmailSentSuccessfully;

  /// No description provided for @verificationEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification email to your inbox.\nPlease verify your email before continuing.'**
  String get verificationEmailMessage;

  /// No description provided for @iveVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get iveVerifiedMyEmail;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get resendVerificationEmail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get searchProducts;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @bestSelling.
  ///
  /// In en, this message translates to:
  /// **'Best Selling'**
  String get bestSelling;

  /// No description provided for @smartphones.
  ///
  /// In en, this message translates to:
  /// **'Smartphones'**
  String get smartphones;

  /// No description provided for @laptops.
  ///
  /// In en, this message translates to:
  /// **'Laptops'**
  String get laptops;

  /// No description provided for @tablets.
  ///
  /// In en, this message translates to:
  /// **'Tablets'**
  String get tablets;

  /// No description provided for @smartwatches.
  ///
  /// In en, this message translates to:
  /// **'Smartwatches'**
  String get smartwatches;

  /// No description provided for @audio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// No description provided for @gaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get gaming;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @homeAppliances.
  ///
  /// In en, this message translates to:
  /// **'Home Appliances'**
  String get homeAppliances;

  /// No description provided for @perfumes.
  ///
  /// In en, this message translates to:
  /// **'Perfumes'**
  String get perfumes;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @shoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get shoes;

  /// No description provided for @bags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get bags;

  /// No description provided for @glasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get glasses;

  /// No description provided for @watches.
  ///
  /// In en, this message translates to:
  /// **'Watches'**
  String get watches;

  /// No description provided for @jewelry.
  ///
  /// In en, this message translates to:
  /// **'Jewelry'**
  String get jewelry;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @toys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get toys;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @automotive.
  ///
  /// In en, this message translates to:
  /// **'Automotive'**
  String get automotive;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @rateThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Rate this product'**
  String get rateThisProduct;

  /// No description provided for @tellUsAboutThisProduct.
  ///
  /// In en, this message translates to:
  /// **'Tell us about this product...'**
  String get tellUsAboutThisProduct;

  /// No description provided for @reviewSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Review submitted successfully'**
  String get reviewSubmittedSuccessfully;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @logoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get logoutFailed;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @noOrderYet.
  ///
  /// In en, this message translates to:
  /// **'No order yet'**
  String get noOrderYet;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @firstNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameIsRequired;

  /// No description provided for @firstNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters'**
  String get firstNameMinLength;

  /// No description provided for @firstNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'First name must not exceed 30 characters'**
  String get firstNameMaxLength;

  /// No description provided for @validFirstName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid first name'**
  String get validFirstName;

  /// No description provided for @lastNameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameIsRequired;

  /// No description provided for @lastNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters'**
  String get lastNameMinLength;

  /// No description provided for @lastNameMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must not exceed 30 characters'**
  String get lastNameMaxLength;

  /// No description provided for @validLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid last name'**
  String get validLastName;

  /// No description provided for @usernameOptional.
  ///
  /// In en, this message translates to:
  /// **'Username (Optional)'**
  String get usernameOptional;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Required)'**
  String get phoneNumberRequired;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @countryRequired.
  ///
  /// In en, this message translates to:
  /// **'Country (Required)'**
  String get countryRequired;

  /// No description provided for @countryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Country is required'**
  String get countryIsRequired;

  /// No description provided for @countryNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Country name is too short'**
  String get countryNameTooShort;

  /// No description provided for @countryNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Country name is too long'**
  String get countryNameTooLong;

  /// No description provided for @validCountryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid country name'**
  String get validCountryName;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City (Required)'**
  String get cityRequired;

  /// No description provided for @cityIsRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityIsRequired;

  /// No description provided for @cityNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'City name is too short'**
  String get cityNameTooShort;

  /// No description provided for @validCityName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid city name'**
  String get validCityName;

  /// No description provided for @streetAddressOptional.
  ///
  /// In en, this message translates to:
  /// **'Street Address (Optional)'**
  String get streetAddressOptional;

  /// No description provided for @zipCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code (Optional)'**
  String get zipCodeOptional;

  /// No description provided for @additionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInformation;

  /// No description provided for @genderOptional.
  ///
  /// In en, this message translates to:
  /// **'Gender (Optional)'**
  String get genderOptional;

  /// No description provided for @dateOfBirthOptional.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth (Optional)'**
  String get dateOfBirthOptional;

  /// No description provided for @selectYourBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date'**
  String get selectYourBirthDate;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noProductFound.
  ///
  /// In en, this message translates to:
  /// **'No product found'**
  String get noProductFound;

  /// No description provided for @tryAnotherKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try searching with another keyword.'**
  String get tryAnotherKeyword;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get noName;

  /// No description provided for @pleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please login'**
  String get pleaseLogin;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @taxIncluded.
  ///
  /// In en, this message translates to:
  /// **'Tax included'**
  String get taxIncluded;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @itemsLeftInStock.
  ///
  /// In en, this message translates to:
  /// **'Only {count} items left in stock'**
  String itemsLeftInStock(Object count);

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @relatedProducts.
  ///
  /// In en, this message translates to:
  /// **'Related Products'**
  String get relatedProducts;

  /// No description provided for @noRelatedProducts.
  ///
  /// In en, this message translates to:
  /// **'No related products'**
  String get noRelatedProducts;

  /// No description provided for @customerReviews.
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get noProducts;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart 🛒'**
  String get addedToCart;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'No favorite products'**
  String get noFavoriteProducts;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites ❤️'**
  String get removedFromFavorites;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterYourFullName;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name is too long'**
  String get nameTooLong;

  /// No description provided for @pleaseEnterAValidName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid name'**
  String get pleaseEnterAValidName;

  /// No description provided for @pleaseEnterYourFirstAndLastName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name'**
  String get pleaseEnterYourFirstAndLastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pleaseEnterYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter your address'**
  String get pleaseEnterYourAddress;

  /// No description provided for @pleaseEnterAMoreCompleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a more complete address'**
  String get pleaseEnterAMoreCompleteAddress;

  /// No description provided for @addressTooLong.
  ///
  /// In en, this message translates to:
  /// **'Address is too long'**
  String get addressTooLong;

  /// No description provided for @pleaseEnterYourCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get pleaseEnterYourCity;

  /// No description provided for @cityNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'City name is too long'**
  String get cityNameTooLong;

  /// No description provided for @pleaseEnterAValidCity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid city'**
  String get pleaseEnterAValidCity;

  /// No description provided for @saveYourInformation.
  ///
  /// In en, this message translates to:
  /// **'Save your information'**
  String get saveYourInformation;

  /// No description provided for @forFasterCheckoutNextTime.
  ///
  /// In en, this message translates to:
  /// **'For faster checkout next time'**
  String get forFasterCheckoutNextTime;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @payWhenYourOrderArrives.
  ///
  /// In en, this message translates to:
  /// **'Pay when your order arrives'**
  String get payWhenYourOrderArrives;

  /// No description provided for @transferBeforeShipping.
  ///
  /// In en, this message translates to:
  /// **'Transfer before shipping'**
  String get transferBeforeShipping;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @orderPlacedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully 🎉'**
  String get orderPlacedSuccessfully;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @pleaseEnterAValidAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid address'**
  String get pleaseEnterAValidAddress;

  /// No description provided for @pleaseEnterYourCountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter your country'**
  String get pleaseEnterYourCountry;

  /// No description provided for @pleaseEnterAValidCountry.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid country'**
  String get pleaseEnterAValidCountry;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @pleaseSelectAtLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one product'**
  String get pleaseSelectAtLeastOneProduct;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @unableToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to select image'**
  String get unableToSelectImage;

  /// No description provided for @noActiveBankAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No active bank accounts available'**
  String get noActiveBankAccountsAvailable;

  /// No description provided for @unableToLoadPaymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Unable to load payment information'**
  String get unableToLoadPaymentInformation;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'copied'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @transferYourOrderTotalToTheBankAccountBelow.
  ///
  /// In en, this message translates to:
  /// **'Transfer your order total to the bank account below.'**
  String get transferYourOrderTotalToTheBankAccountBelow;

  /// No description provided for @selectBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Bank Account'**
  String get selectBankAccount;

  /// No description provided for @bankAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Details'**
  String get bankAccountDetails;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @paymentProof.
  ///
  /// In en, this message translates to:
  /// **'Payment Proof'**
  String get paymentProof;

  /// No description provided for @uploadTransferScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Upload transfer screenshot'**
  String get uploadTransferScreenshot;

  /// No description provided for @tapToChooseAnImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose an image'**
  String get tapToChooseAnImage;

  /// No description provided for @paymentProofSelected.
  ///
  /// In en, this message translates to:
  /// **'Payment proof selected'**
  String get paymentProofSelected;

  /// No description provided for @afterCompletingTheTransfer.
  ///
  /// In en, this message translates to:
  /// **'After completing the transfer, tap \"I Have Transferred\" to continue placing your order.'**
  String get afterCompletingTheTransfer;

  /// No description provided for @bankTransferCurrentlyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer is currently unavailable. Please choose another payment method.'**
  String get bankTransferCurrentlyUnavailable;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @iHaveTransferred.
  ///
  /// In en, this message translates to:
  /// **'I Have Transferred'**
  String get iHaveTransferred;

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in'**
  String get userNotLoggedIn;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseYourPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourPreferredLanguage;

  /// No description provided for @chooseLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you want to use in the app.'**
  String get chooseLanguageDescription;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @unitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get unitedStates;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @france.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get france;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @morocco.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get morocco;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @followDeviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Follow device language'**
  String get followDeviceLanguage;

  /// No description provided for @languageSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language saved successfully'**
  String get languageSavedSuccessfully;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage how you receive updates from the app.'**
  String get manageNotificationsDescription;

  /// No description provided for @orderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order Updates'**
  String get orderUpdates;

  /// No description provided for @orderUpdatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive updates about your orders.'**
  String get orderUpdatesDescription;

  /// No description provided for @offersDiscounts.
  ///
  /// In en, this message translates to:
  /// **'Offers & Discounts'**
  String get offersDiscounts;

  /// No description provided for @offersDiscountsDescription.
  ///
  /// In en, this message translates to:
  /// **'Get notified about new deals.'**
  String get offersDiscountsDescription;

  /// No description provided for @promotionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive promotional notifications.'**
  String get promotionsDescription;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive important emails.'**
  String get emailNotificationsDescription;

  /// No description provided for @pushNotificationsFutureUpdate.
  ///
  /// In en, this message translates to:
  /// **'Push notifications with Firebase Cloud Messaging will be available in a future update.'**
  String get pushNotificationsFutureUpdate;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @chooseYourPreferredTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get chooseYourPreferredTheme;

  /// No description provided for @selectHowAppAppear.
  ///
  /// In en, this message translates to:
  /// **'Select how you want the app to appear.'**
  String get selectHowAppAppear;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @alwaysUseLightMode.
  ///
  /// In en, this message translates to:
  /// **'Always use light mode'**
  String get alwaysUseLightMode;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @alwaysUseDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Always use dark mode'**
  String get alwaysUseDarkMode;

  /// No description provided for @followDeviceSettings.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get followDeviceSettings;

  /// No description provided for @themeSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme saved successfully'**
  String get themeSavedSuccessfully;

  /// No description provided for @failedToSaveTheme.
  ///
  /// In en, this message translates to:
  /// **'Failed to save theme'**
  String get failedToSaveTheme;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteUserConfirmation(Object name);

  /// No description provided for @unableToLoadOrders.
  ///
  /// In en, this message translates to:
  /// **'Unable to load orders.'**
  String get unableToLoadOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No Orders Found'**
  String get noOrdersFound;

  /// No description provided for @userHasNoOrders.
  ///
  /// In en, this message translates to:
  /// **'This user hasn\'t placed any orders yet.'**
  String get userHasNoOrders;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderNumber}'**
  String orderNumber(Object orderNumber);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @usersOrders.
  ///
  /// In en, this message translates to:
  /// **'User Orders'**
  String get usersOrders;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening today'**
  String get dashboardSubtitle;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @noRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'No recent orders'**
  String get noRecentOrders;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @storeManagement.
  ///
  /// In en, this message translates to:
  /// **'Store Management'**
  String get storeManagement;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get noProductsAvailable;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @chooseNotifications.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive.'**
  String get chooseNotifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @turnAllNotificationsOnOrOff.
  ///
  /// In en, this message translates to:
  /// **'Turn all notifications on or off'**
  String get turnAllNotificationsOnOrOff;

  /// No description provided for @newOrders.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrders;

  /// No description provided for @receiveNotificationsForNewOrders.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for new orders'**
  String get receiveNotificationsForNewOrders;

  /// No description provided for @newUsers.
  ///
  /// In en, this message translates to:
  /// **'New Users'**
  String get newUsers;

  /// No description provided for @notifyWhenCustomerRegisters.
  ///
  /// In en, this message translates to:
  /// **'Notify when a customer registers'**
  String get notifyWhenCustomerRegisters;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @alertWhenProductsRunningOut.
  ///
  /// In en, this message translates to:
  /// **'Alert when products are running out'**
  String get alertWhenProductsRunningOut;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @marketingPromotionalNotifications.
  ///
  /// In en, this message translates to:
  /// **'Marketing & promotional notifications'**
  String get marketingPromotionalNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @playSoundWhenReceivingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Play a sound when receiving notifications'**
  String get playSoundWhenReceivingNotifications;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrateWhenReceivingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Vibrate when receiving notifications'**
  String get vibrateWhenReceivingNotifications;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @allNotificationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @notificationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notificationDeleted;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get newOrder;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get newUser;

  /// No description provided for @newProduct.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProduct;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @pleaseAddAtLeastOneImage.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one image'**
  String get pleaseAddAtLeastOneImage;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @selectImages.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get selectImages;

  /// No description provided for @replaceImage.
  ///
  /// In en, this message translates to:
  /// **'Replace Image'**
  String get replaceImage;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @enterProductName.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// No description provided for @nameIsTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get nameIsTooShort;

  /// No description provided for @maximum25Characters.
  ///
  /// In en, this message translates to:
  /// **'Maximum 25 characters'**
  String get maximum25Characters;

  /// No description provided for @nikeAirMaxHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nike Air Max'**
  String get nikeAirMaxHint;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get enterDescription;

  /// No description provided for @descriptionIsTooShort.
  ///
  /// In en, this message translates to:
  /// **'Description is too short'**
  String get descriptionIsTooShort;

  /// No description provided for @maximum80Characters.
  ///
  /// In en, this message translates to:
  /// **'Maximum 80 characters'**
  String get maximum80Characters;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get enterPrice;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get invalidPrice;

  /// No description provided for @priceMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get priceMustBeGreaterThanZero;

  /// No description provided for @maximumPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price is 99999.99'**
  String get maximumPrice;

  /// No description provided for @oldPrice.
  ///
  /// In en, this message translates to:
  /// **'Old Price'**
  String get oldPrice;

  /// No description provided for @invalidOldPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid old price'**
  String get invalidOldPrice;

  /// No description provided for @oldPriceMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Old price must be greater than 0'**
  String get oldPriceMustBeGreaterThanZero;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @enterStockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter stock quantity'**
  String get enterStockQuantity;

  /// No description provided for @invalidStock.
  ///
  /// In en, this message translates to:
  /// **'Invalid stock'**
  String get invalidStock;

  /// No description provided for @stockCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot be negative'**
  String get stockCannotBeNegative;

  /// No description provided for @maximumStock.
  ///
  /// In en, this message translates to:
  /// **'Maximum stock is 999999'**
  String get maximumStock;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @pleaseSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @pleaseSelectBrand.
  ///
  /// In en, this message translates to:
  /// **'Please select a brand'**
  String get pleaseSelectBrand;

  /// No description provided for @updateProduct.
  ///
  /// In en, this message translates to:
  /// **'Update Product'**
  String get updateProduct;

  /// No description provided for @oldPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 129.99'**
  String get oldPriceHint;

  /// No description provided for @stockHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get stockHint;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Nike Air Max'**
  String get productNameHint;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 99.99'**
  String get priceHint;

  /// No description provided for @shortDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Short description...'**
  String get shortDescriptionHint;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @pleaseSelectAnImage.
  ///
  /// In en, this message translates to:
  /// **'Please select an image'**
  String get pleaseSelectAnImage;

  /// No description provided for @productAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully!'**
  String get productAddedSuccessfully;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get zipCode;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @userUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get userUpdatedSuccessfully;

  /// No description provided for @failedToUpdateUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to update user: {error}'**
  String failedToUpdateUser(Object error);

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @usersDetails.
  ///
  /// In en, this message translates to:
  /// **'Users Details'**
  String get usersDetails;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @totalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get totalOrders;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @customerStatistics.
  ///
  /// In en, this message translates to:
  /// **'Customer Statistics'**
  String get customerStatistics;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @viewOrders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get viewOrders;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @areYouSureDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get areYouSureDeleteUser;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @userDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'User deleted successfully'**
  String get userDeletedSuccessfully;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found'**
  String get noUserFound;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @administrator.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get administrator;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get menu;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM'**
  String get system;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No Orders'**
  String get noOrders;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotal;

  /// No description provided for @paymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// No description provided for @paymentProofUploaded.
  ///
  /// In en, this message translates to:
  /// **'Payment proof uploaded'**
  String get paymentProofUploaded;

  /// No description provided for @paymentProofNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Payment proof not uploaded'**
  String get paymentProofNotUploaded;

  /// No description provided for @viewPaymentProof.
  ///
  /// In en, this message translates to:
  /// **'View Payment Proof'**
  String get viewPaymentProof;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @orderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order updated successfully'**
  String get orderUpdatedSuccessfully;

  /// No description provided for @editBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Bank Account'**
  String get editBankAccount;

  /// No description provided for @addBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Bank Account'**
  String get addBankAccount;

  /// No description provided for @editBankInformation.
  ///
  /// In en, this message translates to:
  /// **'Edit Bank Information'**
  String get editBankInformation;

  /// No description provided for @bankInformation.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get bankInformation;

  /// No description provided for @updateBankAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Update the bank account information customers can use for bank transfers.'**
  String get updateBankAccountInfo;

  /// No description provided for @addBankAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Add the bank account customers can use for bank transfers.'**
  String get addBankAccountInfo;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @rib.
  ///
  /// In en, this message translates to:
  /// **'RIB'**
  String get rib;

  /// No description provided for @swiftBic.
  ///
  /// In en, this message translates to:
  /// **'SWIFT / BIC'**
  String get swiftBic;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (Optional)'**
  String get phoneOptional;

  /// No description provided for @customersCanUseAccount.
  ///
  /// In en, this message translates to:
  /// **'Customers can use this account for bank transfers.'**
  String get customersCanUseAccount;

  /// No description provided for @bankAccountUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bank account updated successfully'**
  String get bankAccountUpdatedSuccessfully;

  /// No description provided for @bankAccountAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Bank account added successfully'**
  String get bankAccountAddedSuccessfully;

  /// No description provided for @failedToUpdateBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to update bank account'**
  String get failedToUpdateBankAccount;

  /// No description provided for @failedToAddBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to add bank account'**
  String get failedToAddBankAccount;

  /// No description provided for @updateBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Update Bank Account'**
  String get updateBankAccount;

  /// No description provided for @saveBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Save Bank Account'**
  String get saveBankAccount;

  /// No description provided for @bankNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Bank name is required'**
  String get bankNameRequired;

  /// No description provided for @enterValidBankName.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid bank name'**
  String get enterValidBankName;

  /// No description provided for @accountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get accountNameRequired;

  /// No description provided for @enterValidAccountName.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid account name'**
  String get enterValidAccountName;

  /// No description provided for @ibanRequired.
  ///
  /// In en, this message translates to:
  /// **'IBAN is required'**
  String get ibanRequired;

  /// No description provided for @enterValidIban.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IBAN'**
  String get enterValidIban;

  /// No description provided for @invalidIbanLength.
  ///
  /// In en, this message translates to:
  /// **'Invalid IBAN length'**
  String get invalidIbanLength;

  /// No description provided for @ribRequired.
  ///
  /// In en, this message translates to:
  /// **'RIB is required'**
  String get ribRequired;

  /// No description provided for @ribExactly24Digits.
  ///
  /// In en, this message translates to:
  /// **'RIB must contain exactly 24 digits'**
  String get ribExactly24Digits;

  /// No description provided for @enterValidSwiftBic.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid SWIFT / BIC code'**
  String get enterValidSwiftBic;

  /// No description provided for @enterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterValidPhoneNumber;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @paymentBanks.
  ///
  /// In en, this message translates to:
  /// **'Payment Banks'**
  String get paymentBanks;

  /// No description provided for @bankAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Bank account disabled'**
  String get bankAccountDisabled;

  /// No description provided for @bankAccountEnabled.
  ///
  /// In en, this message translates to:
  /// **'Bank account enabled'**
  String get bankAccountEnabled;

  /// No description provided for @unableToUpdateBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to update bank account'**
  String get unableToUpdateBankAccount;

  /// No description provided for @deleteBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Bank Account'**
  String get deleteBankAccount;

  /// No description provided for @deleteBankConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{bankName}\"?\n\nCustomers will no longer be able to use this account for bank transfers.'**
  String deleteBankConfirmation(Object bankName);

  /// No description provided for @bankAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bank account deleted'**
  String get bankAccountDeleted;

  /// No description provided for @unableToDeleteBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete bank account'**
  String get unableToDeleteBankAccount;

  /// No description provided for @unableToLoadPaymentBanks.
  ///
  /// In en, this message translates to:
  /// **'Unable to load payment banks.'**
  String get unableToLoadPaymentBanks;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noBankAccountsYet.
  ///
  /// In en, this message translates to:
  /// **'No bank accounts yet'**
  String get noBankAccountsYet;

  /// No description provided for @addBankAccountToEnableTransfers.
  ///
  /// In en, this message translates to:
  /// **'Add a bank account to enable bank transfer payments.'**
  String get addBankAccountToEnableTransfers;

  /// No description provided for @unnamedBank.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Bank'**
  String get unnamedBank;

  /// No description provided for @accountNameNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Account name not provided'**
  String get accountNameNotProvided;

  /// No description provided for @bankOptions.
  ///
  /// In en, this message translates to:
  /// **'Bank options'**
  String get bankOptions;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateAdministratorPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your administrator password.'**
  String get updateAdministratorPassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get tooManyAttempts;

  /// No description provided for @pleaseSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again and retry.'**
  String get pleaseSignInAgain;

  /// No description provided for @exportOrders.
  ///
  /// In en, this message translates to:
  /// **'Export Orders'**
  String get exportOrders;

  /// No description provided for @unableToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile'**
  String get unableToLoadProfile;

  /// No description provided for @updateYourAdministratorProfile.
  ///
  /// In en, this message translates to:
  /// **'Update your administrator profile'**
  String get updateYourAdministratorProfile;

  /// No description provided for @updateYourAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateYourAccountPassword;

  /// No description provided for @application.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get application;

  /// No description provided for @manageNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage notification settings'**
  String get manageNotificationSettings;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @viewStoreAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View store analytics'**
  String get viewStoreAnalytics;

  /// No description provided for @manageProducts.
  ///
  /// In en, this message translates to:
  /// **'Manage Products'**
  String get manageProducts;

  /// No description provided for @addEditOrDeleteProducts.
  ///
  /// In en, this message translates to:
  /// **'Add, edit or delete products'**
  String get addEditOrDeleteProducts;

  /// No description provided for @manageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manageOrders;

  /// No description provided for @trackAndUpdateOrders.
  ///
  /// In en, this message translates to:
  /// **'Track and update orders'**
  String get trackAndUpdateOrders;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @viewRegisteredCustomers.
  ///
  /// In en, this message translates to:
  /// **'View registered customers'**
  String get viewRegisteredCustomers;

  /// No description provided for @exportAllOrders.
  ///
  /// In en, this message translates to:
  /// **'Export all orders'**
  String get exportAllOrders;

  /// No description provided for @backupDatabase.
  ///
  /// In en, this message translates to:
  /// **'Backup Database'**
  String get backupDatabase;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @manageBankTransferAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage bank transfer accounts'**
  String get manageBankTransferAccounts;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @version101.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version101;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @forSecurityReasonsSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please sign in again before deleting your account.'**
  String get forSecurityReasonsSignInAgain;

  /// No description provided for @failedToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get failedToDeleteAccount;

  /// No description provided for @permanentlyDeleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account?\n\nThis action cannot be undone.'**
  String get permanentlyDeleteAccountConfirmation;

  /// No description provided for @storePerformanceOverview.
  ///
  /// In en, this message translates to:
  /// **'Store performance overview'**
  String get storePerformanceOverview;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @businessOverview.
  ///
  /// In en, this message translates to:
  /// **'Business Overview'**
  String get businessOverview;

  /// No description provided for @businessHealth.
  ///
  /// In en, this message translates to:
  /// **'Business Health'**
  String get businessHealth;

  /// No description provided for @revenueGeneratedFromDeliveredOrders.
  ///
  /// In en, this message translates to:
  /// **'Revenue generated from delivered orders'**
  String get revenueGeneratedFromDeliveredOrders;

  /// No description provided for @usersRegistered.
  ///
  /// In en, this message translates to:
  /// **'{count} users registered'**
  String usersRegistered(int count);

  /// No description provided for @productsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} products available'**
  String productsAvailable(int count);

  /// No description provided for @ordersDeliveredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} orders delivered successfully'**
  String ordersDeliveredSuccessfully(int count);

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logoutConfirmation;

  /// No description provided for @pleaseSelectAtLeastOneCollection.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one collection'**
  String get pleaseSelectAtLeastOneCollection;

  /// No description provided for @saveDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Save Database Backup'**
  String get saveDatabaseBackup;

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'Backup cancelled'**
  String get backupCancelled;

  /// No description provided for @databaseBackupSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Database backup saved successfully'**
  String get databaseBackupSavedSuccessfully;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @selectDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Select Database Backup'**
  String get selectDatabaseBackup;

  /// No description provided for @unableToReadSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to read the selected file'**
  String get unableToReadSelectedFile;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file'**
  String get invalidBackupFile;

  /// No description provided for @restoreDatabase.
  ///
  /// In en, this message translates to:
  /// **'Restore Database?'**
  String get restoreDatabase;

  /// No description provided for @backupContains.
  ///
  /// In en, this message translates to:
  /// **'This backup contains:'**
  String get backupContains;

  /// No description provided for @collectionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} collections'**
  String collectionsCount(int count);

  /// No description provided for @documentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} documents'**
  String documentsCount(int count);

  /// No description provided for @existingDocumentsWillBeOverwritten.
  ///
  /// In en, this message translates to:
  /// **'Existing documents with the same IDs will be overwritten.'**
  String get existingDocumentsWillBeOverwritten;

  /// No description provided for @doYouWantToContinue.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get doYouWantToContinue;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @databaseRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Database restored successfully ({count} documents)'**
  String databaseRestoredSuccessfully(int count);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @databaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Database Backup'**
  String get databaseBackup;

  /// No description provided for @createBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a backup of your Firestore data and save it as a JSON file.'**
  String get createBackupDescription;

  /// No description provided for @selectData.
  ///
  /// In en, this message translates to:
  /// **'Select Data'**
  String get selectData;

  /// No description provided for @chooseCollectionsToInclude.
  ///
  /// In en, this message translates to:
  /// **'Choose which collections you want to include.'**
  String get chooseCollectionsToInclude;

  /// No description provided for @completedPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String completedPercentage(int percent);

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating Backup...'**
  String get creatingBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup'**
  String get restoreBackup;

  /// No description provided for @backupFirestoreOnly.
  ///
  /// In en, this message translates to:
  /// **'The backup contains Firestore data only. Product and profile images stored in Firebase Storage are not included in this JSON backup.'**
  String get backupFirestoreOnly;

  /// No description provided for @pleaseSelectProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile picture'**
  String get pleaseSelectProfilePicture;

  /// No description provided for @profilePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo *'**
  String get profilePhotoRequired;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @usernameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameIsRequired;

  /// No description provided for @enterAValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get enterAValidPhoneNumber;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @productDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeletedSuccessfully;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @deleteProductConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get deleteProductConfirmation;

  /// No description provided for @productOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'This product is out of stock.'**
  String get productOutOfStock;

  /// No description provided for @onlyItemsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Only {stock} items available.'**
  String onlyItemsAvailable(int stock);

  /// No description provided for @alreadyInCart.
  ///
  /// In en, this message translates to:
  /// **'This product is already in your cart.'**
  String get alreadyInCart;

  /// No description provided for @orderPlacedNotification.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderPlacedNotification;

  /// No description provided for @orderPlacedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your order {orderNumber} has been placed successfully.'**
  String orderPlacedNotificationBody(Object orderNumber);

  /// No description provided for @orderUpdatedNotification.
  ///
  /// In en, this message translates to:
  /// **'Order Updated'**
  String get orderUpdatedNotification;

  /// No description provided for @orderUpdatedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'Your order {orderNumber} is now {status}.'**
  String orderUpdatedNotificationBody(Object orderNumber, Object status);

  /// No description provided for @newProductNotification.
  ///
  /// In en, this message translates to:
  /// **'New Product'**
  String get newProductNotification;

  /// No description provided for @newProductNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'A new product has been added: {productName}.'**
  String newProductNotificationBody(Object productName);

  /// No description provided for @promotionNotification.
  ///
  /// In en, this message translates to:
  /// **'Special Offer'**
  String get promotionNotification;

  /// No description provided for @promotionNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{productName} is now on sale!'**
  String promotionNotificationBody(Object productName);

  /// No description provided for @tapAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Tap again to exit'**
  String get tapAgainToExit;

  /// Admin notification body for a new order
  ///
  /// In en, this message translates to:
  /// **'{userName} placed order {orderNumber}'**
  String newOrderNotificationBody(Object userName, Object orderNumber);

  /// No description provided for @enterStock.
  ///
  /// In en, this message translates to:
  /// **'Please enter stock quantity.'**
  String get enterStock;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
