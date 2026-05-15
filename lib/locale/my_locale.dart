import 'package:get/get_navigation/src/root/internacionalization.dart';

class MyLocale implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    // ================= ENGLISH =================
    'en': {
      // App
      'title': 'My eSouq',
      'my_esouq': 'My eSouq',

      // ================= Home & UI =================
      'home': 'Home',
      'categories': 'Categories',
      'settings': 'Settings',
      'cart': 'Cart',
      'profile': 'Profile',
      'all': 'All',
      'electronics': 'Electronics',
      'clothing': 'Clothing',
      'books': 'Books',
      'home_category': 'Home',
      'notifications': 'Notifications',
      'favourites': 'Favourites',
      'account_info': 'Account Information',
      'orders': 'Recent Orders',

      // Search & UI text
      'search_products': 'Search products',
      'featured_products': 'Featured Products',
      'see_all': 'See All',

      // ================= Auth =================
      'name': 'Full Name',
      'email': 'Email',
      'password': 'Password',
      'password_confirm': 'Confirm Password',
      'login': 'Login',
      'sign_in': 'Sign in',
      'create_account': 'Create Account',
      'welcome_back': 'Hi There!',
      'sitc': 'Sign in to continue!',
      'accept_terms_first': 'Accept terms first',
      'terms': 'I agree to the terms and conditions',
      'phone': 'Phone Number',

      // Validation
      'email_required': 'Email is required',
      'password_required': 'Password is required',

      // ================= Drawer / User =================
      'hi': 'HI',
      'guest': 'Guest',
      'language': 'Language',
      'english': 'English',
      'arabic': 'Arabic',
      'logout': 'Logout',

      // ================= Items =================
      'shirts': 'Shirts',
      'trousers': 'Trousers',
      'shoes': 'Shoes',
      'accessories': 'Accessories',

      // ================= Buying =================
      'subtotal': 'Subtotal',
      'total': 'Total',
      'delivery': 'Delivery',
      'checkout': 'Checkout',
      'your_cart_is_empty': 'Your cart is empty',
      'no_favourites_yet': 'No favourites yet',
      'save_items_you_like': 'Save items you like',
      'add_something': 'Add something from the store',
      'shop_now': 'Shop Now',
      'buy_now': 'Buy Now',
      'add_to_cart': 'Add to Cart',
    },

    // ================= ARABIC =================
    'ar': {
      // App
      'title': 'متجرنا الإلكتروني',
      'my_esouq': 'متجر السوق الالكتروني',

      // ================= Home & UI =================
      'home': 'الرئيسية',
      'categories': 'التصنيفات',
      'settings': 'الإعدادات',
      'cart': 'السلة',
      'profile': 'الحساب',
      'all': 'الكل',
      'electronics': 'إلكترونيات',
      'clothing': 'ملابس',
      'books': 'كتب',
      'home_category': 'منزل',
      'notifications': 'الإشعارات',
      'favourites': 'المفضلة',
      'account_info': 'معلومات الحساب',
      'orders': 'الطلبات',

      // Search & UI text
      'search_products': 'ابحث عن المنتجات',
      'featured_products': 'منتجات مميزة',
      'see_all': 'عرض الكل',

      // ================= Auth =================
      'name': 'الاسم الكامل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'password_confirm': 'تأكيد كلمة المرور',
      'login': 'تسجيل الدخول',
      'sign_in': 'تسجيل الدخول',
      'create_account': 'إنشاء حساب',
      'welcome_back': 'مرحبًا بك!',
      'sitc': 'الرجاء تسجيل الدخول للمتابعة!',
      'accept_terms_first': 'يرجى قبول الشروط أولاً',
      'terms': 'أوافق على الشروط والأحكام',
      'phone': 'رقم الهاتف',
      // Validation
      'email_required': 'البريد مطلوب',
      'password_required': 'كلمة المرور مطلوبة',

      // ================= Drawer / User =================
      'hi': 'مرحبا',
      'guest': 'ضيف',
      'language': 'اللغة',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'logout': 'تسجيل الخروج',

      // ================= Items =================
      'shirts': 'القمصان',
      'trousers': 'السروال',
      'shoes': 'الحذاء',
      'accessories': 'الأكسسوارات',

      // ================= Buying =================
      'subtotal': 'المجموع الفرعي',
      'total': 'المجموع',
      'delivery': 'التوصيل',
      'checkout': 'الدفع',
      'your_cart_is_empty': 'سلتك فارغة',
      'no_favourites_yet': 'لا توجد منتجات في المفضلة',
      'save_items_you_like': 'احفظ المنتجات التي تعجبك',
      'add_something': 'أضف شيئًا من المتجر',
      'shop_now': 'تسوق الآن',
      'buy_now': 'اشتر الآن',
      'add_to_cart': 'أضف إلى السلة',
    },
  };
}
