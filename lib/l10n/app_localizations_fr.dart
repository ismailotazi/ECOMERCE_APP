// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get enterEmail => 'Entrez votre e-mail';

  @override
  String get invalidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get min6Chars => '6 caractères minimum';

  @override
  String get accountCreatedVerifyEmail => 'Compte créé avec succès. Veuillez vérifier votre adresse e-mail avant de vous connecter.';

  @override
  String get emailAlreadyInUse => 'Cette adresse e-mail est déjà utilisée.';

  @override
  String get weakPassword => 'Le mot de passe est trop faible.';

  @override
  String get noInternetConnection => 'Aucune connexion Internet.';

  @override
  String get registrationFailed => 'Échec de la création du compte.';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String googleError(String error) {
    return 'Erreur Google : $error';
  }

  @override
  String get verifyYourEmailFirst => 'Veuillez d\'abord vérifier votre adresse e-mail';

  @override
  String get resend => 'Renvoyer';

  @override
  String get userDataNotFound => 'Données utilisateur introuvables.';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get login => 'Connexion';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get register => 'S\'inscrire';

  @override
  String get passwordResetEmailSent => 'L’e-mail de réinitialisation du mot de passe a été envoyé.';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get noUserFoundForEmail => 'Aucun utilisateur trouvé pour cette adresse e-mail';

  @override
  String get invalidEmailAddress => 'Adresse e-mail invalide';

  @override
  String get pleaseEnterYourEmail => 'Veuillez saisir votre adresse e-mail';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get enterEmailToResetPassword => 'Entrez votre e-mail pour réinitialiser votre mot de passe';

  @override
  String get verifyEmail => 'Vérifier l\'adresse e-mail';

  @override
  String get emailNotVerifiedYet => 'L\'adresse e-mail n\'est pas encore vérifiée.';

  @override
  String get verificationEmailSentSuccessfully => 'L\'e-mail de vérification a été envoyé avec succès.';

  @override
  String get verificationEmailMessage => 'Nous avons envoyé un e-mail de vérification dans votre boîte de réception.\nVeuillez vérifier votre adresse e-mail avant de continuer.';

  @override
  String get iveVerifiedMyEmail => 'J\'ai vérifié mon adresse e-mail';

  @override
  String get resendVerificationEmail => 'Renvoyer l\'e-mail de vérification';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get or => 'OU';

  @override
  String get searchProducts => 'Rechercher des produits';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get categories => 'Catégories';

  @override
  String get all => 'Tous';

  @override
  String get bestSelling => 'Meilleures ventes';

  @override
  String get smartphones => 'Smartphones';

  @override
  String get laptops => 'Ordinateurs portables';

  @override
  String get tablets => 'Tablettes';

  @override
  String get smartwatches => 'Montres connectées';

  @override
  String get audio => 'Audio';

  @override
  String get gaming => 'Jeux vidéo';

  @override
  String get electronics => 'Électronique';

  @override
  String get homeAppliances => 'Électroménager';

  @override
  String get perfumes => 'Parfums';

  @override
  String get beauty => 'Beauté';

  @override
  String get clothing => 'Vêtements';

  @override
  String get shoes => 'Chaussures';

  @override
  String get bags => 'Sacs';

  @override
  String get glasses => 'Lunettes';

  @override
  String get watches => 'Montres';

  @override
  String get jewelry => 'Bijoux';

  @override
  String get sports => 'Sports';

  @override
  String get books => 'Livres';

  @override
  String get toys => 'Jouets';

  @override
  String get furniture => 'Meubles';

  @override
  String get food => 'Alimentation';

  @override
  String get health => 'Santé';

  @override
  String get automotive => 'Automobile';

  @override
  String get other => 'Autre';

  @override
  String get home => 'Accueil';

  @override
  String get cart => 'Panier';

  @override
  String get favorite => 'Favoris';

  @override
  String get profile => 'Profil';

  @override
  String get rateThisProduct => 'Évaluez ce produit';

  @override
  String get tellUsAboutThisProduct => 'Parlez-nous de ce produit...';

  @override
  String get reviewSubmittedSuccessfully => 'Avis envoyé avec succès';

  @override
  String get submitReview => 'Envoyer l’avis';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get paymentMethods => 'Modes de paiement';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get helpAndSupport => 'Aide et assistance';

  @override
  String get contactSupport => 'Contacter l\'assistance';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get deleteFailed => 'Échec de la suppression';

  @override
  String get logoutFailed => 'Échec de la déconnexion';

  @override
  String get orderHistory => 'Historique des commandes';

  @override
  String get noOrderYet => 'Aucune commande pour le moment';

  @override
  String get pending => 'En attente';

  @override
  String get processing => 'En traitement';

  @override
  String get shipped => 'Expédiée';

  @override
  String get delivered => 'Livrée';

  @override
  String get cancelled => 'Annulée';

  @override
  String get order => 'Commande';

  @override
  String get product => 'Produit';

  @override
  String get firstNameIsRequired => 'Le prénom est obligatoire';

  @override
  String get firstNameMinLength => 'Le prénom doit contenir au moins 2 caractères';

  @override
  String get firstNameMaxLength => 'Le prénom ne doit pas dépasser 30 caractères';

  @override
  String get validFirstName => 'Veuillez saisir un prénom valide';

  @override
  String get lastNameIsRequired => 'Le nom est obligatoire';

  @override
  String get lastNameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get lastNameMaxLength => 'Le nom ne doit pas dépasser 30 caractères';

  @override
  String get validLastName => 'Veuillez saisir un nom valide';

  @override
  String get phoneNumberRequired => 'Numéro de téléphone (obligatoire)';

  @override
  String get pleaseEnterPhoneNumber => 'Veuillez saisir votre numéro de téléphone';

  @override
  String get countryRequired => 'Pays (obligatoire)';

  @override
  String get countryIsRequired => 'Le pays est obligatoire';

  @override
  String get countryNameTooShort => 'Le nom du pays est trop court';

  @override
  String get countryNameTooLong => 'Le nom du pays est trop long';

  @override
  String get validCountryName => 'Veuillez saisir un nom de pays valide';

  @override
  String get cityRequired => 'Ville (obligatoire)';

  @override
  String get cityIsRequired => 'La ville est obligatoire';

  @override
  String get cityNameTooShort => 'Le nom de la ville est trop court';

  @override
  String get validCityName => 'Veuillez saisir un nom de ville valide';

  @override
  String get streetAddressOptional => 'Adresse (facultatif)';

  @override
  String get additionalInformation => 'Informations supplémentaires';

  @override
  String get subscribedStores => 'Magasins abonnés';

  @override
  String get unsubscribedStores => 'Magasins non abonnés';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get clear => 'Effacer';

  @override
  String get noProductFound => 'Aucun produit trouvé';

  @override
  String get tryAnotherKeyword => 'Essayez avec un autre mot-clé.';

  @override
  String get noName => 'Sans nom';

  @override
  String get pleaseLogin => 'Veuillez vous connecter';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get orderId => 'ID de commande';

  @override
  String get status => 'Statut';

  @override
  String get total => 'Total';

  @override
  String get date => 'Date';

  @override
  String get productDetails => 'Détails du produit';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get optional => 'Facultatif';

  @override
  String get taxIncluded => 'Taxes incluses';

  @override
  String get writeReview => 'Écrire un avis';

  @override
  String get outOfStock => 'Rupture de stock';

  @override
  String itemsLeftInStock(Object count) {
    return 'Plus que $count articles en stock';
  }

  @override
  String get quantity => 'Quantité';

  @override
  String get description => 'Description';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible.';

  @override
  String get relatedProducts => 'Produits similaires';

  @override
  String get noRelatedProducts => 'Aucun produit similaire';

  @override
  String get customerReviews => 'Avis des clients';

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get noProducts => 'Aucun produit';

  @override
  String get qty => 'Qté';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get buyNow => 'Acheter maintenant';

  @override
  String get addedToCart => 'Ajouté au panier 🛒';

  @override
  String get unknown => 'Inconnu';

  @override
  String get reviews => 'Avis';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavoriteProducts => 'Aucun produit favori';

  @override
  String get removedFromFavorites => 'Retiré des favoris ❤️';

  @override
  String get checkout => 'Paiement';

  @override
  String get deliveryInformation => 'Informations de livraison';

  @override
  String get fullName => 'Nom complet';

  @override
  String get pleaseEnterYourFullName => 'Veuillez saisir votre nom complet';

  @override
  String get nameTooLong => 'Le nom est trop long';

  @override
  String get pleaseEnterAValidName => 'Veuillez saisir un nom valide';

  @override
  String get pleaseEnterYourFirstAndLastName => 'Veuillez saisir votre prénom et votre nom';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get address => 'Adresse';

  @override
  String get pleaseEnterYourAddress => 'Veuillez saisir votre adresse';

  @override
  String get pleaseEnterAMoreCompleteAddress => 'Veuillez saisir une adresse plus complète';

  @override
  String get addressTooLong => 'L\'adresse est trop longue';

  @override
  String get pleaseEnterYourCity => 'Veuillez saisir votre ville';

  @override
  String get cityNameTooLong => 'Le nom de la ville est trop long';

  @override
  String get pleaseEnterAValidCity => 'Veuillez saisir une ville valide';

  @override
  String get saveYourInformation => 'Enregistrer vos informations';

  @override
  String get forFasterCheckoutNextTime => 'Pour un paiement plus rapide la prochaine fois';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get cashOnDelivery => 'Paiement à la livraison';

  @override
  String get payWhenYourOrderArrives => 'Payez lorsque votre commande arrive';

  @override
  String get transferBeforeShipping => 'Effectuez le virement avant l\'expédition';

  @override
  String get orderSummary => 'Résumé de la commande';

  @override
  String get items => 'Articles';

  @override
  String get payment => 'Paiement';

  @override
  String get placeOrder => 'Passer la commande';

  @override
  String get orderPlacedSuccessfully => 'Commande passée avec succès 🎉';

  @override
  String get pleaseEnterYourPhoneNumber => 'Veuillez saisir votre numéro de téléphone';

  @override
  String get pleaseEnterAValidAddress => 'Veuillez saisir une adresse valide';

  @override
  String get pleaseEnterYourCountry => 'Veuillez entrer votre pays';

  @override
  String get pleaseEnterAValidCountry => 'Veuillez entrer un pays valide';

  @override
  String get yourCartIsEmpty => 'Votre panier est vide';

  @override
  String get selected => 'Sélectionné';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get pleaseSelectAtLeastOneProduct => 'Veuillez sélectionner au moins un produit';

  @override
  String get bankTransfer => 'Virement bancaire';

  @override
  String get unableToSelectImage => 'Impossible de sélectionner l\'image';

  @override
  String get noActiveBankAccountsAvailable => 'Aucun compte bancaire actif disponible';

  @override
  String get unableToLoadPaymentInformation => 'Impossible de charger les informations de paiement';

  @override
  String get copied => 'copié';

  @override
  String get copy => 'Copier';

  @override
  String get transferYourOrderTotalToTheBankAccountBelow => 'Transférez le montant total de votre commande vers le compte bancaire ci-dessous.';

  @override
  String get selectBankAccount => 'Sélectionner un compte bancaire';

  @override
  String get bankAccountDetails => 'Détails du compte bancaire';

  @override
  String get bank => 'Banque';

  @override
  String get email => 'E-mail';

  @override
  String get paymentProof => 'Preuve de paiement';

  @override
  String get uploadTransferScreenshot => 'Téléverser une capture du virement';

  @override
  String get tapToChooseAnImage => 'Appuyez pour choisir une image';

  @override
  String get paymentProofSelected => 'Preuve de paiement sélectionnée';

  @override
  String get afterCompletingTheTransfer => 'Après avoir effectué le virement, appuyez sur \"J\'ai effectué le virement\" pour continuer votre commande.';

  @override
  String get bankTransferCurrentlyUnavailable => 'Le virement bancaire est actuellement indisponible. Veuillez choisir un autre mode de paiement.';

  @override
  String get uploadFailed => 'Échec du téléchargement';

  @override
  String get iHaveTransferred => 'J\'ai effectué le virement';

  @override
  String get userNotLoggedIn => 'Utilisateur non connecté';

  @override
  String get language => 'Langue';

  @override
  String get chooseYourPreferredLanguage => 'Choisissez votre langue préférée';

  @override
  String get chooseLanguageDescription => 'Choisissez la langue que vous souhaitez utiliser dans l\'application.';

  @override
  String get english => 'Anglais';

  @override
  String get unitedStates => 'États-Unis';

  @override
  String get french => 'Français';

  @override
  String get france => 'France';

  @override
  String get arabic => 'Arabe';

  @override
  String get morocco => 'Maroc';

  @override
  String get systemDefault => 'Langue du système';

  @override
  String get followDeviceLanguage => 'Suivre la langue de l\'appareil';

  @override
  String get languageSavedSuccessfully => 'Langue enregistrée avec succès';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotificationsDescription => 'Gérez la façon dont vous recevez les mises à jour de l\'application.';

  @override
  String get orderUpdates => 'Mises à jour des commandes';

  @override
  String get orderUpdatesDescription => 'Recevez des mises à jour concernant vos commandes.';

  @override
  String get offersDiscounts => 'Offres et réductions';

  @override
  String get offersDiscountsDescription => 'Soyez informé des nouvelles offres.';

  @override
  String get promotionsDescription => 'Recevez des notifications promotionnelles.';

  @override
  String get emailNotifications => 'Notifications par e-mail';

  @override
  String get emailNotificationsDescription => 'Recevez les e-mails importants.';

  @override
  String get pushNotificationsFutureUpdate => 'Les notifications push avec Firebase Cloud Messaging seront disponibles dans une prochaine mise à jour.';

  @override
  String get theme => 'Thème';

  @override
  String get chooseYourPreferredTheme => 'Choisissez votre thème préféré';

  @override
  String get selectHowAppAppear => 'Sélectionnez l\'apparence que vous souhaitez pour l\'application.';

  @override
  String get light => 'Clair';

  @override
  String get alwaysUseLightMode => 'Toujours utiliser le mode clair';

  @override
  String get dark => 'Sombre';

  @override
  String get alwaysUseDarkMode => 'Toujours utiliser le mode sombre';

  @override
  String get followDeviceSettings => 'Suivre les paramètres de l\'appareil';

  @override
  String get themeSavedSuccessfully => 'Thème enregistré avec succès';

  @override
  String get failedToSaveTheme => 'Échec de l\'enregistrement du thème';

  @override
  String get add => 'Ajouter';

  @override
  String get orderStatusCannotBeChanged => 'Le statut de cette commande ne peut pas être modifié.';

  @override
  String get users => 'Utilisateurs';

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé';

  @override
  String get noEmail => 'Aucun e-mail';

  @override
  String deleteUserConfirmation(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer $name ?';
  }

  @override
  String get unableToLoadOrders => 'Impossible de charger les commandes.';

  @override
  String get noOrdersFound => 'Aucune commande trouvée';

  @override
  String get userHasNoOrders => 'Cet utilisateur n\'a encore passé aucune commande.';

  @override
  String orderNumber(Object orderNumber) {
    return 'Commande n°$orderNumber';
  }

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get completed => 'Terminé';

  @override
  String get usersOrders => 'Commandes de l\'utilisateur';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get dashboardSubtitle => 'Voici ce qui se passe aujourd\'hui';

  @override
  String get recentOrders => 'Commandes récentes';

  @override
  String get noRecentOrders => 'Aucune commande récente';

  @override
  String get totalRevenue => 'Chiffre d\'affaires total';

  @override
  String get average => 'Moyenne';

  @override
  String get account => 'Compte';

  @override
  String get storeManagement => 'Gestion des boutiques';

  @override
  String get admin => 'Administrateur';

  @override
  String get user => 'Utilisateur';

  @override
  String get noProductsAvailable => 'Aucun produit disponible';

  @override
  String get productDeleted => 'Produit supprimé';

  @override
  String get edit => 'Modifier';

  @override
  String get notificationSettings => 'Paramètres des notifications';

  @override
  String get chooseNotifications => 'Choisissez les notifications que vous souhaitez recevoir.';

  @override
  String get enableNotifications => 'Activer les notifications';

  @override
  String get turnAllNotificationsOnOrOff => 'Activer ou désactiver toutes les notifications';

  @override
  String get newOrders => 'Nouvelles commandes';

  @override
  String get receiveNotificationsForNewOrders => 'Recevoir des notifications pour les nouvelles commandes';

  @override
  String get newUsers => 'Nouveaux utilisateurs';

  @override
  String get notifyWhenCustomerRegisters => 'Être averti lorsqu\'un client s\'inscrit';

  @override
  String get lowStock => 'Stock faible';

  @override
  String get alertWhenProductsRunningOut => 'Alerter lorsque les produits sont presque épuisés';

  @override
  String get promotions => 'Promotions';

  @override
  String get marketingPromotionalNotifications => 'Notifications marketing et promotionnelles';

  @override
  String get sound => 'Son';

  @override
  String get playSoundWhenReceivingNotifications => 'Jouer un son lors de la réception de notifications';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateWhenReceivingNotifications => 'Vibrer lors de la réception de notifications';

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get allNotificationsMarkedAsRead => 'Toutes les notifications ont été marquées comme lues';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get notificationDeleted => 'Notification supprimée';

  @override
  String get newOrder => 'Nouvelle commande';

  @override
  String get newUser => 'Nouvel utilisateur';

  @override
  String get newProduct => 'Nouveau produit';

  @override
  String get warning => 'Avertissement';

  @override
  String get pleaseAddAtLeastOneImage => 'Veuillez ajouter au moins une image';

  @override
  String get productUpdatedSuccessfully => 'Produit mis à jour avec succès';

  @override
  String get selectImages => 'Sélectionner des images';

  @override
  String get replaceImage => 'Remplacer l\'image';

  @override
  String get deleteImage => 'Supprimer l\'image';

  @override
  String get productName => 'Nom du produit';

  @override
  String get enterProductName => 'Entrez le nom du produit';

  @override
  String get nameIsTooShort => 'Le nom est trop court';

  @override
  String get maximum25Characters => 'Maximum 25 caractères';

  @override
  String get nikeAirMaxHint => 'ex. Nike Air Max';

  @override
  String get enterDescription => 'Entrez la description';

  @override
  String get descriptionIsTooShort => 'La description est trop courte';

  @override
  String get maximum80Characters => 'Maximum 80 caractères';

  @override
  String get price => 'Prix';

  @override
  String get enterPrice => 'Entrez le prix';

  @override
  String get invalidPrice => 'Prix invalide';

  @override
  String get priceMustBeGreaterThanZero => 'Le prix doit être supérieur à 0';

  @override
  String get maximumPrice => 'Le prix maximum est de 99999.99';

  @override
  String get oldPrice => 'Ancien prix';

  @override
  String get invalidOldPrice => 'Ancien prix invalide';

  @override
  String get oldPriceMustBeGreaterThanZero => 'L\'ancien prix doit être supérieur à 0';

  @override
  String get stock => 'Stock';

  @override
  String get enterStockQuantity => 'Entrez la quantité en stock';

  @override
  String get invalidStock => 'Stock invalide';

  @override
  String get stockCannotBeNegative => 'Le stock ne peut pas être négatif';

  @override
  String get maximumStock => 'Le stock maximum est de 999999';

  @override
  String get category => 'Catégorie';

  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';

  @override
  String get brand => 'Marque';

  @override
  String get pleaseSelectBrand => 'Veuillez sélectionner une marque';

  @override
  String get updateProduct => 'Mettre à jour le produit';

  @override
  String get oldPriceHint => 'ex. 129.99';

  @override
  String get stockHint => 'ex. 25';

  @override
  String get accessories => 'Accessoires';

  @override
  String get editProduct => 'Modifier le produit';

  @override
  String get productNameHint => 'ex. Nike Air Max';

  @override
  String get error => 'Erreur';

  @override
  String get priceHint => 'ex. 99.99';

  @override
  String get shortDescriptionHint => 'Courte description...';

  @override
  String get gallery => 'Galerie';

  @override
  String get camera => 'Appareil photo';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get pleaseSelectAnImage => 'Veuillez sélectionner une image';

  @override
  String get productAddedSuccessfully => 'Produit ajouté avec succès !';

  @override
  String get addProduct => 'Ajouter un produit';

  @override
  String get editUser => 'Modifier l\'utilisateur';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get male => 'Homme';

  @override
  String get female => 'Femme';

  @override
  String get shippingAddress => 'Adresse de livraison';

  @override
  String get country => 'Pays';

  @override
  String get city => 'Ville';

  @override
  String get streetAddress => 'Adresse';

  @override
  String get firstNameRequired => 'Le prénom est obligatoire';

  @override
  String get lastNameRequired => 'Le nom est obligatoire';

  @override
  String get userUpdatedSuccessfully => 'Utilisateur mis à jour avec succès';

  @override
  String failedToUpdateUser(Object error) {
    return 'Échec de la mise à jour de l\'utilisateur : $error';
  }

  @override
  String get saving => 'Enregistrement...';

  @override
  String get usersDetails => 'Détails de l\'utilisateur';

  @override
  String get contactInformation => 'Coordonnées';

  @override
  String get totalOrders => 'Total des commandes';

  @override
  String get totalSpent => 'Total dépensé';

  @override
  String get memberSince => 'Membre depuis';

  @override
  String get customerStatistics => 'Statistiques du client';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get viewOrders => 'Voir les commandes';

  @override
  String get deleteUser => 'Supprimer l\'utilisateur';

  @override
  String get areYouSureDeleteUser => 'Êtes-vous sûr de vouloir supprimer cet utilisateur ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get userDeletedSuccessfully => 'Utilisateur supprimé avec succès';

  @override
  String get noUserFound => 'Aucun utilisateur trouvé';

  @override
  String get userNotFound => 'Utilisateur introuvable';

  @override
  String get administrator => 'Administrateur';

  @override
  String get menu => 'MENU';

  @override
  String get orders => 'Commandes';

  @override
  String get customers => 'Clients';

  @override
  String get products => 'Produits';

  @override
  String get revenue => 'Chiffre d\'affaires';

  @override
  String get analytics => 'Analyses';

  @override
  String get system => 'Système';

  @override
  String get settings => 'Paramètres';

  @override
  String get noOrders => 'Aucune commande';

  @override
  String get unknownUser => 'Utilisateur inconnu';

  @override
  String get customer => 'Client';

  @override
  String get orderTotal => 'Total de la commande';

  @override
  String get paymentInformation => 'Informations de paiement';

  @override
  String get paymentProofUploaded => 'Preuve de paiement téléchargée';

  @override
  String get paymentProofNotUploaded => 'Preuve de paiement non téléchargée';

  @override
  String get viewPaymentProof => 'Voir la preuve de paiement';

  @override
  String get orderStatus => 'Statut des commandes';

  @override
  String get orderUpdatedSuccessfully => 'Commande mise à jour avec succès';

  @override
  String get editBankAccount => 'Modifier le compte bancaire';

  @override
  String get addBankAccount => 'Ajouter un compte bancaire';

  @override
  String get editBankInformation => 'Modifier les informations bancaires';

  @override
  String get bankInformation => 'Informations bancaires';

  @override
  String get updateBankAccountInfo => 'Mettez à jour les informations du compte bancaire que les clients peuvent utiliser pour les virements bancaires.';

  @override
  String get addBankAccountInfo => 'Ajoutez le compte bancaire que les clients peuvent utiliser pour les virements bancaires.';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get accountName => 'Nom du titulaire';

  @override
  String get iban => 'IBAN';

  @override
  String get rib => 'RIB';

  @override
  String get swiftBic => 'SWIFT / BIC';

  @override
  String get phoneOptional => 'Téléphone (facultatif)';

  @override
  String get customersCanUseAccount => 'Les clients peuvent utiliser ce compte pour les virements bancaires.';

  @override
  String get bankAccountUpdatedSuccessfully => 'Compte bancaire mis à jour avec succès';

  @override
  String get bankAccountAddedSuccessfully => 'Compte bancaire ajouté avec succès';

  @override
  String get failedToUpdateBankAccount => 'Échec de la mise à jour du compte bancaire';

  @override
  String get failedToAddBankAccount => 'Échec de l\'ajout du compte bancaire';

  @override
  String get updateBankAccount => 'Mettre à jour le compte bancaire';

  @override
  String get saveBankAccount => 'Enregistrer le compte bancaire';

  @override
  String get bankNameRequired => 'Le nom de la banque est requis';

  @override
  String get enterValidBankName => 'Entrez un nom de banque valide';

  @override
  String get accountNameRequired => 'Le nom du titulaire est requis';

  @override
  String get enterValidAccountName => 'Entrez un nom de titulaire valide';

  @override
  String get ibanRequired => 'L\'IBAN est requis';

  @override
  String get enterValidIban => 'Entrez un IBAN valide';

  @override
  String get invalidIbanLength => 'Longueur de l\'IBAN invalide';

  @override
  String get ribRequired => 'Le RIB est requis';

  @override
  String get ribExactly24Digits => 'Le RIB doit contenir exactement 24 chiffres';

  @override
  String get enterValidSwiftBic => 'Entrez un code SWIFT / BIC valide';

  @override
  String get enterValidPhoneNumber => 'Entrez un numéro de téléphone valide';

  @override
  String get enterValidEmailAddress => 'Entrez une adresse e-mail valide';

  @override
  String get paymentBanks => 'Banques de paiement';

  @override
  String get bankAccountDisabled => 'Compte bancaire désactivé';

  @override
  String get bankAccountEnabled => 'Compte bancaire activé';

  @override
  String get unableToUpdateBankAccount => 'Impossible de mettre à jour le compte bancaire';

  @override
  String get deleteBankAccount => 'Supprimer le compte bancaire';

  @override
  String deleteBankConfirmation(Object bankName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$bankName\" ?\n\nLes clients ne pourront plus utiliser ce compte pour les virements bancaires.';
  }

  @override
  String get bankAccountDeleted => 'Compte bancaire supprimé';

  @override
  String get unableToDeleteBankAccount => 'Impossible de supprimer le compte bancaire';

  @override
  String get unableToLoadPaymentBanks => 'Impossible de charger les comptes bancaires.';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get noBankAccountsYet => 'Aucun compte bancaire pour le moment';

  @override
  String get addBankAccountToEnableTransfers => 'Ajoutez un compte bancaire pour activer les paiements par virement bancaire.';

  @override
  String get unnamedBank => 'Banque sans nom';

  @override
  String get accountNameNotProvided => 'Nom du compte non renseigné';

  @override
  String get bankOptions => 'Options du compte';

  @override
  String get disable => 'Désactiver';

  @override
  String get enable => 'Activer';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get updateAdministratorPassword => 'Mettez à jour votre mot de passe administrateur.';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get enterCurrentPassword => 'Entrez votre mot de passe actuel';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get confirmYourPassword => 'Confirmez votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe modifié avec succès';

  @override
  String get somethingWentWrong => 'Une erreur s’est produite';

  @override
  String get currentPasswordIncorrect => 'Le mot de passe actuel est incorrect';

  @override
  String get passwordTooWeak => 'Le mot de passe est trop faible';

  @override
  String get tooManyAttempts => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get pleaseSignInAgain => 'Veuillez vous reconnecter.';

  @override
  String get exportOrders => 'Exporter les commandes';

  @override
  String get unableToLoadProfile => 'Impossible de charger le profil';

  @override
  String get updateYourAdministratorProfile => 'Mettre à jour votre profil administrateur';

  @override
  String get updateYourAccountPassword => 'Mettre à jour le mot de passe de votre compte';

  @override
  String get application => 'Application';

  @override
  String get manageNotificationSettings => 'Gérer les paramètres de notification';

  @override
  String get administration => 'Administration';

  @override
  String get viewStoreAnalytics => 'Voir les statistiques de la boutique';

  @override
  String get manageProducts => 'Gérer les produits';

  @override
  String get addEditOrDeleteProducts => 'Ajouter, modifier ou supprimer des produits';

  @override
  String get manageOrders => 'Gérer les commandes';

  @override
  String get trackAndUpdateOrders => 'Suivre et mettre à jour les commandes';

  @override
  String get manageUsers => 'Gérer les utilisateurs';

  @override
  String get viewRegisteredCustomers => 'Voir les clients inscrits';

  @override
  String get exportAllOrders => 'Exporter toutes les commandes';

  @override
  String get backupDatabase => 'Sauvegarder la base de données';

  @override
  String get createBackup => 'Créer une sauvegarde';

  @override
  String get manageBankTransferAccounts => 'Gérer les comptes de virement bancaire';

  @override
  String get about => 'À propos';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get version101 => 'Version 1.0.0';

  @override
  String get accountDeletedSuccessfully => 'Compte supprimé avec succès';

  @override
  String get forSecurityReasonsSignInAgain => 'Pour des raisons de sécurité, veuillez vous reconnecter avant de supprimer votre compte.';

  @override
  String get failedToDeleteAccount => 'Échec de la suppression du compte';

  @override
  String get permanentlyDeleteAccountConfirmation => 'Êtes-vous sûr de vouloir supprimer définitivement votre compte ?\n\nCette action est irréversible.';

  @override
  String get storePerformanceOverview => 'Aperçu des performances de la boutique';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get success => 'Réussite';

  @override
  String get businessOverview => 'Vue d\'ensemble de l\'activité';

  @override
  String get businessHealth => 'État de l\'activité';

  @override
  String get revenueGeneratedFromDeliveredOrders => 'Chiffre d\'affaires généré par les commandes livrées';

  @override
  String usersRegistered(int count) {
    return '$count utilisateurs inscrits';
  }

  @override
  String productsAvailable(int count) {
    return '$count produits disponibles';
  }

  @override
  String ordersDeliveredSuccessfully(int count) {
    return '$count commandes livrées avec succès';
  }

  @override
  String get logoutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get pleaseSelectAtLeastOneCollection => 'Veuillez sélectionner au moins une collection';

  @override
  String get saveDatabaseBackup => 'Enregistrer la sauvegarde de la base de données';

  @override
  String get backupCancelled => 'Sauvegarde annulée';

  @override
  String get databaseBackupSavedSuccessfully => 'Sauvegarde de la base de données enregistrée avec succès';

  @override
  String backupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get selectDatabaseBackup => 'Sélectionner une sauvegarde de la base de données';

  @override
  String get unableToReadSelectedFile => 'Impossible de lire le fichier sélectionné';

  @override
  String get invalidBackupFile => 'Fichier de sauvegarde invalide';

  @override
  String get restoreDatabase => 'Restaurer la base de données ?';

  @override
  String get backupContains => 'Cette sauvegarde contient :';

  @override
  String collectionsCount(int count) {
    return '$count collections';
  }

  @override
  String documentsCount(int count) {
    return '$count documents';
  }

  @override
  String get existingDocumentsWillBeOverwritten => 'Les documents existants ayant les mêmes identifiants seront écrasés.';

  @override
  String get doYouWantToContinue => 'Voulez-vous continuer ?';

  @override
  String get restore => 'Restaurer';

  @override
  String databaseRestoredSuccessfully(int count) {
    return 'Restauration terminée : $count nouveaux documents ajoutés';
  }

  @override
  String restoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get databaseBackup => 'Sauvegarde de la base de données';

  @override
  String get createBackupDescription => 'Créez une sauvegarde de vos données Firestore et enregistrez-la sous forme de fichier JSON.';

  @override
  String get selectData => 'Sélectionner les données';

  @override
  String get chooseCollectionsToInclude => 'Choisissez les collections à inclure.';

  @override
  String completedPercentage(int percent) {
    return '$percent % terminé';
  }

  @override
  String get creatingBackup => 'Création de la sauvegarde...';

  @override
  String get restoreBackup => 'Restaurer la sauvegarde';

  @override
  String get backupFirestoreOnly => 'La sauvegarde contient uniquement les données Firestore. Les images des produits et des profils stockées dans Firebase Storage ne sont pas incluses dans cette sauvegarde JSON.';

  @override
  String get pleaseSelectProfilePicture => 'Veuillez sélectionner une photo de profil';

  @override
  String get profilePhotoRequired => 'Photo de profil *';

  @override
  String get changeProfilePhoto => 'Modifier la photo de profil';

  @override
  String get enterAValidPhoneNumber => 'Entrez un numéro de téléphone valide';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get productDeletedSuccessfully => 'Produit supprimé avec succès';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String get statistics => 'Statistiques';

  @override
  String get rating => 'Évaluation';

  @override
  String get discount => 'Réduction';

  @override
  String get deleteProduct => 'Supprimer le produit';

  @override
  String get deleteProductConfirmation => 'Êtes-vous sûr de vouloir supprimer ce produit ?';

  @override
  String get productOutOfStock => 'Ce produit est en rupture de stock.';

  @override
  String onlyItemsAvailable(int stock) {
    return 'Seulement $stock articles disponibles.';
  }

  @override
  String get alreadyInCart => 'Ce produit est déjà dans votre panier.';

  @override
  String get orderPlacedNotification => 'Commande passée';

  @override
  String orderPlacedNotificationBody(Object orderNumber) {
    return 'Votre commande $orderNumber a été passée avec succès.';
  }

  @override
  String get orderUpdatedNotification => 'Commande mise à jour';

  @override
  String orderUpdatedNotificationBody(Object orderNumber, Object status) {
    return 'Votre commande $orderNumber est maintenant $status.';
  }

  @override
  String get newProductNotification => 'Nouveau produit';

  @override
  String newProductNotificationBody(Object productName) {
    return 'Un nouveau produit a été ajouté : $productName.';
  }

  @override
  String get promotionNotification => 'Offre spéciale';

  @override
  String promotionNotificationBody(Object productName) {
    return '$productName est maintenant en promotion !';
  }

  @override
  String get tapAgainToExit => 'Appuyez à nouveau pour quitter';

  @override
  String newOrderNotificationBody(Object userName, Object orderNumber) {
    return '$userName a passé la commande $orderNumber';
  }

  @override
  String get enterStock => 'Veuillez saisir la quantité en stock.';

  @override
  String get createNewStoreForPlatform => 'Créez une nouvelle boutique pour votre plateforme.';

  @override
  String get exampleMiloMall => 'Exemple : Milo Mall';

  @override
  String get exampleMiloMallId => 'Exemple : milo_mall';

  @override
  String get pleaseEnterStoreName => 'Veuillez saisir le nom de la boutique.';

  @override
  String get storeNameTooShort => 'Le nom de la boutique est trop court.';

  @override
  String get storeId => 'ID de la boutique';

  @override
  String get pleaseEnterStoreId => 'Veuillez saisir l’ID de la boutique.';

  @override
  String get storeIdTooShort => 'L’ID de la boutique est trop court.';

  @override
  String get storeIdCharactersError => 'Utilisez uniquement des lettres minuscules, des chiffres et _.';

  @override
  String get storeActive => 'Boutique active';

  @override
  String get usersCanAccessStore => 'Les utilisateurs peuvent accéder à cette boutique.';

  @override
  String get usersCannotAccessStore => 'Les utilisateurs ne peuvent pas accéder à cette boutique.';

  @override
  String get storeIdAlreadyExists => 'Cet ID de boutique existe déjà.';

  @override
  String get storeCreatedSuccessfully => 'Boutique créée avec succès.';

  @override
  String get createAdministrator => 'Créer un administrateur';

  @override
  String get createAdminAssignStore => 'Créez un administrateur et attribuez-le à une boutique.';

  @override
  String get pleaseEnterFirstName => 'Veuillez saisir le prénom.';

  @override
  String get pleaseEnterLastName => 'Veuillez saisir le nom.';

  @override
  String get pleaseEnterEmail => 'Veuillez saisir l\'adresse e-mail.';

  @override
  String get pleaseEnterValidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get pleaseEnterPassword => 'Veuillez saisir un mot de passe.';

  @override
  String get passwordMinCharacters => 'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get assignStore => 'Attribuer une boutique';

  @override
  String get unableToLoadStores => 'Impossible de charger les boutiques.';

  @override
  String get noActiveStoresAvailable => 'Aucune boutique active disponible.';

  @override
  String get adminCreatedSuccessfully => 'Administrateur créé avec succès';

  @override
  String get failedToCreateAdmin => 'Échec de la création de l’administrateur.';

  @override
  String get stores => 'Boutiques';

  @override
  String get createStore => 'Créer une boutique';

  @override
  String get noStoresYet => 'Aucune boutique pour le moment';

  @override
  String get superAdmin => 'Super administrateur';

  @override
  String get platformOverview => 'Vue d’ensemble de la plateforme';

  @override
  String get manageAllStoresAndAdmins => 'Gérez toutes les boutiques et les administrateurs.';

  @override
  String get management => 'Gestion';

  @override
  String get manageStores => 'Gérer les boutiques';

  @override
  String get createEditManageAllStores => 'Créez, modifiez et gérez toutes les boutiques.';

  @override
  String get manageAdmins => 'Gérer les administrateurs';

  @override
  String get createAdminsAndAssignStores => 'Créez des administrateurs et attribuez-les à des boutiques.';

  @override
  String get ordersCompleted => 'Commandes terminées';

  @override
  String get admins => 'Administrateurs';

  @override
  String get createAdmin => 'Créer un administrateur';

  @override
  String get noAdminsYet => 'Aucun administrateur pour le moment';

  @override
  String get noStoreAssigned => 'Aucune boutique attribuée';

  @override
  String get storeInformation => 'Informations sur la boutique';

  @override
  String get storeName => 'Nom de la boutique';

  @override
  String get pleaseSelectStore => 'Veuillez sélectionner un magasin.';

  @override
  String get security => 'Sécurité';

  @override
  String get passwordResetDescription => 'Envoyer un lien de réinitialisation du mot de passe à votre adresse e-mail.';

  @override
  String get appearance => 'Apparence';

  @override
  String get adminManagement => 'Gestion des administrateurs';

  @override
  String get platform => 'Plateforme';

  @override
  String get aboutMiloMall => 'À propos de Milo Mall';

  @override
  String get saasMarketplacePlatform => 'Plateforme marketplace SaaS Milo Mall';

  @override
  String get emailVerified => 'E-mail vérifié';

  @override
  String get emailNotVerified => 'E-mail non vérifié';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get close => 'Fermer';

  @override
  String get editStore => 'Modifier le magasin';

  @override
  String get updateStoreInformation => 'Mettez à jour les informations de votre magasin.';

  @override
  String get removeStoreLogo => 'Supprimer le logo du magasin';

  @override
  String get storeUpdatedSuccessfully => 'Magasin mis à jour avec succès.';

  @override
  String get store => 'Magasin';

  @override
  String get editAdmin => 'Modifier l\'administrateur';

  @override
  String get since => 'Depuis';

  @override
  String get adminInformation => 'Informations de l\'administrateur';

  @override
  String get updateAdminInformation => 'Mettez à jour les informations de l\'administrateur.';

  @override
  String get adminUpdatedSuccessfully => 'Administrateur mis à jour avec succès.';

  @override
  String get permissionDenied => 'Vous n\'avez pas l\'autorisation d\'effectuer cette action.';

  @override
  String get adminOrStoreNotFound => 'Administrateur ou magasin introuvable.';

  @override
  String get emailAlreadyExists => 'Un compte avec cet e-mail existe déjà.';

  @override
  String get storeInactive => 'Le magasin sélectionné est inactif.';

  @override
  String get invalidAdminInformation => 'Les informations de l\'administrateur sont invalides.';

  @override
  String get adminUpdateSecurityInfo => 'Les modifications de l\'administrateur sont traitées de manière sécurisée via le service d\'administration de la plateforme.';

  @override
  String get allStores => 'Toutes les boutiques';

  @override
  String get allAdmins => 'Tous les administrateurs';

  @override
  String get totalStores => 'Total des boutiques';

  @override
  String get activeStores => 'Boutiques actives';

  @override
  String get noStores => 'Aucune boutique trouvée';

  @override
  String get noAdmins => 'Aucun administrateur trouvé';

  @override
  String get totalAdmins => 'Total des administrateurs';

  @override
  String get computers => 'Informatique';

  @override
  String get fashion => 'Mode';

  @override
  String get lifestyle => 'Style de vie';

  @override
  String placedNewOrder(Object userName) {
    return '$userName a passé une nouvelle commande';
  }

  @override
  String get currencySymbol => 'MAD';

  @override
  String get whatsappNumber => 'Numéro WhatsApp';

  @override
  String get enterWhatsappNumber => 'Veuillez saisir le numéro WhatsApp';

  @override
  String get invalidWhatsappNumber => 'Veuillez saisir un numéro WhatsApp valide';

  @override
  String get accountInactive => 'Votre compte est inactif. Veuillez contacter l\'administrateur du magasin.';

  @override
  String get chooseYourStore => 'Choisissez votre boutique';

  @override
  String get selectStoreToContinue => 'Sélectionnez une boutique pour continuer';

  @override
  String get noStoresAvailableAtMoment => 'Aucune boutique n’est disponible pour le moment.';

  @override
  String get oldPriceMustBeGreaterThanPrice => 'L’ancien prix doit être supérieur au prix actuel.';

  @override
  String get confirm => 'Confirmer';

  @override
  String get oldPriceMustBeHigher => 'L’ancien prix doit être supérieur au prix actuel';

  @override
  String get productRemovedByAdmin => 'Ce produit n’est plus disponible car il a été supprimé par l’administrateur.';

  @override
  String get subscriptionCenterTitle => 'Centre des abonnements';

  @override
  String get subscriptionCenterSubtitle => 'Gérez les forfaits mensuels et les dates de paiement';

  @override
  String get subscriptionTotalStores => 'Nombre total de boutiques';

  @override
  String get subscriptionConfigured => 'Configurés';

  @override
  String get subscriptionDueSoon => 'Bientôt à échéance';

  @override
  String get subscriptionOverdue => 'En retard';

  @override
  String get subscriptionExpectedRevenue => 'Revenu mensuel prévu';

  @override
  String get subscriptionStoreSubscriptions => 'Abonnements des boutiques';

  @override
  String get subscriptionFilterAll => 'Tous';

  @override
  String get subscriptionStatusActive => 'Actif';

  @override
  String get subscriptionStatusDueSoon => 'Bientôt à échéance';

  @override
  String get subscriptionStatusOverdue => 'En retard';

  @override
  String get subscriptionStatusNotConfigured => 'Non configuré';

  @override
  String get subscriptionNoStores => 'Aucune boutique ne correspond à ce filtre.';

  @override
  String get subscriptionOverdueNote => 'Les abonnements en retard affichent uniquement une alerte ici. L’activation des boutiques est gérée séparément.';

  @override
  String get subscriptionManageTitle => 'Gérer l’abonnement';

  @override
  String get subscriptionMonthlyPrice => 'Prix mensuel (MAD)';

  @override
  String get subscriptionPriceHint => 'Ex. : 150';

  @override
  String get subscriptionNextPayment => 'Prochaine date de paiement';

  @override
  String get subscriptionNotSet => 'Non définie';

  @override
  String get subscriptionSaveNote => 'Ces informations sont uniquement enregistrées. Aucun paiement n’est enregistré et la boutique n’est pas désactivée.';

  @override
  String get subscriptionInvalidPrice => 'Saisissez un prix mensuel valide.';

  @override
  String get subscriptionSelectPaymentDate => 'Veuillez sélectionner la prochaine date de paiement.';

  @override
  String get subscriptionSaving => 'Enregistrement...';

  @override
  String get subscriptionSave => 'Enregistrer l’abonnement';

  @override
  String get subscriptionStoreEnabled => 'Boutique activée';

  @override
  String get subscriptionStoreDisabled => 'Boutique désactivée';

  @override
  String get subscriptionLoadError => 'Impossible de charger les abonnements.';

  @override
  String subscriptionUpdatedFor(String storeName) {
    return 'Abonnement mis à jour pour $storeName.';
  }

  @override
  String subscriptionSaveError(String error) {
    return 'Impossible d’enregistrer l’abonnement : $error';
  }

  @override
  String get subscriptions => 'Abonnements';

  @override
  String get accessDeniedSuperAdminOnly => 'Accès refusé. Réservé au SuperAdmin.';

  @override
  String get selectAtLeastOneCollection => 'Sélectionnez au moins une collection à sauvegarder.';

  @override
  String get existingDocumentsKeptUnchanged => 'Les documents existants resteront inchangés.';

  @override
  String get onlyNewDocumentsAdded => 'Seuls les nouveaux documents seront ajoutés.';

  @override
  String restoreFinished(int added, int skipped) {
    return 'Restauration terminée : $added documents ajoutés, $skipped documents ignorés.';
  }

  @override
  String get storeSubscriptionSignInAgain => 'Veuillez vous reconnecter.';

  @override
  String get storeSubscriptionNoStore => 'Aucun magasin n\'est associé à ce compte.';

  @override
  String get storeSubscriptionStoreNotFound => 'Magasin introuvable.';

  @override
  String get storeSubscriptionChooseFileType => 'Choisissez un fichier JPG, PNG, WEBP ou PDF.';

  @override
  String get storeSubscriptionFileTooLarge => 'Le fichier doit faire moins de 10 Mo.';

  @override
  String get storeSubscriptionFileReadError => 'Impossible de lire le fichier sélectionné.';

  @override
  String storeSubscriptionFileSelectError(Object error) {
    return 'Impossible de sélectionner le fichier : $error';
  }

  @override
  String get storeSubscriptionSelectDateAndProof => 'Veuillez d\'abord sélectionner la date du virement et le justificatif.';

  @override
  String get storeSubscriptionFileUnavailable => 'Le fichier sélectionné n\'est plus disponible. Veuillez le sélectionner à nouveau.';

  @override
  String get storeSubscriptionPriceNotConfigured => 'Le prix de l\'abonnement n\'a pas été configuré.';

  @override
  String get storeSubscriptionBankUnavailable => 'Le compte bancaire pour l\'abonnement est actuellement indisponible.';

  @override
  String get storeSubscriptionPaymentSubmitted => 'Justificatif de paiement envoyé. Votre paiement est en attente de vérification.';

  @override
  String storeSubscriptionSubmitPaymentError(Object error) {
    return 'Impossible d\'envoyer le paiement : $error';
  }

  @override
  String get storeSubscriptionTitle => 'Abonnement et paiements';

  @override
  String get storeSubscriptionYourSubscription => 'Votre abonnement';

  @override
  String get storeSubscriptionPriceLabel => 'Prix de l\'abonnement';

  @override
  String get storeSubscriptionNextPaymentDate => 'Date du prochain paiement';

  @override
  String get storeSubscriptionStatusLabel => 'Statut de l\'abonnement';

  @override
  String get storeSubscriptionBankTransfer => 'Virement bancaire';

  @override
  String get storeSubscriptionBankUnavailableContact => 'Le virement bancaire est actuellement indisponible. Veuillez contacter le support.';

  @override
  String get storeSubscriptionBankTransferDetails => 'Coordonnées bancaires';

  @override
  String get storeSubscriptionTransferInstructions => 'Effectuez le virement du montant de l\'abonnement vers ce compte.';

  @override
  String get storeSubscriptionBankName => 'Nom de la banque';

  @override
  String get storeSubscriptionAccountHolder => 'Titulaire du compte';

  @override
  String get storeSubscriptionRib => 'RIB';

  @override
  String get storeSubscriptionIban => 'IBAN';

  @override
  String get storeSubscriptionSwiftBic => 'SWIFT/BIC';

  @override
  String get storeSubscriptionSubmitProofTitle => 'Envoyer un justificatif de paiement';

  @override
  String get storeSubscriptionUploadReceiptSubtitle => 'Téléversez votre reçu de virement pour une vérification manuelle.';

  @override
  String get storeSubscriptionTransferDate => 'Date du virement';

  @override
  String get storeSubscriptionTransactionReferenceOptional => 'Référence de transaction (facultatif)';

  @override
  String get storeSubscriptionTransactionReferenceHint => 'Saisissez la référence de votre transaction bancaire';

  @override
  String get storeSubscriptionTransferReceiptRequired => 'Justificatif du virement *';

  @override
  String get storeSubscriptionChooseImageOrPdf => 'Choisir une image ou un PDF';

  @override
  String get storeSubscriptionAllowedFileTypes => 'JPG, PNG, WEBP ou PDF · 10 Mo maximum';

  @override
  String get storeSubscriptionBrowseFiles => 'Parcourir les fichiers';

  @override
  String get storeSubscriptionChangeFile => 'Changer de fichier';

  @override
  String get storeSubscriptionSubmitting => 'Envoi en cours...';

  @override
  String get storeSubscriptionSubmitForVerification => 'Envoyer pour vérification';

  @override
  String get storeSubscriptionManualVerificationNotice => 'L\'envoi du justificatif ne renouvelle pas automatiquement votre abonnement. Votre paiement doit être vérifié par l\'administrateur de la plateforme.';

  @override
  String get storeSubscriptionPaymentHistory => 'Historique des paiements';

  @override
  String get storeSubscriptionPaymentHistorySubtitle => 'Suivez vos demandes de paiement d\'abonnement.';

  @override
  String storeSubscriptionLoadHistoryError(Object error) {
    return 'Impossible de charger l\'historique des paiements : $error';
  }

  @override
  String get storeSubscriptionNoPayments => 'Aucun paiement d\'abonnement envoyé pour le moment.';

  @override
  String get storeSubscriptionPaymentApproved => 'Approuvé';

  @override
  String get storeSubscriptionPaymentRejected => 'Rejeté';

  @override
  String get storeSubscriptionPaymentPendingReview => 'En attente de vérification';

  @override
  String get storeSubscriptionReference => 'Référence';

  @override
  String get storeSubscriptionAdminNote => 'Note de l\'administrateur';

  @override
  String storeSubscriptionLoadDetailsError(Object error) {
    return 'Impossible de charger les détails de l\'abonnement : $error';
  }

  @override
  String get storeSubscriptionLoadBankError => 'Impossible de charger les coordonnées bancaires. Veuillez contacter le support.';

  @override
  String get storeSubscriptionManageTitle => 'Gérer votre abonnement';

  @override
  String get storeSubscriptionManageSubtitle => 'Consultez votre forfait, effectuez le paiement et envoyez votre reçu pour vérification.';

  @override
  String get storeSubscriptionTryAgain => 'Réessayer';

  @override
  String get storeSubscriptionMonthlyPlan => 'Mensuel';

  @override
  String get reviewSubscriptionPayments => 'Vérifier les paiements d’abonnement';

  @override
  String get reviewSubscriptionPaymentsSubtitle => 'Vérifiez les virements bancaires et approuvez ou refusez les paiements.';

  @override
  String get subscriptionPayments => 'Paiements des abonnements';

  @override
  String get subscriptionAndPayments => 'Abonnement et paiements';

  @override
  String get manageAllSubscriptions => 'Gérer tous les abonnements';

  @override
  String get subscriptionPaymentPending => 'En attente';

  @override
  String get subscriptionPaymentAll => 'Tous';

  @override
  String get subscriptionPaymentProof => 'Justificatif de paiement';

  @override
  String get subscriptionPaymentNoProof => 'Aucun justificatif de paiement n’a été fourni.';

  @override
  String get subscriptionPaymentOpenUploadedFile => 'Ouvrez le fichier envoyé à l’aide du lien ci-dessous :';

  @override
  String subscriptionPaymentCouldNotOpenProof(Object error) {
    return 'Impossible d’ouvrir le justificatif de paiement : $error';
  }

  @override
  String get subscriptionPaymentApproveTitle => 'Approuver le paiement';

  @override
  String get subscriptionPaymentRejectTitle => 'Rejeter le paiement';

  @override
  String get subscriptionPaymentRejectionReason => 'Motif du rejet *';

  @override
  String get subscriptionPaymentReviewNoteOptional => 'Note de vérification (facultative)';

  @override
  String get subscriptionPaymentRequestMissing => 'La demande de paiement n’existe plus.';

  @override
  String get subscriptionPaymentMissingStoreId => 'La demande de paiement ne contient aucun identifiant de boutique.';

  @override
  String get subscriptionPaymentStoreMissing => 'La boutique n’existe pas.';

  @override
  String get subscriptionPaymentAlreadyReviewed => 'Ce paiement a déjà été vérifié.';

  @override
  String get subscriptionPaymentApprovedUpdated => 'Paiement approuvé et abonnement mis à jour.';

  @override
  String get subscriptionPaymentRejectedMessage => 'Paiement rejeté.';

  @override
  String subscriptionPaymentReviewError(Object error) {
    return 'Impossible de vérifier le paiement : $error';
  }

  @override
  String get subscriptionPaymentBank => 'Banque';

  @override
  String get subscriptionPaymentTransferReference => 'Référence du virement';

  @override
  String get subscriptionPaymentTransferDate => 'Date du virement';

  @override
  String get subscriptionPaymentSubmitted => 'Soumis le';

  @override
  String get subscriptionPaymentViewProof => 'Voir le justificatif de paiement';

  @override
  String subscriptionPaymentLoadError(Object error) {
    return 'Impossible de charger les demandes de paiement :\n$error';
  }

  @override
  String get subscriptionPaymentNoRequests => 'Aucune demande de paiement trouvée.';

  @override
  String get save => 'Enregistrer';

  @override
  String get activeBankDetailsVisibleToStoreAdmins => 'Les coordonnées bancaires actives sont visibles par les administrateurs des boutiques.';

  @override
  String get paymentInstructions => 'Instructions de paiement';

  @override
  String get subscriptionBankAccount => 'Compte bancaire d’abonnement';

  @override
  String get couldNotLoadBankDetails => 'Impossible de charger les coordonnées bancaires';

  @override
  String get bankDetailsSavedSuccessfully => 'Coordonnées bancaires enregistrées avec succès';

  @override
  String get storeCategories => 'Catégories de la boutique';

  @override
  String get selectStoreCategories => 'Sélectionnez les catégories disponibles dans cette boutique';

  @override
  String get androidPhones => 'Téléphones Android';

  @override
  String get iphones => 'iPhones';

  @override
  String get phoneAccessories => 'Accessoires pour téléphones';

  @override
  String get desktopComputers => 'Ordinateurs de bureau';

  @override
  String get computerAccessories => 'Accessoires informatiques';

  @override
  String get monitors => 'Écrans';

  @override
  String get printers => 'Imprimantes';

  @override
  String get televisions => 'Téléviseurs';

  @override
  String get cameras => 'Appareils photo';

  @override
  String get smartHome => 'Maison connectée';

  @override
  String get electronicAccessories => 'Accessoires électroniques';

  @override
  String get women => 'Femmes';

  @override
  String get men => 'Hommes';

  @override
  String get kids => 'Enfants';

  @override
  String get unisex => 'Unisexe';

  @override
  String get sunglasses => 'Lunettes de soleil';

  @override
  String get wallets => 'Portefeuilles';

  @override
  String get skincare => 'Soins de la peau';

  @override
  String get makeup => 'Maquillage';

  @override
  String get bodyCare => 'Soins du corps';

  @override
  String get hairCare => 'Soins capillaires';

  @override
  String get livingRoom => 'Salon';

  @override
  String get bedroom => 'Chambre à coucher';

  @override
  String get office => 'Bureau';

  @override
  String get kitchen => 'Cuisine';

  @override
  String get outdoorFurniture => 'Mobilier d’extérieur';

  @override
  String get fitness => 'Fitness';

  @override
  String get training => 'Entraînement';

  @override
  String get sportswear => 'Vêtements de sport';

  @override
  String get sportsEquipment => 'Équipements sportifs';

  @override
  String get consoles => 'Consoles';

  @override
  String get games => 'Jeux';

  @override
  String get gamingAccessories => 'Accessoires de gaming';

  @override
  String get otherProducts => 'Autres produits';

  @override
  String get gold => 'Or';

  @override
  String get silver => 'Argent';

  @override
  String get rings => 'Bagues';

  @override
  String get necklaces => 'Colliers';

  @override
  String get bracelets => 'Bracelets';

  @override
  String get anklets => 'Bracelets de cheville';

  @override
  String get earrings => 'Boucles d’oreilles';

  @override
  String get goldChains => 'Chaînes en or';

  @override
  String get silverChains => 'Chaînes en argent';

  @override
  String get pendants => 'Pendentifs';

  @override
  String get goldSets => 'Parures en or';

  @override
  String get silverSets => 'Parures en argent';

  @override
  String get crownsAndTiaras => 'Couronnes et diadèmes';

  @override
  String get otherGoldJewelry => 'Autres bijoux en or';

  @override
  String get otherSilverJewelry => 'Autres bijoux en argent';

  @override
  String get continueAsGuest => 'Continuer en tant qu’invité';

  @override
  String get subcategory => 'Sous-catégorie';

  @override
  String get pleaseSelectSubcategory => 'Veuillez sélectionner une sous-catégorie';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ?';

  @override
  String get signIn => 'Se connecter';
}
