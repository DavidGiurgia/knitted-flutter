import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';

class PostPollContent extends ConsumerWidget {
  const PostPollContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCreationState = ref.watch(postCreationNotifierProvider);
    final notifier = ref.read(postCreationNotifierProvider.notifier);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              AppTheme.foregroundColor(context).withValues(alpha: 0.1), // Light background
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postCreationState.optionControllers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: postCreationState.optionControllers[index],
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: "Option ${index + 1}",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color:
                                  Colors.grey // Culoarea bordurii este gri
                            ),
                          ),

                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          // When text changes, simply trigger validation in the notifier
                          notifier.validatePost();
                        },
                        validator: (value) {
                          // Add validator
                          if (value == null || value.isEmpty) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                    ),
                    if (postCreationState.optionControllers.length > 2)
                      IconButton(
                        icon: const HeroIcon(
                          HeroIcons.xMark,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          // Call the notifier's method to remove the option
                          notifier.removePollOption(
                            index,
                          ); 
                        },
                      ),
                  ],
                );
              },
            ),
            if (postCreationState.optionControllers.length < 4)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: () {
                    // Call the notifier's method to add an option
                    notifier
                        .addPollOption(); // IMPLEMENT THIS METHOD IN THE NOTIFIER
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        SizedBox(width: 8),
                        Text(
                          "Add another option...",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Call notifier method to reset poll data and change type to text
                    notifier.updateField('optionControllers', []);
                    notifier.updateField('selectedPostType', 'text');
                  },
                  child: const Text(
                    "Remove poll",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
