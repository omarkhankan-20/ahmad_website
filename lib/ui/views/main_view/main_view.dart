import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/colors.dart';
import 'main_view_controller.dart';
import 'widgets/about_section.dart';
import 'widgets/consultation_section.dart';
import 'widgets/curriculum_section.dart';
import 'widgets/faq_section.dart';
import 'widgets/final_cta_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/nav_bar.dart';
import 'widgets/offerings_section.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put without Bindings, same as the rest of the codebase.
    final controller = Get.put(MainViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          NavBar(controller: controller),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Column(
                children: [
                  HeroSection(controller: controller),
                  OfferingsSection(controller: controller),
                  AboutSection(controller: controller),
                  const CurriculumSection(),
                  ConsultationSection(controller: controller),
                  FaqSection(controller: controller),
                  FinalCtaSection(controller: controller),
                  const MainFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
