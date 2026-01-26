import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../widgets/pull_to_refresh.dart';
import '../widgets/clearance/clearance_request_card.dart';
import '../widgets/clearance/clearance_timeline_card.dart';
import '../../../core/viewmodels/clearance_view_model.dart';

class ClearanceScreen extends StatefulWidget {
  const ClearanceScreen({super.key});

  @override
  State<ClearanceScreen> createState() => _ClearanceScreenState();
}

class _ClearanceScreenState extends State<ClearanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load clearance status when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClearanceViewModel>().loadStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: Text(
            "إخلاء الطرف",
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        leading: FadeInDown(
          delay: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF001F3F),
                  Color(0xFFF5F7FA),
                ],
                stops: [0.2, 0.5],
              ),
            ),
          ),

          // Content with ListenableBuilder
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListenableBuilder(
                listenable: context.read<ClearanceViewModel>(),
                builder: (context, _) {
                  final viewModel = context.read<ClearanceViewModel>();

                  return PullToRefresh(
                    onRefresh: () async {
                      await viewModel.loadStatus();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 110),
                          SlideInUp(
                            duration: const Duration(milliseconds: 600),
                            from: 100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: _buildContent(viewModel),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build content based on viewModel state
  Widget _buildContent(ClearanceViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'جاري التحميل...',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (viewModel.errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.loadStatus();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3F),
              ),
              child: Text(
                'إعادة محاولة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // State A: No active request - show ClearanceRequestCard
    if (!viewModel.hasActiveRequest) {
      return const ClearanceRequestCard();
    }

    // State B: Active request - show ClearanceTimelineCard
    return ClearanceTimelineCard(
      clearanceData: viewModel.clearanceData,
    );
  }
}