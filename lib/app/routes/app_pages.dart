import 'package:ahmad_website/ui/views/checkout_view/checkout_view.dart';
import 'package:ahmad_website/ui/views/consultation_status_view/consultation_status_view.dart';
import 'package:ahmad_website/ui/views/consultation_view/consultation_view_controller.dart';
import 'package:ahmad_website/ui/views/course_view/course_view.dart';
import 'package:ahmad_website/ui/views/forgot_password_view/forgot_password_view.dart';
import 'package:ahmad_website/ui/views/legal_view/legal_view.dart';
import 'package:ahmad_website/ui/views/login_view/login_controller.dart';
import 'package:ahmad_website/ui/views/my_orders_view/my_orders_view.dart';
import 'package:ahmad_website/ui/views/pinding_view/pinding_view.dart';
import 'package:ahmad_website/ui/views/rejected_view/rejected_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/enums/text_style_type.dart';
import '../../ui/shared/app_button.dart';
import '../../ui/shared/colors.dart';
import '../../ui/shared/custom_text.dart';
import '../../ui/views/main_view/main_view.dart';
import '../../ui/views/register_view/register_view.dart';
import 'app_routes.dart';

/// Maps route names to pages. Every screen the site has lives in this list;
/// if it is not here, it has no URL and cannot be linked, refreshed, or
/// indexed.
///
/// Screens are added as they get built. Routes are intentionally NOT
/// commented out ahead of time - a route pointing at a page that does not
/// exist yet fails at build, not at runtime, which is where you want it.
class AppPages {
  AppPages._();

  static const String initial = Routes.main;

  static final List<GetPage> pages = [
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      // Fades rather than slides: on web a horizontal slide reads like a
      // mobile app and feels wrong in a browser tab.
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    //Register route added for the register view
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Login route added for the login view
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Checkout route added for the checkout view
    GetPage(
      name: Routes.checkout,
      page: () => const CheckoutView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Pending route added for the pending view
    GetPage(
      name: Routes.pending,
      page: () => const PendingView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Rejected route added for the rejected view
    GetPage(
      name: Routes.rejected,
      page: () => const RejectedView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Course route added for the course view
    GetPage(
      name: Routes.course,
      page: () => const CourseView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Consultation route added for the consultation view
    GetPage(
      name: Routes.consultation,
      page: () => const ConsultationView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // order route added for the order view
    GetPage(
      name: Routes.myOrders,
      page: () => const MyOrdersView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // forget password route added for the forgot password view
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // consultation status route added for the consultation status view
    GetPage(
      name: Routes.consultationStatus,
      page: () => const ConsultationStatusView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Legal routes added for the terms and privacy views. These are linked from the signup checkbox, so they must exist before launch.
    GetPage(
      name: Routes.terms,
      page: () => const LegalView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Privacy route added for the privacy view. This is linked from the signup checkbox, so it must exist before launch.
    GetPage(
      name: Routes.privacy,
      page: () => const LegalView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),

    // Added as each screen lands:
    //   Routes.forgotPassword  -> ForgotPasswordView
    //   Routes.checkout        -> CheckoutView
    //   Routes.pending         -> PendingView
    //   Routes.rejected        -> RejectedView
    //   Routes.consultation    -> ConsultationView
    //   Routes.course          -> CourseView
    //   Routes.lesson          -> LessonView
    //   Routes.myOrders        -> MyOrdersView
    //   Routes.admin           -> AdminView
    //   Routes.terms/privacy   -> LegalView
    //
    // AuthMiddleware gets attached to the member-area pages once AuthService
    // exists. Until then those pages are open - do not ship in that state.
  ];

  /// Shown for any URL that is not in the list above. Without it, a typo in
  /// the address bar lands the visitor on a blank page with no way back.
  static final GetPage unknownRoute = GetPage(
    name: '/not-found',
    page: () => const _NotFoundView(),
  );
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                text: 'الصفحة غير موجودة',
                styleType: TextStyleType.h2,
              ),
              const SizedBox(height: 8),
              const CustomText(
                text: 'الرابط اللي فتحته مش موجود أو تغيّر.',
                styleType: TextStyleType.medium,
                textColor: AppColors.textMuted,
                alignText: TextAlign.center,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'رجوع للصفحة الرئيسية',
                onPressed: () => Get.offAllNamed(Routes.main),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
