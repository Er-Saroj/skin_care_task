import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../blocs/routine/routine_bloc.dart';
import '../blocs/routine/routine_event.dart';
import '../blocs/routine/routine_state.dart';
import '../models/routine_step.dart';
import '../theme/app_theme.dart';

class RoutineTab extends StatelessWidget {
  const RoutineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoutineBloc, RoutineState>(
      builder: (context, state) {
        // Show content with loading indicator overlay if loading
        if (state is RoutineLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is RoutineError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RoutineBloc>().add(LoadRoutine());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is RoutineLoaded) {
          final routine = state.routine;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Skincare',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: routine.steps.length,
                    itemBuilder: (context, index) {
                      final step = routine.steps[index];
                      return _buildRoutineStepCard(context, index, step);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // Initial state or fallback
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildRoutineStepCard(
    BuildContext context, 
    int index, 
    RoutineStep step,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.secondaryColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showStepDetails(context, index, step),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isCompleted ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: step.isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.name,
                      style: AppTheme.subheadingStyle,
                    ),
                    if (step.productName != null)
                      Text(
                        step.productName!,
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                _formatTime(step.timestamp),
                style: AppTheme.captionStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _showStepDetails(
    BuildContext context, 
    int index, 
    RoutineStep step,
  ) async {
    final ImagePicker picker = ImagePicker();
    final routineBloc = BlocProvider.of<RoutineBloc>(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.name,
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 16),
                  if (step.photoUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        step.photoUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error_outline, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Product',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: step.productName,
                    decoration: const InputDecoration(
                      hintText: 'Enter product name',
                    ),
                    onChanged: (value) {
                      routineBloc.add(UpdateStepProduct(index, value));
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80, // Optimize image quality
                              maxWidth: 1200,
                            );
                            if (image != null) {
                              Navigator.pop(context);
                              routineBloc.add(UploadStepPhoto(
                                index, 
                                File(image.path),
                              ));
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80, // Optimize image quality
                              maxWidth: 1200,
                            );
                            if (image != null) {
                              Navigator.pop(context);
                              routineBloc.add(UploadStepPhoto(
                                index, 
                                File(image.path),
                              ));
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        routineBloc.add(ToggleStepCompletion(index));
                        Navigator.pop(context);
                      },
                      child: Text(
                        step.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

