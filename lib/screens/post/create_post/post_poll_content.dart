import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';

class PostPollContent extends StatefulWidget {
  final VoidCallback resetPost;
  final PostData postData;
  final VoidCallback validatePost;

  const PostPollContent({
    super.key,
    required this.resetPost,
    required this.postData,
    required this.validatePost,
  });

  @override
  State<PostPollContent> createState() => _PostPollContentState();
}

class _PostPollContentState extends State<PostPollContent> {
  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form

  @override
  void initState() {
    super.initState();
    widget.postData.textController.addListener(_validateForm);
    for (var controller in widget.postData.optionControllers) {
      controller.addListener(_validateForm);
    }
  }

  void _validateForm() {
    widget.validatePost();
  }

  void addOption() {
    if (widget.postData.optionControllers.length < 5) {
      TextEditingController newOptionController = TextEditingController();
      newOptionController.addListener(_validateForm);
      setState(() {
        widget.postData.optionControllers.add(
          newOptionController,
        ); // Use PostData
      });

      widget.validatePost();
    }
  }

  void removeOption(int index) {
    if (widget.postData.optionControllers.length > 2) {
      TextEditingController removedController =
          widget.postData.optionControllers[index];
      removedController.removeListener(_validateForm);
      setState(() {
        widget.postData.optionControllers.removeAt(index); // Use PostData
      });

      widget.validatePost();
    }
  }

  // Function to reset the post with confirmation
  void _resetPostWithConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to remove this poll?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.resetPost(); // Reset
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Remove"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    widget.postData.textController.removeListener(_validateForm);
    for (var controller in widget.postData.optionControllers) {
      controller.removeListener(_validateForm);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        // Wrap the Column with a Form widget
        key: _formKey, // Assign the GlobalKey to the Form
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                AppTheme.isDark(context)
                    ? const Color.fromARGB(92, 33, 33, 33)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.postData.optionControllers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.postData.optionControllers[index],
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "Option ${index + 1}",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color:
                                    AppTheme
                                        .grey300, // Culoarea bordurii este gri
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          validator: (value) {
                            // Add validator
                            if (value == null || value.isEmpty) {
                              return 'Please enter an option';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (widget.postData.optionControllers.length > 2)
                        IconButton(
                          icon: const HeroIcon(
                            HeroIcons.xMark,
                            color: Colors.grey,
                          ),
                          onPressed: () => removeOption(index),
                        ),
                    ],
                  );
                },
              ),
              if (widget.postData.optionControllers.length < 5)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InkWell(
                    onTap: addOption,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.grey300),
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
                    onPressed: _resetPostWithConfirmation,
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
      ),
    );
  }
}
