import 'package:ahmad_website/ui/shared/site_nav_bar.dart';
import 'package:ahmad_website/ui/shared/whatsapp_fab.dart';
import 'package:ahmad_website/ui/views/main_view/widgets/results_section.dart';
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
// import 'widgets/nav_bar.dart';
import 'widgets/offerings_section.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put without Bindings, same as the rest of the codebase.
    final controller = Get.put(MainViewController());

    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: const WhatsappFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Column(
        children: [
          // NavBar(controller: controller),
          const SiteNavBar(),
          Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: Column(
                children: [
                  HeroSection(controller: controller),
                  const ResultsSection(),
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
