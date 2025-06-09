import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/core/services/cloudinaryService.dart';

enum _CreationState { idle, uploading, creating, success, error }

class CreateCommunity extends ConsumerStatefulWidget {
  const CreateCommunity({super.key});

  @override
  ConsumerState<CreateCommunity> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<CreateCommunity> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ruleController = TextEditingController();

  bool _onlyAdminsCanPost = false;
  bool _allowAnonymousPosts = false;
  bool _isSubmitting = false;
  XFile? _bannerImage;
  final List<String> _rules = [
    'Respectați ceilalți membri',
    'Fără conținut ilegal',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ruleController.dispose();
    super.dispose();
  }

  Future<void> _pickBannerImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _bannerImage = pickedFile;
      });
    }
  }

  void _addRule() {
    if (_ruleController.text.isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text);
        _ruleController.clear();
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  _CreationState _creationState = _CreationState.idle;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _creationState = _CreationState.uploading);

    try {
      String? bannerUrl;
      String? bannerPublicId;

      if (_bannerImage != null) {
        final file = File(_bannerImage!.path);
        final response = await CloudinaryService.uploadFile(file);
        if (response == null || response['fileUrl'] == null) {
          throw Exception("Banner upload failed");
        }
        bannerUrl = response['fileUrl'];
        bannerPublicId = response['publicId'];
      }

      setState(() => _creationState = _CreationState.creating);

      await ref
          .read(CommunityNotifier.provider.notifier)
          .createCommunity(
            _nameController.text,
            _descriptionController.text,
            onlyAdminsCanPost: _onlyAdminsCanPost,
            allowAnonymousPosts: _allowAnonymousPosts,
            rules: _rules,
            bannerUrl: bannerUrl!,
            bannerPublicId: bannerPublicId!,
          );

      setState(() => _creationState = _CreationState.success);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating community: ${e.toString()}')),
        );
        setState(() => _creationState = _CreationState.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Section
                const Text(
                  'Community Banner',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickBannerImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          AppTheme.isDark(context)
                              ? Colors.grey[900]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child:
                        _bannerImage != null
                            ? FutureBuilder(
                              future: _bannerImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )
                            : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40),
                                  Text('Add Banner Image'),
                                ],
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 24),

                // Basic Info Section
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Community Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a community name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Rules Section
                const Text(
                  'Community Rules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _rules.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.rule, size: 20),
                      title: Text(_rules[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => _removeRule(index),
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ruleController,
                        decoration: const InputDecoration(
                          labelText: 'Add new rule',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addRule,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Settings Section
                const Text(
                  'Community Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Only admins can post'),
                  value: _onlyAdminsCanPost,
                  onChanged:
                      (value) => setState(() => _onlyAdminsCanPost = value),
                ),
                SwitchListTile(
                  title: const Text('Allow anonymous posts'),
                  value: _allowAnonymousPosts,
                  onChanged:
                      (value) => setState(() => _allowAnonymousPosts = value),
                ),
                const SizedBox(height: 32),
                if (_isSubmitting)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
