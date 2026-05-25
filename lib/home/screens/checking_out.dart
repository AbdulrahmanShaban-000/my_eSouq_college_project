import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CheckingOutPage extends StatefulWidget {
  const CheckingOutPage({super.key});

  @override
  State<CheckingOutPage> createState() => _CheckingOutPageState();
}

class _CheckingOutPageState extends State<CheckingOutPage> {
  int selectedPayment = 0;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      "name": "Apple Pay",
      "image": "images/applepay.png",
      "icon": FontAwesomeIcons.applePay,
    },
    {
      "name": "MasterCard",
      "image": "images/mastercard.png",
      "icon": FontAwesomeIcons.ccMastercard,
    },
    {
      "name": "Visa",
      "image": "images/visa.png",
      "icon": FontAwesomeIcons.ccVisa,
    },
    {
      "name": "Paypal",
      "image": "images/paypal.png",
      "icon": FontAwesomeIcons.paypal,
    },
  ];

  final TextEditingController securityController = TextEditingController();
  final TextEditingController promoController = TextEditingController();

  bool validateCodes() {
    return securityController.text.isNotEmpty ||
        promoController.text.isNotEmpty;
  }

  @override
  void dispose() {
    securityController.dispose();
    promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = paymentMethods[selectedPayment];
    // جلب خصائص الثيم الحالي ديناميكياً
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // تدرج لوني يتكيف تلقائياً حسب وضع الثيم (فاتح أو داكن)
            colors: isDark
                ? [
                    theme.colorScheme.surfaceContainerLowest,
                    theme.colorScheme.surfaceContainerLow,
                    theme.colorScheme.surface,
                  ]
                : [
                    theme.colorScheme.surfaceContainerHigh,
                    theme.colorScheme.surfaceContainerLow,
                    theme.scaffoldBackgroundColor,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    /// TOP BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleButton(
                            theme: theme,
                            icon: Icons.arrow_back_ios_new,
                            onTap: () => Get.back(),
                          ),
                          Text(
                            "check_out".tr,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _circleButton(
                            theme: theme,
                            icon: Icons.shopping_bag_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// MAIN CONTENT (DYNAMIC GLASS STYLE)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 15),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          // ألوان الخلفية والحدود تأخذ شفافية متغيرة بناءً على لون نصوص الخلفية
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.04,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "payment".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Icon(
                                  Icons.more_horiz,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// CARD IMAGE WITH ANIMATED CONTAINER
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow.withValues(
                                      alpha: isDark ? 0.4 : 0.15,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(currentCard["image"]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(height: 35),

                            /// PAYMENT METHODS TITLE
                            Text(
                              "choose_payment".tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// PAYMENT BUTTONS
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(paymentMethods.length, (
                                index,
                              ) {
                                final method = paymentMethods[index];
                                final isSelected = selectedPayment == index;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedPayment = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 75,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.1),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        method["icon"],
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 35),

                            /// SECURITY CODE
                            Text(
                              "sequrity_code".tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: securityController,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "enter_sequrity_code".tr,
                                        hintStyle: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (!validateCodes()) {
                                        Get.snackbar(
                                          "Error",
                                          "Enter Security Code or Promo Code",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }
                                      Get.snackbar(
                                        "Success",
                                        "Code applied",
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    },
                                    child: const Text("Apply"),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 35),

                            /// PROMO CODE
                            Text(
                              "promo_code".tr,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),

                            const SizedBox(height: 18),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: promoController,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "enter_promo_code".tr,
                                        hintStyle: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor:
                                          theme.colorScheme.onPrimary,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (!validateCodes()) {
                                        Get.snackbar(
                                          "Required",
                                          "You must enter Security or Promo code",
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                        return;
                                      }
                                      Get.snackbar(
                                        "Success",
                                        "Approved",
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    },
                                    child: const Text("Apply"),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            /// TOTAL & CHECKOUT BUTTON
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "total_".tr,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        "\$2270",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 22),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 65,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (!validateCodes()) {
                                          Get.snackbar(
                                            "Required",
                                            "Please enter Security Code or Promo Code",
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                          return;
                                        }

                                        Get.snackbar(
                                          "Success",
                                          "Payment completed successfully",
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "make_payment".tr,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required ThemeData theme,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface),
      ),
    );
  }
}
